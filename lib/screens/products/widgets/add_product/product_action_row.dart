import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';

class ProductActionsRow extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onBack;
  final bool isProcessing;

  const ProductActionsRow({
    super.key,
    required this.onSave,
    required this.onBack,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: isProcessing ? "جارٍ الحفظ..." : "حفظ المنتج",
            icon: Icons.save,
            backgroundColor: Colors.blueAccent,
            onPressed: isProcessing ? null : onSave,
            height: 55,
          ),
        ),
        const Spacer(),
        Expanded(
          child: CustomButton(
            text: "رجوع",
            icon: Icons.arrow_back,
            backgroundColor: Colors.grey,
            onPressed: isProcessing ? null : onBack,
            height: 55,
          ),
        ),
      ],
    );
  }
}
