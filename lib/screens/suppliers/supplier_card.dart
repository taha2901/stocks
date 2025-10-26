import 'package:flutter/material.dart';
import 'package:management_stock/core/constants/app_constants.dart';
import 'package:management_stock/models/suppliers.dart';
import 'package:management_stock/screens/suppliers/add_edit_suppliers_page.dart';

class SupplierCard extends StatefulWidget {
  final Supplier supplier;
  const SupplierCard({super.key, required this.supplier});

  @override
  State<SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends State<SupplierCard> {
  List<Supplier> suppliers = List.from(dummySuppliers);
  List<Supplier> filteredSuppliers = List.from(dummySuppliers);
  String searchQuery = '';
  String? cityFilter;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F48),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.supplier.name,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditSupplier(context, widget.supplier);
                    } else if (value == 'delete') {}
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, widget.supplier.phone),
            const SizedBox(height: 4),
            _buildInfoRow(Icons.location_on, widget.supplier.address),
            if (widget.supplier.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildInfoRow(Icons.note, widget.supplier.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _navigateToEditSupplier(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSupplierPage(
          supplier: supplier,
          onSave: (updatedSupplier) {
            setState(() {
              final index = suppliers.indexWhere((s) => s.id == supplier.id);
              if (index != -1) {
                suppliers[index] = updatedSupplier;
                _filterSuppliers();
              }
            });
          },
        ),
      ),
    );
  }

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
}
