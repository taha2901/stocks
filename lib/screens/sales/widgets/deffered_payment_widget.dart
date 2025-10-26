import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/sales_invoice_model.dart';

class DeferredPaymentWidget extends StatefulWidget {
  final SalesInvoiceModel invoice;
  final TextEditingController paidNowController;
  final TextEditingController interestRateController;
  final double paidNow;
  final double interestRate;
  final ValueChanged<double> onPaidNowChanged;
  final ValueChanged<double> onInterestRateChanged;

  const DeferredPaymentWidget({
    super.key,
    required this.invoice,
    required this.paidNowController,
    required this.interestRateController,
    required this.paidNow,
    required this.interestRate,
    required this.onPaidNowChanged,
    required this.onInterestRateChanged,
  });

  double get totalAfterInterest =>
      invoice.totalAfterDiscount + (invoice.totalAfterDiscount * interestRate / 100);

  @override
  State<DeferredPaymentWidget> createState() => _DeferredPaymentWidgetState();
}

class _DeferredPaymentWidgetState extends State<DeferredPaymentWidget> {
  @override
  Widget build(BuildContext context) {
    final totalAfterInterest = widget.totalAfterInterest;
    final remaining = totalAfterInterest - widget.paidNow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF2C2F48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomInputField(
                  controller: widget.paidNowController,
                  label: "المدفوع الآن",
                  hint: "0",
                  isNumber: true,
                  onChanged: (val) {
                    final paid = double.tryParse(val) ?? 0;
                    setState(() => widget.onPaidNowChanged(paid));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInputField(
                  controller: widget.interestRateController,
                  label: "نسبة الفائدة (%)",
                  hint: "0",
                  isNumber: true,
                  onChanged: (val) {
                    final rate = double.tryParse(val) ?? 0;
                    setState(() => widget.onInterestRateChanged(rate));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInputField(
                  label: "المتبقي",
                  hint: "0.00",
                  readOnly: true,
                  controller: TextEditingController(
                    text: remaining.toStringAsFixed(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF353855),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "الإجمالي بعد الفائدة",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  totalAfterInterest.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
