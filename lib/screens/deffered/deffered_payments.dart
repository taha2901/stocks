import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/deffered/cubit.dart';
import 'package:management_stock/cubits/deffered/states.dart';
import 'package:management_stock/models/defferred_account_model.dart';
import 'package:management_stock/screens/deffered/customer_details_dialouge.dart';

class DeferredAccountsScreen extends StatefulWidget {
  const DeferredAccountsScreen({super.key});

  @override
  State<DeferredAccountsScreen> createState() => _DeferredAccountsScreenState();
}

class _DeferredAccountsScreenState extends State<DeferredAccountsScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DeferredAccountCubit>().fetchDeferredAccounts();
    context.read<DeferredAccountCubit>().listenToDeferredAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(MediaQuery.of(context).size.width * 0.04);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "حسابات العملاء (آجل)",
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: BlocListener<DeferredAccountCubit, DeferredAccountState>(
        listener: (context, state) {
          if (state is PaymentAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PaymentAddError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<DeferredAccountCubit, DeferredAccountState>(
                  builder: (context, state) {
                    if (state is DeferredAccountLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DeferredAccountError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is DeferredAccountLoaded) {
                      return isMobile
                          ? _buildMobileView(state.filteredAccounts)
                          : _buildTableView(context, state.filteredAccounts);
                    }
                    return const Center(
                      child: Text(
                        'لا توجد بيانات',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return CustomInputField(
      controller: searchController,
      label: "بحث باسم العميل",
      hint: "اكتب اسم العميل للبحث...",
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: (value) {
        context.read<DeferredAccountCubit>().searchAccounts(value);
      },
    );
  }

  Widget _buildMobileView(List<DeferredAccountModel> accounts) {
    if (accounts.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد عملاء',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: const Color(0xFF2C2F48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _showCustomerDetails(context, account);
                      },
                      icon: const Icon(
                        Icons.visibility,
                        color: Color(0xFF1976D2),
                        size: 16,
                      ),
                      label: const Text(
                        "عرض",
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Text(
                      account.customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMobileInfoRow(
                  "عدد الفواتير 📋",
                  "${account.invoiceCount}",
                  color: Colors.white,
                ),
                _buildMobileInfoRow(
                  "إجمالي الأجل 💰",
                  "${account.totalAmount.toStringAsFixed(2)} جنيه",
                  color: Colors.white,
                ),
                _buildMobileInfoRow(
                  "المدفوع ✅",
                  "${account.paid.toStringAsFixed(2)} جنيه",
                  color: Colors.green,
                ),
                _buildMobileInfoRow(
                  "المتبقي ⚠️",
                  "${account.remaining.toStringAsFixed(2)} جنيه",
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(
      BuildContext context, List<DeferredAccountModel> accounts) {
    if (accounts.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد عملاء',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2F48),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeader("تفاصيل 🔍", flex: 1),
                _buildTableHeader("المتبقي ⚠️", flex: 2),
                _buildTableHeader("المدفوع ✅", flex: 2),
                _buildTableHeader("إجمالي الأجل 💰", flex: 2),
                _buildTableHeader("عدد الفواتير 📋", flex: 2),
                _buildTableHeader("اسم العميل 👤", flex: 3),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showCustomerDetails(context, account);
                              },
                              icon: const Icon(
                                Icons.visibility,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              label: const Text(
                                "عرض",
                                style: TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF1976D2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildTableCell(
                          "${account.remaining.toStringAsFixed(2)} جنيه",
                          flex: 2,
                          color: Colors.red,
                        ),
                        _buildTableCell(
                          "${account.paid.toStringAsFixed(2)} جنيه",
                          flex: 2,
                          color: Colors.green,
                        ),
                        _buildTableCell(
                          "${account.totalAmount.toStringAsFixed(2)} جنيه",
                          color: Colors.yellow,
                          flex: 2,
                        ),
                        _buildTableCell(
                          "${account.invoiceCount}",
                          color: const Color(0xFF1976D2),
                          flex: 2,
                        ),
                        _buildTableCell(
                          account.customerName,
                          flex: 3,
                          color: Colors.white,
                          isBold: true,
                        ),
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

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    required int flex,
    Color? color,
    bool isBold = false,
  }) {
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

  void _showCustomerDetails(
      BuildContext context, DeferredAccountModel account) {
    showDialog(
      context: context,
      builder: (context) => CustomerDetailsDialog(account: account),
    );
  }
}
