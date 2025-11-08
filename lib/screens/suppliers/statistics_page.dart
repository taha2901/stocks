import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/statistics_content.dart';
import 'package:management_stock/screens/suppliers/widgets/statistics/statistics_error.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SupplierCubit, SupplierState>(
          builder: (context, state) {
            // ✅ لو ما حملنا الموردين بعد
            if (state is SupplierInitial) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('جاري تحميل البيانات...'),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SupplierCubit>().fetchSuppliers();
                      },
                      child: const Text('حمّل البيانات'),
                    ),
                  ],
                ),
              );
            }

            // ✅ لو جاري التحميل
            if (state is SupplierLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // ✅ لو في خطأ
            if (state is SupplierError) {
              return StatisticsErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<SupplierCubit>().fetchSuppliers();
                },
              );
            }

            // ✅ الإحصائيات من الـ Local Data (0 Reads!)
            if (state is SupplierLoaded) {
              final stats = context.read<SupplierCubit>().getStatistics();
              
              return StatisticsContent(
                totalSuppliers: stats['totalSuppliers'],
                filteredSuppliers: state.filteredSuppliers.length,
                cityCount: stats['cityDistribution'],
              );
            }

            return const Center(
              child: Text('حالة غير معروفة'),
            );
          },
        ),
      ),
    );
  }
}
