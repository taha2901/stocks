import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/products/widgets/product_action.dart';
import 'package:management_stock/screens/products/widgets/product_image.dart';
import 'package:management_stock/screens/products/widgets/product_info_column.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

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
          ProductImage(url: product.image),
          const SizedBox(width: 16),
          Expanded(
            child: ProductInfoColumn(product: product),
          ),
          ProductActions(
            onEdit: () {
              // Navigator.pushNamed(context, Routers.editProductRoute, arguments: product);
            },
            onDelete: () => _showDeleteConfirmation(context, product),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2F48),
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.white)),
        content: Text("هل أنت متأكد من حذف ${product.name}؟", style: const TextStyle(color: Colors.white70)),
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
      ),
    );
  }
}
