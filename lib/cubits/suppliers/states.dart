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

// حالات العمليات
class SupplierOperationLoading extends SupplierState {}

class SupplierAdded extends SupplierState {
  final Supplier supplier;

  SupplierAdded(this.supplier);
}

class SupplierUpdated extends SupplierState {
  final Supplier supplier;

  SupplierUpdated(this.supplier);
}

class SupplierDeleted extends SupplierState {
  final String supplierId;

  SupplierDeleted(this.supplierId);
}

class SupplierOperationError extends SupplierState {
  final String message;

  SupplierOperationError(this.message);
}

// حالات الإحصائيات
class SupplierStatisticsLoading extends SupplierState {}

class SupplierStatisticsLoaded extends SupplierState {
  final int totalSuppliers;
  final int filteredSuppliers;
  final Map<String, int> cityCount;

  SupplierStatisticsLoaded({
    required this.totalSuppliers,
    required this.filteredSuppliers,
    required this.cityCount,
  });
}

class SupplierStatisticsError extends SupplierState {
  final String message;

  SupplierStatisticsError(this.message);
}