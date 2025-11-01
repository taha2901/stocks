
// تقرير المخزون
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/report/category_breakdown_card.dart';
import 'package:management_stock/screens/report/inventory_table.dart';
import 'package:management_stock/screens/report/states_grid.dart';

class InventoryReportWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const InventoryReportWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ج.م', decimalDigits: 2);

    return Column(
      children: [
        StatsGrid(
          stats: [
            {
              'title': 'إجمالي المنتجات',
              'value': '${data['totalProducts'] ?? 0}',
              'icon': Icons.inventory,
              'color': Colors.blue,
            },
            {
              'title': 'قيمة المخزون',
              'value': currencyFormat.format(data['totalInventoryValue'] ?? 0),
              'icon': Icons.account_balance_wallet,
              'color': Colors.green,
            },
            {
              'title': 'منتجات قاربت النفاذ',
              'value': '${data['lowStockProducts'] ?? 0}',
              'icon': Icons.warning,
              'color': Colors.orange,
            },
            {
              'title': 'منتجات نفذت',
              'value': '${data['outOfStockProducts'] ?? 0}',
              'icon': Icons.error,
              'color': Colors.red,
            },
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 20)),
        CategoryBreakdownCard(
          categoryCount: data['categoryCount'],
          categoryValue: data['categoryValue'],
        ),
        SizedBox(height: Responsive.spacing(context, 20)),
        InventoryTable(products: data['products'],isDesktop:  true,),
      ],
    );
  }
}
