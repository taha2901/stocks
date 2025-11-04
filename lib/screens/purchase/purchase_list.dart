import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/purchase/cubit.dart';
import 'package:management_stock/cubits/purchase/states.dart';
import 'package:management_stock/models/purchase/purchase_invoice_item.dart';
import 'package:management_stock/screens/purchase/widgets/purchase_details_dialouge.dart';

class PurchaseInvoicesListScreen extends StatefulWidget {
  const PurchaseInvoicesListScreen({super.key});

  @override
  State<PurchaseInvoicesListScreen> createState() => _PurchaseInvoicesListScreenState();
}

class _PurchaseInvoicesListScreenState extends State<PurchaseInvoicesListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<PurchaseInvoiceModel> filteredInvoices = [];
  List<PurchaseInvoiceModel> allInvoices = [];

  @override
  void initState() {
    super.initState();
    context.read<PurchaseInvoiceCubit>().fetchInvoices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterInvoices(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredInvoices = allInvoices;
      } else {
        filteredInvoices = allInvoices.where((invoice) {
          final supplierName = invoice.supplierName.toLowerCase();
          final searchLower = query.toLowerCase();
          return supplierName.contains(searchLower) || invoice.id.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildInvoicesList(isDesktop)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2C2F48),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'فواتير الشراء 📋',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 24),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomInputField(
      controller: searchController,
      hint: 'ابحث باسم المورد أو رقم الفاتورة...',
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: _filterInvoices,
    );
  }

  Widget _buildInvoicesList(bool isDesktop) {
    return BlocBuilder<PurchaseInvoiceCubit, PurchaseInvoiceState>(
      builder: (context, state) {
        if (state is PurchaseInvoiceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PurchaseInvoiceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<PurchaseInvoiceCubit>().fetchInvoices(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
              ],
            ),
          );
        }

        if (state is PurchaseInvoiceLoaded) {
          allInvoices = state.invoices;
          
          // أول مرة نجيب البيانات
          if (filteredInvoices.isEmpty && searchController.text.isEmpty) {
            filteredInvoices = allInvoices;
          }

          if (filteredInvoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, color: Colors.white38, size: 80),
                  const SizedBox(height: 16),
                  Text(
                    searchController.text.isEmpty ? 'لا توجد فواتير شراء' : 'لا توجد نتائج',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return isDesktop
              ? _buildDesktopTable(filteredInvoices)
              : _buildMobileList(filteredInvoices);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildDesktopTable(List<PurchaseInvoiceModel> invoices) {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF353855),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeader('الإجراءات', flex: 1),
                _buildTableHeader('الإجمالي', flex: 2),
                _buildTableHeader('الخصم', flex: 2),
                _buildTableHeader('عدد المنتجات', flex: 2),
                _buildTableHeader('التاريخ', flex: 2),
                _buildTableHeader('المورد', flex: 3),
              ],
            ),
          ),
          // Body
          Expanded(
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Row(
                      children: [
                        _buildActionButtons(invoice, flex: 1),
                        _buildTableCell(currencyFormat.format(invoice.totalAfterDiscount), flex: 2, color: Colors.green),
                        _buildTableCell(currencyFormat.format(invoice.discount), flex: 2, color: Colors.orange),
                        _buildTableCell('${invoice.items.length}', flex: 2),
                        _buildTableCell(DateFormat('yyyy/MM/dd').format(invoice.invoiceDate), flex: 2),
                        _buildTableCell(invoice.supplierName, flex: 3, isBold: true),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<PurchaseInvoiceModel> invoices) {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF2C2F48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showInvoiceDetails(invoice),
                      icon: const Icon(Icons.visibility, color: Colors.blueAccent, size: 16),
                      label: const Text('عرض', style: TextStyle(color: Colors.blueAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Text(
                      invoice.supplierName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('التاريخ 📅', DateFormat('yyyy/MM/dd').format(invoice.invoiceDate)),
                _buildInfoRow('عدد المنتجات 📦', '${invoice.items.length}'),
                _buildInfoRow('الخصم 🏷️', currencyFormat.format(invoice.discount), valueColor: Colors.orange),
                _buildInfoRow('الإجمالي 💰', currencyFormat.format(invoice.totalAfterDiscount), valueColor: Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {required int flex, Color? color, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color ?? Colors.white70,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButtons(PurchaseInvoiceModel invoice, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blueAccent),
          onPressed: () => _showInvoiceDetails(invoice),
          tooltip: 'عرض التفاصيل',
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(color: valueColor ?? Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  void _showInvoiceDetails(PurchaseInvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => PurchaseInvoiceDetailsDialog(invoice: invoice),
    );
  }
}
