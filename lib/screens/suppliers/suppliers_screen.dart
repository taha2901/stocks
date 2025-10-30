import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/cubits/suppliers/cubit.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/add_edit_suppliers_page.dart';
import 'package:management_stock/screens/suppliers/header_of_suppliers.dart';
import 'package:management_stock/screens/suppliers/supplier_card.dart';

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
            _buildFilterBar(context),
            SizedBox(height: Responsive.spacing(context, 24)),
            Expanded(child: _buildSuppliersList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return BlocBuilder<SupplierCubit, SupplierState>(
      builder: (context, state) {
        return Responsive.isMobile(context)
            ? Column(
                children: [
                  _buildSearchField(context),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _executeButton(context)),
                      const SizedBox(width: 12),
                      Expanded(child: _cancelButton(context)),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: _buildSearchField(context)),
                  const SizedBox(width: 12),
                  _executeButton(context),
                  const SizedBox(width: 12),
                  _cancelButton(context),
                ],
              );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return CustomInputField(
      controller: _searchController,
      label: "بحث باسم المورد",
      hint: "اكتب اسم المورد للبحث...",
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: (value) {
        // يمكن تطبيق البحث مباشرة أثناء الكتابة
        // context.read<SupplierCubit>().searchSuppliers(value);
      },
    );
  }

  Widget _executeButton(BuildContext context) {
    return CustomButton(
      text: "تطبيق",
      onPressed: () {
        context.read<SupplierCubit>().searchSuppliers(_searchController.text);
      },
    );
  }

  Widget _cancelButton(BuildContext context) {
    return CustomButton(
      text: "إلغاء",
      onPressed: () {
        _searchController.clear();
        context.read<SupplierCubit>().clearFilters();
      },
    );
  }

  Widget _buildSuppliersList(BuildContext context) {
    return BlocConsumer<SupplierCubit, SupplierState>(
      listener: (context, state) {
        if (state is SupplierOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is SupplierAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة المورد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SupplierUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل المورد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SupplierDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المورد بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SupplierLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SupplierError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: "إعادة المحاولة",
                  onPressed: () {
                    context.read<SupplierCubit>().fetchSuppliers();
                  },
                ),
              ],
            ),
          );
        }

        if (state is SupplierLoaded) {
          final suppliers = state.filteredSuppliers;

          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'لا توجد نتائج للبحث'
                        : 'لا توجد موردين حالياً',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            );
          }

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
                onEdit: () => _navigateToEditSupplier(context, supplier),
                onDelete: () => _showDeleteDialog(context, supplier),
              );
            },
          );
        }

        return const Center(child: Text('حالة غير معروفة'));
      },
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
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف المورد "${supplier.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                context.read<SupplierCubit>().deleteSupplier(supplier.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
