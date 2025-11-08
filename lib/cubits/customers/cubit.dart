import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/customers/customer_services.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerServices _customerServices;

  // ✅ Local cache
  List<Customer> _allCustomers = [];
  bool _isLoading = false;

  CustomerCubit(this._customerServices) : super(CustomerInitial());

  // ═══════════════════════════════════════
  // 📥 فيتش مرة واحدة بس
  // ═══════════════════════════════════════
  Future<void> fetchCustomers() async {
    if (_isLoading || _allCustomers.isNotEmpty) return;

    try {
      _isLoading = true;
      emit(CustomerLoading());

      _allCustomers = await _customerServices.getCustomers();

      // ✅ استخدم `customers` مش `allCustomers`
      emit(CustomerLoaded(customers: _allCustomers));
      _isLoading = false;
    } catch (e) {
      emit(CustomerError('فشل في جلب العملاء: ${e.toString()}'));
      _isLoading = false;
    }
  }

  // ═══════════════════════════════════════
  // ➕ إضافة عميل (بدون إعادة جلب!)
  // ═══════════════════════════════════════
  Future<void> addCustomer(Customer customer) async {
    try {
      await _customerServices.addCustomer(customer);
      _allCustomers.insert(0, customer);
      _applyFilters();
    } catch (e) {
      emit(CustomerError('فشل في إضافة العميل: ${e.toString()}'));
    }
  }
  // ═══════════════════════════════════════
  // ✏️ تعديل عميل
  // ═══════════════════════════════════════
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerServices.updateCustomer(customer);

      // ✅ عدّله محلياً بس
      final index = _allCustomers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _allCustomers[index] = customer;
      }
      _applyFilters(); // ✅ حدّث الفلترة
    } catch (e) {
      emit(CustomerError('فشل في تعديل العميل: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // 🗑️ حذف عميل
  // ═══════════════════════════════════════
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _customerServices.deleteCustomer(customerId);

      // ✅ احذفه محلياً بس
      _allCustomers.removeWhere((c) => c.id == customerId);
      _applyFilters(); // ✅ حدّث الفلترة
    } catch (e) {
      emit(CustomerError('فشل في حذف العميل: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════
  // 🔍 بحث
  // ═══════════════════════════════════════
   void searchCustomers(String query) {
    if (state is CustomerLoaded) {
      final current = state as CustomerLoaded;
      _applyFilters(query: query, city: current.cityFilter);
    }
  }

  // ═══════════════════════════════════════
  // 🏙️ فلترة حسب المدينة
  // ═══════════════════════════════════════
  void filterByCity(String? city) {
    if (state is CustomerLoaded) {
      final current = state as CustomerLoaded;
      _applyFilters(query: current.searchQuery, city: city);
    }
  }

  // ═══════════════════════════════════════
  // 🧹 إزالة الفلاتر
  // ═══════════════════════════════════════
  void clearFilters() {
    // ✅ استخدم `customers` مش `allCustomers`
    emit(CustomerLoaded(customers: _allCustomers));
  }

  // ═══════════════════════════════════════
  // ⚙️ تطبيق الفلاتر (الدالة الرئيسية)
  // ═══════════════════════════════════════
   void _applyFilters({String query = '', String? city}) {
    final filtered = _allCustomers.where((customer) {
      final matchesSearch = query.isEmpty ||
          customer.name.toLowerCase().contains(query.toLowerCase()) ||
          customer.phone.contains(query);
      
      final matchesCity = city == null ||
          customer.address.toLowerCase().contains(city.toLowerCase());
      
      return matchesSearch && matchesCity;
    }).toList();

    // ✅ استخدم `customers` مش `allCustomers`
    emit(CustomerLoaded(
      customers: _allCustomers,
      filteredCustomers: filtered,
      searchQuery: query,
      cityFilter: city,
    ));
  }
  // ═══════════════════════════════════════
  // 📍 قائمة المدن
  // ═══════════════════════════════════════
  List<String> getAvailableCities() {
    return _allCustomers
        .map((c) => c.address)
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}
