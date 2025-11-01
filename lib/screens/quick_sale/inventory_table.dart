import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/cubits/products/cubit.dart';
import 'package:management_stock/cubits/products/states.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/screens/quick_sale/empty_state.dart';

class InventoryTable extends StatelessWidget {
  final bool isDesktop;
  final List<ProductModel> products;

  const InventoryTable({
    super.key,
    required this.isDesktop,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (products.isEmpty) {
          return const EmptyState(
            icon: Icons.inventory,
            message: "لا توجد منتجات",
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: isDesktop ? 800 : 400),
            child: Table(
              border: TableBorder.all(color: Colors.white24),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildHeaderRow(),
                ...products.map(_buildProductRow),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _buildHeaderRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFF353855)),
      children: [
        _TableHeader("المنتج"),
        _TableHeader("الباركود"),
        _TableHeader("الكمية"),
        _TableHeader("سعر البيع"),
      ],
    );
  }

  TableRow _buildProductRow(ProductModel product) {
    return TableRow(
      children: [
        _TableData(product.name),
        _TableData(product.barcode),
        _TableData("${product.quantity}"),
        _TableData("${product.sellPrice.toStringAsFixed(2)} ج.م"),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableData extends StatelessWidget {
  final String text;
  const _TableData(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
    );
  }
}
