
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/products/widgets/product_card.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductModel> products;
  final int crossAxisCount;
  const ProductGridView({super.key, required this.products, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Responsive.spacing(context, 20),
        mainAxisSpacing: Responsive.spacing(context, 20),
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}
