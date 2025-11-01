import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/routing/routers.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/products/states.dart';
import 'package:management_stock/screens/products/widgets/producr_list_view.dart';
import 'package:management_stock/screens/products/widgets/product_filter.dart';
import 'package:management_stock/screens/products/widgets/product_grid_view.dart';

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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
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

          final allProducts = context.read<ProductCubit>().products;

          if (allProducts.isEmpty && state is! ProductError) {
            return const Center(
              child: Text(
                "لا توجد منتجات حالياً",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final categories = [
            'الكل',
            ...allProducts.map((e) => e.category).toSet(),
          ];

          final filteredProducts = allProducts.where((product) {
            final matchesCategory =
                selectedCategory == null ||
                selectedCategory == 'الكل' ||
                product.category == selectedCategory;
            final matchesBarcode = barcodeSearch.isEmpty ||
                product.barcode.toLowerCase().contains(
                      barcodeSearch.toLowerCase(),
                    );
            return matchesCategory && matchesBarcode;
          }).toList();

          return Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Filters
                ProductFiltersBar(
                  categories: categories,
                  selectedCategory: selectedCategory ?? 'الكل',
                  onCategoryChanged: (value) =>
                      setState(() => selectedCategory = value == 'الكل' ? null : value),
                  onBarcodeChanged: (value) =>
                      setState(() => barcodeSearch = value.trim()),
                ),

                const SizedBox(height: 20),

                // Add button
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CustomButton(
                    text: 'إضافة منتج جديد',
                    icon: Icons.add_circle_outline,
                    backgroundColor: Colors.blueAccent,
                    textColor: Colors.white,
                    onPressed: () async {
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

                // Products
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد منتجات مطابقة",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ResponsiveLayout(
                          mobile: ProductListView(products: filteredProducts),
                          tablet: ProductGridView(products: filteredProducts, crossAxisCount: 2),
                          desktop: ProductGridView(products: filteredProducts, crossAxisCount: 3),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
