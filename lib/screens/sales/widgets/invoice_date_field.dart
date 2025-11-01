
import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class InvoiceDateField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const InvoiceDateField({super.key, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: "تاريخ الفاتورة",
      hint: "اختر التاريخ",
      readOnly: true,
      controller: TextEditingController(
        text: "${date.day}/${date.month}/${date.year}",
      ),
      prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}
