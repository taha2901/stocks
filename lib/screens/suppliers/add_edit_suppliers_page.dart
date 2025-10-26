import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/suppliers.dart';

class AddEditSupplierPage extends StatefulWidget {
  final Supplier? supplier;
  final Function(Supplier) onSave;

  const AddEditSupplierPage({super.key, this.supplier, required this.onSave});

  @override
  State<AddEditSupplierPage> createState() => _AddEditSupplierPageState();
}

class _AddEditSupplierPageState extends State<AddEditSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.supplier?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.supplier?.address ?? '',
    );
    _notesController = TextEditingController(
      text: widget.supplier?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            isEdit ? 'تعديل مورد' : 'إضافة مورد جديد',
            style: const TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Responsive.value(
                  context: context,
                  mobile: double.infinity,
                  tablet: 600,
                  desktop: 700,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomInputField(
                      controller: _nameController,
                      label: 'الاسم',
                      prefixIcon: Icon(Icons.person),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _phoneController,
                      label: 'رقم الجوال',
                      prefixIcon: Icon(Icons.phone),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'الرجاء إدخال رقم الجوال'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _addressController,
                      label: 'العنوان',
                      prefixIcon: Icon(Icons.location_on),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'الرجاء إدخال العنوان'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _notesController,
                      label: 'ملاحظات',
                      prefixIcon: Icon(Icons.notes),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'الرجاء إدخال الملاحظات'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: "حفظ",
                            onPressed: _saveSupplier,
                            icon: Icons.save,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: "إلغاء",
                            onPressed: () => Navigator.pop(context),
                            icon: Icons.cancel,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveSupplier() {
    if (_formKey.currentState?.validate() ?? false) {
      final supplier = Supplier(
        id:
            widget.supplier?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        notes: _notesController.text,
      );
      widget.onSave(supplier);
      Navigator.pop(context);
    }
  }
}