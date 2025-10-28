import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/Customers/cubit.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';

class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController noteController;
  late TextEditingController creditLimitController;

  String? selectedType;
  final List<String> customerTypes = ["قطاعي", "جملة", "آخر"];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات الحالية
    nameController = TextEditingController(text: widget.customer.name);
    phoneController = TextEditingController(text: widget.customer.phone);
    addressController = TextEditingController(text: widget.customer.address);
    noteController = TextEditingController(text: widget.customer.notes);
    creditLimitController = TextEditingController(
      text: widget.customer.creditLimit?.toString() ?? '',
    );
    selectedType = widget.customer.type;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();
    creditLimitController.dispose();
    super.dispose();
  }

  void updateCustomer() {
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      final updatedCustomer = Customer(
        id: widget.customer.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        notes: noteController.text.trim(),
        type: selectedType ?? "آخر",
        creditLimit: creditLimitController.text.isEmpty 
            ? null 
            : double.tryParse(creditLimitController.text),
      );

      context.read<CustomerCubit>().updateCustomer(updatedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        title: const Text("تعديل العميل", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is CustomerUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ تم تعديل العميل بنجاح"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is CustomerOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "تعديل بيانات العميل",
                        style: TextStyle(
                          color: Colors.blueAccent.shade100,
                          fontSize: Responsive.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // اسم العميل
                      CustomInputField(
                        label: "اسم العميل",
                        hint: "اكتب اسم العميل",
                        controller: nameController,
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
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
                        onItemSelected: (val) => setState(() => selectedType = val),
                        prefixIcon: const Icon(Icons.group, color: Colors.white70),
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
                        prefixIcon: const Icon(Icons.phone, color: Colors.white70),
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
                        prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
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
                        prefixIcon: const Icon(Icons.note_alt, color: Colors.white70),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // الحد الائتماني
                      CustomInputField(
                        label: "الحد الائتماني (اختياري)",
                        hint: "اكتب المبلغ المسموح به",
                        controller: creditLimitController,
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.money, color: Colors.white70),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                            if (amount < 0) {
                              return 'المبلغ يجب أن يكون موجب';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // الأزرار
                      Row(
                        children: [
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                    ),
                                  )
                                : CustomButton(
                                    text: "حفظ التعديلات",
                                    icon: Icons.save,
                                    onPressed: updateCustomer,
                                    backgroundColor: Colors.blueAccent,
                                    textColor: Colors.white,
                                    elevation: 3,
                                    fullWidth: true,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: "إلغاء",
                              icon: Icons.close,
                              onPressed: _isLoading 
                                  ? null 
                                  : () => Navigator.pop(context),
                              isOutlined: true,
                              borderColor: Colors.grey,
                              textColor: Colors.grey[300],
                              fullWidth: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}