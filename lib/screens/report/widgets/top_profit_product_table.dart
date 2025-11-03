import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';

class TopProfitProductsTable extends StatelessWidget {
  final List<dynamic>? products;

  const TopProfitProductsTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) {
      return _EmptyDataCard(message: 'لا توجد أرباح في هذه الفترة');
    }

    final currencyFormat = NumberFormat.currency(
      symbol: 'ج.م',
      decimalDigits: 2,
    );

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
            padding: EdgeInsets.all(
              Responsive.value(
                context: context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
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
                  'أكثر المنتجات ربحاً 💎',
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
                mobile: 30,
                tablet: 60,
                desktop: 100,
              ),
              columns: const [
                DataColumn(label: Text('المنتج')),
                DataColumn(label: Text('الربح')),
              ],
              rows: products!.take(10).map((product) {
                final productName = product.key;
                final profit = product.value;

                return DataRow(
                  cells: [
                    DataCell(Text(productName)),
                    DataCell(
                      Text(
                        currencyFormat.format(profit),
                        style: TextStyle(
                          color: profit > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Empty Data Card ====================
class _EmptyDataCard extends StatelessWidget {
  final String message;

  const _EmptyDataCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        Responsive.value(context: context, mobile: 20, tablet: 30, desktop: 40),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white70,
            fontSize: Responsive.fontSize(context, 16),
          ),
        ),
      ),
    );
  }
}
