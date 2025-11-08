import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/widgets/suppliers_empty_widget.dart';
import 'package:management_stock/screens/suppliers/widgets/suppliers_error_widget.dart';
import 'package:management_stock/screens/suppliers/widgets/suppliers_grid_view.dart';

class SuppliersListBuilder extends StatelessWidget {
  final Function(BuildContext, Supplier) onEdit;
  final Function(BuildContext, Supplier) onDelete;

  const SuppliersListBuilder({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupplierCubit, SupplierState>(
      listener: (context, state) {
        // ✅ فقط للـ Toast والـ Navigation
        if (state is SupplierLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم العملية بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else if (state is SupplierError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SupplierCubit, SupplierState>(
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (state is SupplierError) {
            return SupplierErrorWidget(
              message: state.message,
              onRetry: () => context.read<SupplierCubit>().fetchSuppliers(),
            );
          }

          if (state is SupplierLoaded) {
            final suppliers = state.filteredSuppliers;

            if (suppliers.isEmpty) {
              return SupplierEmptyWidget(
                hasSearch: state.searchQuery.isNotEmpty,
              );
            }

            return SupplierGridView(
              suppliers: suppliers,
              onEdit: (supplier) => onEdit(context, supplier),
              onDelete: (supplier) => onDelete(context, supplier),
            );
          }

          return const Center(child: Text('حالة غير معروفة'));
        },
      ),
    );
  }
}
