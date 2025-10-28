import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class TopProductsTable extends StatelessWidget {
  final List<dynamic>? products;
  final Map<String, dynamic>? revenue;

  const TopProductsTable({super.key, 
    required this.products,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) {
      // return EmptyDataCard(message: 'لا توجد مبيعات في هذه الفترة');
      return Text('no data');
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
                  'أكثر المنتجات مبيعاً 🏆',
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
                mobile: 20,
                tablet: 40,
                desktop: 60,
              ),
              columns: const [
                DataColumn(label: Text('المنتج')),
                DataColumn(label: Text('الكمية')),
                DataColumn(label: Text('الإيرادات')),
              ],
              rows: products!.take(10).map((product) {
                final productName = product.key;
                final quantity = product.value;
                final productRevenue = revenue?[productName] ?? 0;

                return DataRow(cells: [
                  DataCell(Text(productName)),
                  DataCell(Text('$quantity', textAlign: TextAlign.center)),
                  DataCell(
                    Text(
                      currencyFormat.format(productRevenue),
                      style: const TextStyle(color: Colors.green),
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
