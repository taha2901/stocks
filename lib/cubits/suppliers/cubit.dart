import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/supplier_services.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/models/suppliers.dart';


class SupplierCubit extends Cubit<SupplierState> {
  final SupplierServices _supplierServices;
  List<Supplier> _allSuppliers = [];

  SupplierCubit(this._supplierServices) : super(SupplierInitial());

  // جلب جميع الموردين
  Future<void> fetchSuppliers() async {
    try {
      emit(SupplierLoading());
      final suppliers = await _supplierServices.getSuppliers();
      _allSuppliers = suppliers;
      emit(SupplierLoaded(suppliers: suppliers));
    } catch (e) {
      emit(SupplierError('فشل في جلب الموردين: ${e.toString()}'));
    }
  }

  // الاستماع للتغييرات في الوقت الفعلي
  void listenToSuppliers() {
    _supplierServices.suppliersStream().listen(
      (suppliers) {
        _allSuppliers = suppliers;
        if (state is SupplierLoaded) {
          final currentState = state as SupplierLoaded;
          _applyFilters(
            searchQuery: currentState.searchQuery,
            cityFilter: currentState.cityFilter,
          );
        } else {
          emit(SupplierLoaded(suppliers: suppliers));
        }
      },
      onError: (error) {
        emit(SupplierError('خطأ في الاستماع للموردين: ${error.toString()}'));
      },
    );
  }

  // إضافة مورد جديد
  Future<void> addSupplier(Supplier supplier) async {
    try {
      emit(SupplierOperationLoading());
      await _supplierServices.addSupplier(supplier);
      emit(SupplierAdded(supplier));
      await fetchSuppliers(); // تحديث القائمة
    } catch (e) {
      emit(SupplierOperationError('فشل في إضافة المورد: ${e.toString()}'));
    }
  }

  // تعديل مورد
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      emit(SupplierOperationLoading());
      await _supplierServices.updateSupplier(supplier);
      emit(SupplierUpdated(supplier));
      await fetchSuppliers(); // تحديث القائمة
    } catch (e) {
      emit(SupplierOperationError('فشل في تعديل المورد: ${e.toString()}'));
    }
  }

  // حذف مورد
  Future<void> deleteSupplier(String supplierId) async {
    try {
      emit(SupplierOperationLoading());
      await _supplierServices.deleteSupplier(supplierId);
      emit(SupplierDeleted(supplierId));
      await fetchSuppliers(); // تحديث القائمة
    } catch (e) {
      emit(SupplierOperationError('فشل في حذف المورد: ${e.toString()}'));
    }
  }

  // البحث والتصفية
  void searchSuppliers(String query) {
    if (state is SupplierLoaded) {
      final currentState = state as SupplierLoaded;
      _applyFilters(
        searchQuery: query,
        cityFilter: currentState.cityFilter,
      );
    }
  }

  void filterByCity(String? city) {
    if (state is SupplierLoaded) {
      final currentState = state as SupplierLoaded;
      _applyFilters(
        searchQuery: currentState.searchQuery,
        cityFilter: city,
      );
    }
  }

  void clearFilters() {
    emit(SupplierLoaded(
      suppliers: _allSuppliers,
      searchQuery: '',
      cityFilter: null,
    ));
  }

  void _applyFilters({String searchQuery = '', String? cityFilter}) {
    final filtered = _allSuppliers.where((supplier) {
      final matchesSearch = searchQuery.isEmpty ||
          supplier.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          supplier.phone.contains(searchQuery);

      final matchesCity = cityFilter == null ||
          supplier.address.toLowerCase().contains(cityFilter.toLowerCase());

      return matchesSearch && matchesCity;
    }).toList();

    emit(SupplierLoaded(
      suppliers: _allSuppliers,
      filteredSuppliers: filtered,
      searchQuery: searchQuery,
      cityFilter: cityFilter,
    ));
  }

  // جلب الإحصائيات
  Future<void> fetchStatistics() async {
    try {
      emit(SupplierStatisticsLoading());
      
      final totalCount = await _supplierServices.getTotalSuppliersCount();
      final cityCount = await _supplierServices.getSuppliersCountByCity();
      
      int filteredCount = totalCount;
      if (state is SupplierLoaded) {
        final currentState = state as SupplierLoaded;
        filteredCount = currentState.filteredSuppliers.length;
      }

      emit(SupplierStatisticsLoaded(
        totalSuppliers: totalCount,
        filteredSuppliers: filteredCount,
        cityCount: cityCount,
      ));
    } catch (e) {
      emit(SupplierStatisticsError('فشل في جلب الإحصائيات: ${e.toString()}'));
    }
  }

  // الحصول على قائمة المدن المتاحة
  List<String> getAvailableCities() {
    return _allSuppliers
        .map((s) => s.address)
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}