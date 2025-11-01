import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class TotalsSectionWidget extends StatelessWidget {
  final double totalBeforeDiscount;
  final double totalAfterDiscount;
  final TextEditingController discountController;
  final ValueChanged<double> onDiscountChanged;

  const TotalsSectionWidget({
    super.key,
    required this.totalBeforeDiscount,
    required this.totalAfterDiscount,
    required this.discountController,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(label: "الإجمالي قبل الخصم", value: totalBeforeDiscount.toStringAsFixed(2)),
        const SizedBox(height: 10),
        CustomInputField(
          controller: discountController,
          label: "الخصم",
          hint: "أدخل قيمة الخصم",
          isNumber: true,
          prefixIcon: const Icon(Icons.discount, color: Colors.white70),
          onChanged: (val) => onDiscountChanged(double.tryParse(val) ?? 0),
        ),
        const SizedBox(height: 10),
        _SummaryRow(label: "الإجمالي بعد الخصم", value: totalAfterDiscount.toStringAsFixed(2)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF353855),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
