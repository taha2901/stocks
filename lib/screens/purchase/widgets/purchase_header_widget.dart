import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/suppliers.dart';

class PurchaseHeaderWidget extends StatelessWidget {
  final String? selectedSupplier;
  final String? paymentType;
  final DateTime? invoiceDate;
  final ValueChanged<String?> onSupplierChanged;
  final ValueChanged<String?> onPaymentChanged;
  final ValueChanged<DateTime?> onDateChanged;

  const PurchaseHeaderWidget({
    super.key,
    required this.selectedSupplier,
    required this.paymentType,
    required this.invoiceDate,
    required this.onSupplierChanged,
    required this.onPaymentChanged,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final paymentMethods = ['كاش', 'آجل'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // المورد
        CustomInputField(
          label: "المورد",
          hint: "اختر المورد",
          items: dummySuppliers.map((s) => s.name).toList(),
          selectedValue: selectedSupplier,
          onItemSelected: onSupplierChanged,
          prefixIcon: const Icon(Icons.person, color: Colors.white70),
        ),
        const SizedBox(height: 16),

        // نوع الدفع
        CustomInputField(
          label: "نوع الدفع",
          hint: "اختر نوع الدفع",
          items: paymentMethods,
          selectedValue: paymentType,
          onItemSelected: onPaymentChanged,
          prefixIcon: const Icon(Icons.payment, color: Colors.white70),
        ),
        const SizedBox(height: 16),

        // تاريخ الفاتورة
        CustomInputField(
          label: "تاريخ الفاتورة",
          hint: "اختر التاريخ",
          readOnly: true,
          controller: TextEditingController(
            text: invoiceDate == null
                ? ''
                : "${invoiceDate!.day}/${invoiceDate!.month}/${invoiceDate!.year}",
          ),
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: invoiceDate ?? now,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: Colors.blueAccent,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            onDateChanged(picked);
          },
        ),
      ],
    );
  }
}
