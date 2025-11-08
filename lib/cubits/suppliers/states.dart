import 'package:management_stock/models/suppliers.dart';

abstract class SupplierState {}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;
  final List<Supplier> filteredSuppliers;
  final String searchQuery;
  final String? cityFilter;

  SupplierLoaded({
    required this.suppliers,
    List<Supplier>? filteredSuppliers,
    this.searchQuery = '',
    this.cityFilter,
  }) : filteredSuppliers = filteredSuppliers ?? suppliers;

  SupplierLoaded copyWith({
    List<Supplier>? suppliers,
    List<Supplier>? filteredSuppliers,
    String? searchQuery,
    String? cityFilter,
    bool clearCityFilter = false,
  }) {
    return SupplierLoaded(
      suppliers: suppliers ?? this.suppliers,
      filteredSuppliers: filteredSuppliers ?? this.filteredSuppliers,
      searchQuery: searchQuery ?? this.searchQuery,
      cityFilter: clearCityFilter ? null : (cityFilter ?? this.cityFilter),
    );
  }
}

class SupplierError extends SupplierState {
  final String message;
  SupplierError(this.message);
}
