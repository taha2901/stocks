import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart' show CustomInputField;

class ProductPricesFields extends StatelessWidget {
  final TextEditingController purchasePriceController;
  final TextEditingController sellPriceController;
  final TextEditingController pointPriceController;

  const ProductPricesFields({
    super.key,
    required this.purchasePriceController,
    required this.sellPriceController,
    required this.pointPriceController,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Column(
        children: [
          CustomInputField(
            label: "سعر الشراء",
            controller: purchasePriceController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.price_check, color: Colors.white),
            validator: (v) => v == null || v.isEmpty ? "أدخل سعر الشراء" : null,
          ),
          CustomInputField(
            label: "سعر البيع",
            controller: sellPriceController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.price_change, color: Colors.white),
            validator: (v) => v == null || v.isEmpty ? "أدخل سعر البيع" : null,
          ),
          CustomInputField(
            label: "سعر نقطة البيع",
            controller: pointPriceController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.point_of_sale, color: Colors.white),
          ),
        ],
      ),
      tablet: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          SizedBox(
            width: 200,
            child: CustomInputField(
              label: "سعر الشراء",
              controller: purchasePriceController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.price_check, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 200,
            child: CustomInputField(
              label: "سعر البيع",
              controller: sellPriceController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.price_change, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 200,
            child: CustomInputField(
              label: "سعر نقطة البيع",
              controller: pointPriceController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.point_of_sale, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
