// تقرير الأرباح
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/report/widgets/states_grid.dart';
import 'package:management_stock/screens/report/widgets/top_profit_product_table.dart';

class ProfitReportWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfitReportWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    return Column(
      children: [
        StatsGrid(
          stats: [
            {
              'title': 'إجمالي الإيرادات',
              'value': currencyFormat.format(data['totalRevenue'] ?? 0),
              'icon': Icons.trending_up,
              'color': Colors.green,
            },
            {
              'title': 'إجمالي التكاليف',
              'value': currencyFormat.format(data['totalCost'] ?? 0),
              'icon': Icons.trending_down,
              'color': Colors.red,
            },
            {
              'title': 'صافي الربح',
              'value': currencyFormat.format(data['grossProfit'] ?? 0),
              'icon': Icons.attach_money,
              'color': Colors.blue,
            },
            {
              'title': 'هامش الربح',
              'value': '${(data['profitMargin'] ?? 0).toStringAsFixed(1)}%',
              'icon': Icons.percent,
              'color': Colors.purple,
            },
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 20)),
        TopProfitProductsTable(products: data['topProfitProducts']),
      ],
    );
  }
}
