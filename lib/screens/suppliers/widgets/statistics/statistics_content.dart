import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/cities_distribution_section.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/general_statistics.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/top_bottom_cities_section.dart';

class StatisticsContent extends StatelessWidget {
  final int totalSuppliers;
  final int filteredSuppliers;
  final Map<String, int> cityCount;

  const StatisticsContent({
    super.key,
    required this.totalSuppliers,
    required this.filteredSuppliers,
    required this.cityCount,
  });

  @override
  Widget build(BuildContext context) {
    final sortedCities = cityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: Responsive.pagePadding(context),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Responsive.value(
              context: context,
              mobile: double.infinity,
              tablet: 700,
              desktop: 900,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GeneralStatisticsSection(
                totalSuppliers: totalSuppliers,
                filteredSuppliers: filteredSuppliers,
                citiesCount: cityCount.length,
              ),
              CitiesDistributionSection(
                sortedCities: sortedCities,
              ),
              TopBottomCitiesSection(
                sortedCities: sortedCities,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
