import 'package:flutter/material.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';

class CustomerFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController noteController;
  final String? selectedType;
  final List<String> customerTypes;
  final Function(String?) onTypeSelected;

  const CustomerFormFields({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.noteController,
    required this.selectedType,
    required this.customerTypes,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField(
          label: "اسم العميل",
          hint: "اكتب اسم العميل",
          controller: nameController,
          prefixIcon: const Icon(
            Icons.person,
            color: Colors.white70,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم العميل';
            }
            if (value.trim().length < 3) {
              return 'اسم العميل يجب أن يكون 3 أحرف على الأقل';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // نوع العميل
        CustomInputField(
          label: "نوع العميل",
          hint: "اختر نوع العميل",
          items: customerTypes,
          selectedValue: selectedType,
          onItemSelected: onTypeSelected,
          prefixIcon: const Icon(
            Icons.group,
            color: Colors.white70,
          ),
          validator: (value) {
            if (selectedType == null || selectedType!.isEmpty) {
              return 'يرجى اختيار نوع العميل';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // رقم الهاتف
        CustomInputField(
          label: "رقم الهاتف",
          hint: "اكتب رقم الهاتف",
          controller: phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(
            Icons.phone,
            color: Colors.white70,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال رقم الهاتف';
            }
            if (value.trim().length < 11) {
              return 'رقم الهاتف يجب أن يكون 11 رقم على الأقل';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // العنوان
        CustomInputField(
          label: "العنوان",
          hint: "اكتب العنوان",
          controller: addressController,
          prefixIcon: const Icon(
            Icons.location_on,
            color: Colors.white70,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال العنوان';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // الملاحظات
        CustomInputField(
          label: "ملاحظات",
          hint: "اكتب أي ملاحظات (اختياري)",
          controller: noteController,
          prefixIcon: const Icon(
            Icons.note_alt,
            color: Colors.white70,
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
