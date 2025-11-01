import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class ProductFiltersBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onBarcodeChanged;

  const ProductFiltersBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onBarcodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomInputField(
            label: "الفئة",
            items: categories,
            selectedValue: selectedCategory,
            onItemSelected: onCategoryChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomInputField(
            label: "بحث بالباركود",
            hint: "أدخل الباركود أو جزء منه",
            prefixIcon: const Icon(Icons.qr_code, color: Colors.white70),
            onChanged: onBarcodeChanged,
          ),
        ),
      ],
    );
  }
}