import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/widgets/supplier_card.dart';

class SupplierGridView extends StatelessWidget {
  final List<Supplier> suppliers;
  final Function(Supplier) onEdit;
  final Function(Supplier) onDelete;

  const SupplierGridView({
    super.key,
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = Responsive.value(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: Responsive.isMobile(context) ? 2.5 : 2.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return SupplierCard(
          supplier: supplier,
          onEdit: () => onEdit(supplier),
          onDelete: () => onDelete(supplier),
        );
      },
    );
  }
}
