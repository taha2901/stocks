import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class ProductBasicFields extends StatelessWidget {
  final TextEditingController nameController;
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const ProductBasicFields({
    super.key,
    required this.nameController,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          label: "اسم المنتج",
          controller: nameController,
          prefixIcon: const Icon(Icons.note_alt_outlined, color: Colors.white),
          validator: (v) => v == null || v.isEmpty ? "يرجى إدخال الاسم" : null,
        ),
        const SizedBox(height: 15),
        CustomInputField(
          label: "الفئة",
          items: categories,
          selectedValue: selectedCategory,
          onItemSelected: onCategoryChanged,
          prefixIcon: const Icon(Icons.category, color: Colors.white),
          validator: (v) => selectedCategory == null ? "اختر فئة" : null,
        ),
      ],
    );
  }
}
