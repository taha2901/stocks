
// تقرير المبيعات
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/report/sales_division_card.dart';
import 'package:management_stock/screens/report/states_grid.dart';
import 'package:management_stock/screens/report/top_product_table.dart';

class SalesReportWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const SalesReportWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Column(
      children: [
        StatsGrid(
          stats: [
            {
              'title': 'إجمالي المبيعات',
              'value': currencyFormat.format(data['totalSales'] ?? 0),
              'icon': Icons.attach_money,
              'color': Colors.green,
            },
            {
              'title': 'عدد الفواتير',
              'value': '${data['totalTransactions'] ?? 0}',
              'icon': Icons.receipt_long,
              'color': Colors.blue,
            },
            {
              'title': 'متوسط الفاتورة',
              'value': currencyFormat.format(data['averageOrderValue'] ?? 0),
              'icon': Icons.trending_up,
              'color': Colors.orange,
            },
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 20)),
        SalesDivisionCard(data: data),
        SizedBox(height: Responsive.spacing(context, 20)),
        TopProductsTable(
          products: data['topProducts'],
          revenue: data['productRevenue'],
        ),
      ],
    );
  }
}
