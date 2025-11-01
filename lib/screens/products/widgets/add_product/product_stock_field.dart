import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class ProductStockFields extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController barcodeController;

  const ProductStockFields({
    super.key,
    required this.quantityController,
    required this.barcodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          label: "الكمية",
          controller: quantityController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.production_quantity_limits, color: Colors.white),
        ),
        const SizedBox(height: 15),
        CustomInputField(
          label: "الباركود",
          controller: barcodeController,
          prefixIcon: const Icon(Icons.qr_code, color: Colors.white),
        ),
      ],
    );
  }
}
