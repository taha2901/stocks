import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/add_edit_suppliers_page.dart';
import 'package:management_stock/screens/suppliers/widgets/header_of_suppliers.dart';
import 'package:management_stock/screens/suppliers/widgets/supplier_search_bar.dart';
import 'package:management_stock/screens/suppliers/widgets/suppliers_deleting_dialouge.dart';
import 'package:management_stock/screens/suppliers/widgets/suppliers_list_builder.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قائمة الموردين',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: Responsive.pagePadding(context),
        child: Column(
          children: [
            const ResponsiveHeader(),
            SizedBox(height: Responsive.spacing(context, 24)),

            // ✅ Search Bar
            SupplierSearchBar(
              controller: _searchController,
              onSearch: (value) {
                context.read<SupplierCubit>().searchSuppliers(value);
              },
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // ✅ Suppliers List
            Expanded(
              child: SuppliersListBuilder(
                onEdit: _navigateToEditSupplier,
                onDelete: _showDeleteDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditSupplier(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSupplierPage(
          supplier: supplier,
          onSave: (updatedSupplier) {
            context.read<SupplierCubit>().updateSupplier(updatedSupplier);
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => SupplierDeleteDialog(
        supplier: supplier,
        onConfirm: () {
          context.read<SupplierCubit>().deleteSupplier(supplier.id);
        },
      ),
    );
  }
}
