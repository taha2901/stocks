import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategory;
  String barcodeSearch = '';
  final List<ProductModel> allProducts = dummyProducts;

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    // 🔹 استخراج الفئات بدون تكرار
    final List<String> categories = allProducts
        .map((e) => e.category.toString())
        .toSet()
        .toList();

    // 🔹 فلترة المنتجات بناءً على الفئة والباركود
    final filteredProducts = allProducts.where((product) {
      final matchesCategory =
          selectedCategory == null ||
          selectedCategory == 'الكل' ||
          product.category == selectedCategory;
      final matchesBarcode =
          barcodeSearch.isEmpty ||
          product.barcode.toLowerCase().contains(barcodeSearch.toLowerCase());
      return matchesCategory && matchesBarcode;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 4,
        title: Text(
          "إدارة المنتجات",
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ✅ بحث بالفئة والباركود (باستخدام CustomInputField)
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: "الفئة",
                    items: ['الكل', ...categories],
                    selectedValue: selectedCategory,
                    onItemSelected: (value) =>
                        setState(() => selectedCategory = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInputField(
                    label: "بحث بالباركود",
                    hint: "اكتب أو امسح الباركود",
                    prefixIcon: const Icon(
                      Icons.qr_code,
                      color: Colors.white70,
                    ),
                    onChanged: (value) =>
                        setState(() => barcodeSearch = value.trim()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ زر إضافة منتج جديد
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CustomButton(
                text: 'إضافة منتج جديد',
                icon: Icons.add,
                backgroundColor: Colors.blueAccent,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, Routers.addProductRoute);
                },
              ),
            ),

            const SizedBox(height: 30),

            // ✅ عرض المنتجات
            Expanded(
              child: ResponsiveLayout(
                mobile: _buildProductList(context, filteredProducts),
                tablet: _buildProductGrid(context, filteredProducts, 2),
                desktop: _buildProductGrid(context, filteredProducts, 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 عرض المنتجات في شكل List (للموبايل)
  Widget _buildProductList(BuildContext context, List<ProductModel> products) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }

  // 🔹 عرض المنتجات في شكل Grid (للتابلت والويب)
  Widget _buildProductGrid(
    BuildContext context,
    List<ProductModel> products,
    int crossAxisCount,
  ) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Responsive.spacing(context, 20),
        mainAxisSpacing: Responsive.spacing(context, 20),
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

// 🔹 كارد عرض المنتج
class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "الفئة: ${product.category}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
                Text(
                  "السعر: ${product.sellPrice} ج.م",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
                Text(
                  "الكمية: ${product.quantity}",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.fontSize(context, 14),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}