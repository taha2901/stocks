import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/products/states.dart';
import 'package:management_stock/models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? selectedCategory;
  String barcodeSearch = '';

  @override
  void initState() {
    super.initState();
    // 🔥 تحميل المنتجات عند فتح الشاشة
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E2030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2F48),
        elevation: 4,
        title: const Text(
          "إدارة المنتجات",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          // 🔥 عرض رسالة عند الحذف الناجح
          if (state is ProductLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ تم التحديث بنجاح"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔥 استخدام البيانات من Cubit
          final allProducts = context.read<ProductCubit>().products;

          if (allProducts.isEmpty && state is! ProductError) {
            return const Center(
              child: Text(
                "لا توجد منتجات حالياً",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final categories = ['الكل', ...allProducts.map((e) => e.category).toSet()];

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

          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🔹 فلترة المنتجات
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomInputField(
                        label: "الفئة",
                        items: categories,
                        selectedValue: selectedCategory,
                        onItemSelected: (value) =>
                            setState(() => selectedCategory = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: CustomInputField(
                        label: "بحث بالباركود",
                        hint: "أدخل الباركود أو جزء منه",
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

                // 🔹 زر إضافة منتج
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CustomButton(
                    text: 'إضافة منتج جديد',
                    icon: Icons.add_circle_outline,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    onPressed: () async {
                      // 🔥 تحديث القائمة بعد العودة من شاشة الإضافة
                      final result = await Navigator.pushNamed(
                        context,
                        Routers.addProductRoute,
                      );
                      if (result == true && mounted) {
                        context.read<ProductCubit>().fetchProducts();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 عرض المنتجات
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد منتجات مطابقة",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ResponsiveLayout(
                          mobile: _buildProductList(context, filteredProducts),
                          tablet: _buildProductGrid(
                            context,
                            filteredProducts,
                            2,
                          ),
                          desktop: _buildProductGrid(
                            context,
                            filteredProducts,
                            3,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList(BuildContext context, List<ProductModel> products) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }

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
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[700],
                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // 🔹 بيانات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _infoChip("📦 الفئة", product.category),
                    _infoChip("💰 السعر", "${product.sellPrice} ج.م"),
                    _infoChip("🔢 الكمية", "${product.quantity}"),
                    _infoChip("🏷️ الباركود", product.barcode),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 أزرار التعديل والحذف
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                onPressed: () {
                  // TODO: Navigate to edit screen
                  // Navigator.pushNamed(
                  //   context,
                  //   Routers.editProductRoute,
                  //   arguments: product,
                  // );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  // 🔥 حذف المنتج من Firebase
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2F48),
          title: const Text(
            "تأكيد الحذف",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "هل أنت متأكد من حذف ${product.name}؟",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<ProductCubit>().deleteProduct(product.id);
              },
              child: const Text("حذف", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _infoChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$title: $value",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}