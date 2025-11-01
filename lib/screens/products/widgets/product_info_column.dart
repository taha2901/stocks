
import 'package:flutter/material.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/products/widgets/product_info_chip.dart';

class ProductInfoColumn extends StatelessWidget {
  final ProductModel product;
  const ProductInfoColumn({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            const ProductInfoChip(title: "📦 الفئة"),
            ProductInfoChip(value: product.category),
            const ProductInfoChip(title: "💰 السعر"),
            ProductInfoChip(value: "${product.sellPrice} ج.م"),
            const ProductInfoChip(title: "🔢 الكمية"),
            ProductInfoChip(value: "${product.quantity}"),
            const ProductInfoChip(title: "🏷️ الباركود"),
            ProductInfoChip(value: product.barcode),
          ],
        ),
      ],
    );
  }
}
