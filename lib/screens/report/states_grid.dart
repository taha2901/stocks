// Grid الإحصائيات (Responsive)
import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/report/state_card.dart';

class StatsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.value(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: Responsive.spacing(context, 12),
        mainAxisSpacing: Responsive.spacing(context, 12),
        childAspectRatio: Responsive.value(
          context: context,
          mobile: 1.3,
          tablet: 1.4,
          desktop: 1.5,
        ),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return StatCard(
          title: stat['title'],
          value: stat['value'],
          icon: stat['icon'],
          color: stat['color'],
        );
      },
    );
  }
}
