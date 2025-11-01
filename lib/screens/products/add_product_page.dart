import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/products/widgets/add_product/product_action_row.dart';
import 'package:management_stock/screens/products/widgets/add_product/product_basics_field.dart';
import 'package:management_stock/screens/products/widgets/add_product/product_prices_fields.dart';
import 'package:management_stock/screens/products/widgets/add_product/product_stock_field.dart';

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
    if (_formKey.currentState!.validate()) {
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        category: selectedCategory ?? '',
        image: 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
        purchasePrice: double.parse(purchasePriceController.text),
        sellPrice: double.parse(sellPriceController.text),
        pointPrice: double.tryParse(pointPriceController.text) ?? 0,
        quantity: int.parse(quantityController.text),
        barcode: barcodeController.text,
      );

      context.read<ProductCubit>().addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إضافة المنتج بنجاح"),
          backgroundColor: Colors.blueAccent,
        ),
      );

      Navigator.pop(context, true);
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
                  const SizedBox(height: 30),
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
                          const SizedBox(height: 25),

                          ProductBasicFields(
                            nameController: nameController,
                            categories: categories,
                            selectedCategory: selectedCategory,
                            onCategoryChanged: (value) =>
                                setState(() => selectedCategory = value),
                          ),

                          const SizedBox(height: 15),

                          ProductPricesFields(
                            purchasePriceController: purchasePriceController,
                            sellPriceController: sellPriceController,
                            pointPriceController: pointPriceController,
                          ),

                          const SizedBox(height: 20),

                          ProductStockFields(
                            quantityController: quantityController,
                            barcodeController: barcodeController,
                          ),

                          const SizedBox(height: 30),

                          ProductActionsRow(
                            onSave: saveProduct,
                            onBack: () => Navigator.pop(context),
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