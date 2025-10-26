import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class PurchaseTotalsSection extends StatelessWidget {
  final TextEditingController discountController;
  final double totalBeforeDiscount;
  final double totalAfterDiscount;
  final void Function(String) onDiscountChanged;

  const PurchaseTotalsSection({
    super.key,
    required this.discountController,
    required this.totalBeforeDiscount,
    required this.totalAfterDiscount,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow(
          "الإجمالي قبل الخصم",
          totalBeforeDiscount.toStringAsFixed(2),
        ),
        const SizedBox(height: 10),

        // حقل الخصم
        CustomInputField(
          controller: discountController,
          label: "الخصم",
          hint: "أدخل قيمة الخصم",
          isNumber: true,
          prefixIcon: const Icon(Icons.discount, color: Colors.white70),
          onChanged: onDiscountChanged,
        ),

        const SizedBox(height: 10),
        _buildSummaryRow(
          "الإجمالي بعد الخصم",
          totalAfterDiscount.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF353855),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
