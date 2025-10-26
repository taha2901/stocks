import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/core/widgets/custom_button.dart'; // ✅ استدعاء الزر المخصص

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController purchasePriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController pointPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    "إلكترونيات",
    "ملابس",
    "أغذية",
    "أدوات مكتبية",
    "منزلية",
  ];

  @override
  void dispose() {
    nameController.dispose();
    purchasePriceController.dispose();
    sellPriceController.dispose();
    pointPriceController.dispose();
    quantityController.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  void saveProduct() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إضافة المنتج بنجاح"),
          backgroundColor: Colors.blueAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        title: const Text("إضافة منتج", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "قم بإضافة منتج جديد إلى قاعدة البيانات",
                    style: TextStyle(
                      color: Colors.blueAccent.shade100,
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2F48),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "تفاصيل المنتج",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.fontSize(context, 18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🔹 اسم المنتج
                          CustomInputField(
                            label: "اسم المنتج",
                            controller: nameController,
                            prefixIcon: const Icon(
                              Icons.note_alt_outlined,
                              color: Colors.white,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "يرجى إدخال الاسم"
                                : null,
                          ),
                          const SizedBox(height: 15),

                          // 🔹 الفئة
                          CustomInputField(
                            label: "الفئة",
                            items: categories,
                            selectedValue: selectedCategory,
                            onItemSelected: (value) =>
                                setState(() => selectedCategory = value),
                            prefixIcon: const Icon(
                              Icons.category,
                              color: Colors.white,
                            ),
                            validator: (v) =>
                                selectedCategory == null ? "اختر فئة" : null,
                          ),

                          const SizedBox(height: 15),

                          // 🔹 الأسعار
                          ResponsiveLayout(
                            mobile: Column(
                              children: [
                                CustomInputField(
                                  label: "سعر الشراء",
                                  controller: purchasePriceController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.price_check,
                                    color: Colors.white,
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "أدخل سعر الشراء"
                                      : null,
                                ),
                                CustomInputField(
                                  label: "سعر البيع",
                                  controller: sellPriceController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.price_change,
                                    color: Colors.white,
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "أدخل سعر البيع"
                                      : null,
                                ),
                                CustomInputField(
                                  label: "سعر نقطة البيع",
                                  controller: pointPriceController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(
                                    Icons.point_of_sale,
                                    color: Colors.white,
                                  ),
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
                                    prefixIcon: const Icon(
                                      Icons.price_check,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: CustomInputField(
                                    label: "سعر البيع",
                                    controller: sellPriceController,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.price_change,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: CustomInputField(
                                    label: "سعر نقطة البيع",
                                    controller: pointPriceController,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: const Icon(
                                      Icons.point_of_sale,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 🔹 الكمية
                          CustomInputField(
                            label: "الكمية",
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(
                              Icons.production_quantity_limits,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // 🔹 الباركود
                          CustomInputField(
                            label: "الباركود",
                            controller: barcodeController,
                            prefixIcon: const Icon(
                              Icons.qr_code,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ✅ الأزرار (باستخدام CustomButton)
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: "حفظ المنتج",
                                  icon: Icons.save,
                                  backgroundColor: Colors.blueAccent,
                                  onPressed: saveProduct,
                                  height: 55,
                                ),
                              ),
                              Spacer(),
                              Expanded(
                                child: CustomButton(
                                  text: "رجوع",
                                  icon: Icons.arrow_back,
                                  backgroundColor: Colors.grey,
                                  onPressed: () => Navigator.pop(context),
                                  height: 55,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
