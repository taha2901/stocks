import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/suppliers/supplier_services.dart';
import 'package:management_stock/cubits/suppliers/states.dart';
import 'package:management_stock/models/suppliers.dart';

class SupplierCubit extends Cubit<SupplierState> {
  final SupplierServices _supplierServices;

  List<Supplier> _allSuppliers = [];

  SupplierCubit(this._supplierServices) : super(SupplierInitial());

  // ═══════════════════════════════════════
  // 📥 جيب الموردين
  // ═══════════════════════════════════════
  Future<void> fetchSuppliers() async {
    if (_allSuppliers.isNotEmpty) return; // ✅ منع double fetch

    try {
      emit(SupplierLoading());

      _allSuppliers = await _supplierServices.getSuppliers();

      emit(SupplierLoaded(suppliers: _allSuppliers));
    } catch (e) {
      emit(SupplierError('فشل في جلب الموردين: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // ➕ إضافة مورد
  // ═══════════════════════════════════════
  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _supplierServices.addSupplier(supplier);

      _allSuppliers.insert(0, supplier);
      _applyFilters();
    } catch (e) {
      emit(SupplierError('فشل في إضافة المورد: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // ✏️ تعديل مورد
  // ═══════════════════════════════════════
  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _supplierServices.updateSupplier(supplier);

      final index = _allSuppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _allSuppliers[index] = supplier;
      }
      _applyFilters();
    } catch (e) {
      emit(SupplierError('فشل في تعديل المورد: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // 🗑️ حذف مورد
  // ═══════════════════════════════════════
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _supplierServices.deleteSupplier(supplierId);

      _allSuppliers.removeWhere((s) => s.id == supplierId);
      _applyFilters();
    } catch (e) {
      emit(SupplierError('فشل في حذف المورد: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // 🔍 بحث
  // ═══════════════════════════════════════
  void searchSuppliers(String query) {
    if (state is SupplierLoaded) {
      final current = state as SupplierLoaded;
      _applyFilters(query: query, city: current.cityFilter);
    }
  }

  // ═══════════════════════════════════════
  // 🏙️ فلترة حسب المدينة
  // ═══════════════════════════════════════
  void filterByCity(String? city) {
    if (state is SupplierLoaded) {
      final current = state as SupplierLoaded;
      _applyFilters(query: current.searchQuery, city: city);
    }
  }

  // ═══════════════════════════════════════
  // 🧹 إزالة الفلاتر
  // ═══════════════════════════════════════
  void clearFilters() {
    emit(SupplierLoaded(suppliers: _allSuppliers));
  }

  // ═══════════════════════════════════════
  // ⚙️ تطبيق الفلاتر (محلي)
  // ═══════════════════════════════════════
  void _applyFilters({String query = '', String? city}) {
    final filtered = _allSuppliers.where((supplier) {
      final matchesSearch = query.isEmpty ||
          supplier.name.toLowerCase().contains(query.toLowerCase()) ||
          supplier.phone.contains(query);

      final matchesCity = city == null ||
          supplier.address.toLowerCase().contains(city.toLowerCase());

      return matchesSearch && matchesCity;
    }).toList();

    emit(SupplierLoaded(
      suppliers: _allSuppliers,
      filteredSuppliers: filtered,
      searchQuery: query,
      cityFilter: city,
    ));
  }

  // ═══════════════════════════════════════
  // 📍 قائمة المدن
  // ═══════════════════════════════════════
  List<String> getAvailableCities() {
    return _allSuppliers
        .map((s) => s.address)
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }


   // ═══════════════════════════════════════
  // 📊 حساب الإحصائيات (محلي - 0 Reads!)
  // ═══════════════════════════════════════
  Map<String, dynamic> getStatistics() {
    final totalCount = _allSuppliers.length;
    final cityCount = <String, int>{};
    
    for (var supplier in _allSuppliers) {
      if (supplier.address.isNotEmpty) {
        cityCount[supplier.address] = 
          (cityCount[supplier.address] ?? 0) + 1;
      }
    }
    
    return {
      'totalSuppliers': totalCount,
      'citiesCount': cityCount.length,
      'cityDistribution': cityCount,
    };
  }
}
