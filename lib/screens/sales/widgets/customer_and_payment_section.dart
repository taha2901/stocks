
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';

class CustomerAndPaymentSection extends StatelessWidget {
  final SalesInvoiceModel invoice;
  final List<String> paymentMethods;
  final void Function(String id, String name) onCustomerSelected;
  final ValueChanged<String?> onPaymentTypeSelected;

  const CustomerAndPaymentSection({
    super.key,
    required this.invoice,
    required this.paymentMethods,
    required this.onCustomerSelected,
    required this.onPaymentTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CustomerCubit, CustomerState>(
          builder: (context, customerState) {
            if (customerState is CustomerLoaded) {
              final customers = customerState.customers;
              return CustomInputField(
                label: "العميل",
                hint: "اختر العميل",
                items: customers.map((c) => c.name).toList(),
                selectedValue: invoice.customerName,
                onItemSelected: (value) {
                  if (value == null) return;
                  final customer = customers.firstWhere((c) => c.name == value);
                  onCustomerSelected(customer.id, customer.name);
                },
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        const SizedBox(height: 16),
        CustomInputField(
          label: "نوع الدفع",
          hint: "اختر نوع الدفع",
          items: paymentMethods,
          selectedValue: invoice.paymentType,
          onItemSelected: onPaymentTypeSelected,
          prefixIcon: const Icon(Icons.payment, color: Colors.white70),
        ),
      ],
    );
  }
}
