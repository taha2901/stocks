import 'package:flutter/material.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/state_card.dart';

class TopBottomCitiesSection extends StatelessWidget {
  final List<MapEntry<String, int>> sortedCities;

  const TopBottomCitiesSection({
    super.key,
    required this.sortedCities,
  });

  @override
  Widget build(BuildContext context) {
    if (sortedCities.isEmpty) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 32),
        StateCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          label: 'أكثر مدينة بها موردين',
          value: '${sortedCities.first.key} (${sortedCities.first.value})',
        ),
        const SizedBox(height: 16),
        StateCard(
          icon: Icons.trending_down,
          iconColor: Colors.red,
          label: 'أقل مدينة بها موردين',
          value: '${sortedCities.last.key} (${sortedCities.last.value})',
        ),
      ],
    );
  }
}
