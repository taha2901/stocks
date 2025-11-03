import 'package:flutter/material.dart';
import 'package:management_stock/models/product.dart';
import 'package:management_stock/models/sales/sales_invoice_model.dart';
import 'package:management_stock/screens/sales/widgets/product_row_widget.dart';

class ProductsTableWidget extends StatelessWidget {
  final SalesInvoiceModel invoice;
  final VoidCallback onChanged;
  final List<ProductModel> products;

  const ProductsTableWidget({
    super.key,
    required this.invoice,
    required this.onChanged,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: invoice.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = invoice.items[index];
        return ProductRowWidget(
          item: item,
          index: index,
          isMobile: MediaQuery.of(context).size.width < 700,
          invoice: invoice,
          onChanged: onChanged,
          products: products,
        );
      },
    );
  }
}
