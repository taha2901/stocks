import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class POSBarcodeInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const POSBarcodeInput({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          controller: controller,
          hint: "أدخل باركود المنتج 🔍",
          prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: "إضافة للسلة",
            icon: Icons.add_shopping_cart,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}
