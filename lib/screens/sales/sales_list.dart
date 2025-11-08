import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/sales/cubit.dart';
import 'package:management_stock/cubits/sales/states.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/sales_details_dialouge.dart';

class SalesInvoicesListScreen extends StatefulWidget {
  const SalesInvoicesListScreen({super.key});

  @override
  State<SalesInvoicesListScreen> createState() => _SalesInvoicesListScreenState();
}

class _SalesInvoicesListScreenState extends State<SalesInvoicesListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<SalesInvoiceModel> filteredInvoices = [];
  List<SalesInvoiceModel> allInvoices = [];


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
          final customerName = (invoice.customerName ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return customerName.contains(searchLower) || invoice.id.contains(searchLower);
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
            'فواتير البيع 🧾',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.point_of_sale, color: Colors.white, size: 24),
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
      hint: 'ابحث باسم العميل أو رقم الفاتورة...',
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: _filterInvoices,
    );
  }

  Widget _buildInvoicesList(bool isDesktop) {
    return BlocBuilder<SalesInvoiceCubit, SalesInvoiceState>(
      builder: (context, state) {
        if (state is SalesInvoiceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SalesInvoiceError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(state.error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<SalesInvoiceCubit>().fetchInvoices(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                ),
              ],
            ),
          );
        }

        if (state is SalesInvoiceLoaded) {
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
                    searchController.text.isEmpty ? 'لا توجد فواتير بيع' : 'لا توجد نتائج',
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

  Widget _buildDesktopTable(List<SalesInvoiceModel> invoices) {
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
                _buildTableHeader('المتبقي', flex: 2),
                _buildTableHeader('الإجمالي', flex: 2),
                _buildTableHeader('نوع الدفع', flex: 2),
                _buildTableHeader('التاريخ', flex: 2),
                _buildTableHeader('العميل', flex: 3),
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
                        _buildTableCell(
                          invoice.paymentType == 'آجل' 
                              ? currencyFormat.format(invoice.remaining) 
                              : '-',
                          flex: 2,
                          color: invoice.remaining > 0 ? Colors.red : Colors.green,
                        ),
                        _buildTableCell(currencyFormat.format(invoice.totalAfterDiscount), flex: 2, color: Colors.green),
                        _buildTableCell(
                          invoice.paymentType ?? 'كاش',
                          flex: 2,
                          color: invoice.paymentType == 'آجل' ? Colors.orange : Colors.blue,
                        ),
                        _buildTableCell(DateFormat('yyyy/MM/dd').format(invoice.invoiceDate!), flex: 2),
                        _buildTableCell(invoice.customerName ?? 'غير محدد', flex: 3, isBold: true),
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

  Widget _buildMobileList(List<SalesInvoiceModel> invoices) {
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
                      icon: const Icon(Icons.visibility, color: Colors.green, size: 16),
                      label: const Text('عرض', style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    Text(
                      invoice.customerName ?? 'غير محدد',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('التاريخ 📅', DateFormat('yyyy/MM/dd').format(invoice.invoiceDate!)),
                _buildInfoRow('نوع الدفع 💳', invoice.paymentType ?? 'كاش', valueColor: invoice.paymentType == 'آجل' ? Colors.orange : Colors.blue),
                _buildInfoRow('الإجمالي 💰', currencyFormat.format(invoice.totalAfterDiscount), valueColor: Colors.green),
                if (invoice.paymentType == 'آجل')
                  _buildInfoRow('المتبقي ⚠️', currencyFormat.format(invoice.remaining), valueColor: invoice.remaining > 0 ? Colors.red : Colors.green),
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

  Widget _buildActionButtons(SalesInvoiceModel invoice, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.green),
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

  void _showInvoiceDetails(SalesInvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => SalesInvoiceDetailsDialog(invoice: invoice),
    );
  }
}
