
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class InventoryTable extends StatelessWidget {
  final List<dynamic>? products;

  const InventoryTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.value(
              context: context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            )),
            decoration: const BoxDecoration(
              color: Color(0xFF353855),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'تفاصيل المخزون 📋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFF42455E)),
              headingTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 14),
              ),
              dataTextStyle: TextStyle(
                color: Colors.white70,
                fontSize: Responsive.fontSize(context, 13),
              ),
              columnSpacing: Responsive.value(
                context: context,
                mobile: 15,
                tablet: 30,
                desktop: 40,
              ),
              columns: const [
                DataColumn(label: Text('المنتج')),
                DataColumn(label: Text('الكمية')),
                DataColumn(label: Text('سعر الشراء')),
                DataColumn(label: Text('سعر البيع')),
                DataColumn(label: Text('القيمة')),
              ],
              rows: products!.map((product) {
                final quantity = product.quantity;
                final purchasePrice = product.purchasePrice;
                final sellPrice = product.sellPrice;
                final totalValue = quantity * purchasePrice;

                Color quantityColor = Colors.white70;
                if (quantity == 0) {
                  quantityColor = Colors.red;
                } else if (quantity < 10) {
                  quantityColor = Colors.orange;
                }

                return DataRow(cells: [
                  DataCell(Text(product.name)),
                  DataCell(
                    Text(
                      '$quantity',
                      style: TextStyle(
                        color: quantityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(Text(currencyFormat.format(purchasePrice))),
                  DataCell(Text(currencyFormat.format(sellPrice))),
                  DataCell(
                    Text(
                      currencyFormat.format(totalValue),
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
