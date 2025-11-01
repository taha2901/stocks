import 'package:flutter/material.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:management_stock/screens/suppliers/widgets/statistics/statistics_content.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/statistics_error.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupplierCubit>().fetchStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text('إحصائيات الموردين', style: TextStyle(color: Colors.white)),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              context.read<SupplierCubit>().fetchSuppliers();
            },
          ),
        ),
        body: BlocBuilder<SupplierCubit, SupplierState>(
          builder: (context, state) {
            // ✅ Loading
            if (state is SupplierStatisticsLoading) {
              return const Center(child:  CircularProgressIndicator(),);
            }

            // ✅ Error
            if (state is SupplierStatisticsError) {
              return StatisticsErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<SupplierCubit>().fetchStatistics();
                },
              );
            }

            // ✅ Loaded
            if (state is SupplierStatisticsLoaded) {
              return StatisticsContent(
                totalSuppliers: state.totalSuppliers,
                filteredSuppliers: state.filteredSuppliers,
                cityCount: state.cityCount,
              );
            }
            return const   Center(child:  CircularProgressIndicator(),);
          },
        ),
      ),
    );
  }
}
