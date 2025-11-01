import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class DeferredPaymentWidget extends StatelessWidget {
  final double baseTotalAfterDiscount;
  final TextEditingController paidNowController;
  final TextEditingController interestRateController;
  final double paidNow;
  final double interestRate;
  final ValueChanged<double> onPaidNowChanged;
  final ValueChanged<double> onInterestRateChanged;

  const DeferredPaymentWidget({
    super.key,
    required this.baseTotalAfterDiscount,
    required this.paidNowController,
    required this.interestRateController,
    required this.paidNow,
    required this.interestRate,
    required this.onPaidNowChanged,
    required this.onInterestRateChanged,
  });

  double _totalAfterInterest(double base, double rate) => base + (base * rate / 100);

  @override
  Widget build(BuildContext context) {
    final totalAfterInterest = _totalAfterInterest(baseTotalAfterDiscount, interestRate);
    final remaining = (totalAfterInterest - paidNow).clamp(0, double.infinity);

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
                  controller: paidNowController,
                  label: "المدفوع الآن",
                  hint: "0",
                  isNumber: true,
                  onChanged: (val) => onPaidNowChanged(double.tryParse(val) ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomInputField(
                  controller: interestRateController,
                  label: "نسبة الفائدة (%)",
                  hint: "0",
                  isNumber: true,
                  onChanged: (val) => onInterestRateChanged(double.tryParse(val) ?? 0),
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
