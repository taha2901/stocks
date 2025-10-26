import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/sales_invoice_model.dart';

class TotalsSectionWidget extends StatefulWidget {
  final SalesInvoiceModel invoice;
  final TextEditingController discountController;
  final VoidCallback onChanged;

  const TotalsSectionWidget({
    super.key,
    required this.invoice,
    required this.discountController,
    required this.onChanged,
  });

  @override
  State<TotalsSectionWidget> createState() => _TotalsSectionWidgetState();
}

class _TotalsSectionWidgetState extends State<TotalsSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow(
          "الإجمالي قبل الخصم",
          widget.invoice.totalBeforeDiscount.toStringAsFixed(2),
        ),
        const SizedBox(height: 10),

        // حقل الخصم
        CustomInputField(
          controller: widget.discountController,
          label: "الخصم",
          hint: "أدخل قيمة الخصم",
          isNumber: true,
          prefixIcon: const Icon(Icons.discount, color: Colors.white70),
          onChanged: (val) {
            setState(() => widget.invoice.discount = double.tryParse(val) ?? 0);
            widget.onChanged();
          },
        ),

        const SizedBox(height: 10),
        _buildSummaryRow(
          "الإجمالي بعد الخصم",
          widget.invoice.totalAfterDiscount.toStringAsFixed(2),
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
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
