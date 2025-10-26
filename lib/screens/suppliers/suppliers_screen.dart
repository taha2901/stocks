import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/core/widgets/custom_button.dart';
import 'package:management_stock/core/widgets/custom_text_field.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/build_header.dart';
import 'package:management_stock/screens/suppliers/supplier_card.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  List<Supplier> suppliers = List.from(dummySuppliers);
  List<Supplier> filteredSuppliers = List.from(dummySuppliers);
  String searchQuery = '';
  String? cityFilter;

  void _filterSuppliers() {
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        final matchesSearch =
            supplier.name.contains(searchQuery) ||
            supplier.phone.contains(searchQuery);
        final matchesCity =
            cityFilter == null || supplier.address.contains(cityFilter!);
        return matchesSearch && matchesCity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: Responsive.pagePadding(context),
          child: Column(
            children: [
              BuildHeader(),
              SizedBox(height: Responsive.spacing(context, 24)),
              _buildFilterBar(context),
              SizedBox(height: Responsive.spacing(context, 24)),
              Expanded(child: _buildSuppliersList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Responsive.isMobile(context)
        ? Column(
            children: [
              _buildSearchField(context),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(child: _excuteButton()),
                  const SizedBox(width: 12),
                  Expanded(child: _cancelButton()),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(flex: 3, child: _buildSearchField(context)),
              const SizedBox(width: 12),
              const SizedBox(width: 12),
              _excuteButton(),
              const SizedBox(width: 12),
              _cancelButton(),
            ],
          );
  }

  CustomButton _excuteButton() =>
      CustomButton(text: "تطبيق", onPressed: _filterSuppliers);

  CustomButton _cancelButton() {
    return CustomButton(
      text: "اغلاق",
      onPressed: () {
        setState(() {
          searchQuery = '';
          cityFilter = null;
          filteredSuppliers = List.from(suppliers);
        });
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return CustomInputField(
      controller: TextEditingController(text: searchQuery),
      label: "بحث باسم العميل",
      hint: "اكتب اسم العميل للبحث...",
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  Widget _buildSuppliersList(BuildContext context) {
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
      itemCount: filteredSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = filteredSuppliers[index];
        return SupplierCard(supplier: supplier);
      },
    );
  }
}
