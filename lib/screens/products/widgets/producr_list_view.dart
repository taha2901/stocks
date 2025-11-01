import 'package:flutter/material.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/products/widgets/product_card.dart';

class ProductListView extends StatelessWidget {
  final List<ProductModel> products;
  const ProductListView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}
