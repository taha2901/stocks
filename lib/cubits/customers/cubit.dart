import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:management_stock/core/services/Customer_services.dart';
import 'package:management_stock/cubits/Customers/states.dart';
import 'package:management_stock/models/customer.dart';


class CustomerCubit extends Cubit<CustomerState> {
  final CustomerServices _customerServices; 
  List<Customer> _allCustomers = [];

  CustomerCubit(this._customerServices) : super(CustomerInitial());

  // جلب جميع الموردين
  Future<void> fetchCustomers() async {
    try {
      emit(CustomerLoading());
      final customers = await _customerServices.getCustomers();
      _allCustomers = customers;
      emit(CustomerLoaded(customers: customers));
    } catch (e) {
      emit(CustomerError('فشل في جلب الموردين: ${e.toString()}'));
    }
  }

  // الاستماع للتغييرات في الوقت الفعلي
  void listenToCustomers() {
    _customerServices.customersStream().listen(
      (customers) {
        _allCustomers = customers;
        if (state is CustomerLoaded) {
          final currentState = state as CustomerLoaded;
          _applyFilters(
            searchQuery: currentState.searchQuery,
            cityFilter: currentState.cityFilter,
          );
        } else {
          emit(CustomerLoaded(customers: customers));
        }
      },
      onError: (error) {
        emit(CustomerError('خطأ في الاستماع للموردين: ${error.toString()}'));
      },
    );
  }

  // إضافة مورد جديد
  Future<void> addCustomer(Customer customer) async {
    try {
      emit(CustomerOperationLoading());
      await _customerServices.addCustomer(customer);
      emit(CustomerAdded(customer));
      await fetchCustomers(); // تحديث القائمة
    } catch (e) {
      emit(CustomerOperationError('فشل في إضافة المورد: ${e.toString()}'));
    }
  }

  // تعديل مورد
  Future<void> updateCustomer(Customer customer) async {
    try {
      emit(CustomerOperationLoading());
      await _customerServices.updateCustomer(customer);
      emit(CustomerUpdated(customer));
      await fetchCustomers(); // تحديث القائمة
    } catch (e) {
      emit(CustomerOperationError('فشل في تعديل المورد: ${e.toString()}'));
    }
  }

  // حذف مورد
  Future<void> deleteCustomer(String customerId) async {
    try {
      emit(CustomerOperationLoading());
      await _customerServices.deleteCustomer(customerId);
      emit(CustomerDeleted(customerId));
      await fetchCustomers(); // تحديث القائمة
    } catch (e) {
      emit(CustomerOperationError('فشل في حذف المورد: ${e.toString()}'));
    }
  }

  // البحث والتصفية
  void searchCustomers(String query) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      _applyFilters(
        searchQuery: query,
        cityFilter: currentState.cityFilter,
      );
    }
  }

  void filterByCity(String? city) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      _applyFilters(
        searchQuery: currentState.searchQuery,
        cityFilter: city,
      );
    }
  }

  void clearFilters() {
    emit(CustomerLoaded(
      customers: _allCustomers,
      searchQuery: '',
      cityFilter: null,
    ));
  }

  void _applyFilters({String searchQuery = '', String? cityFilter}) {
    final filtered = _allCustomers.where((customer) {
      final matchesSearch = searchQuery.isEmpty ||
          customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer.phone.contains(searchQuery);

      final matchesCity = cityFilter == null ||
          customer.address.toLowerCase().contains(cityFilter.toLowerCase());

      return matchesSearch && matchesCity;
    }).toList();

    emit(CustomerLoaded(
      customers: _allCustomers,
      filteredCustomers: filtered,
      searchQuery: searchQuery,
      cityFilter: cityFilter,
    ));
  }

  // جلب الإحصائيات
  Future<void> fetchStatistics() async {
    try {
      emit(CustomerStatisticsLoading());
      
      final totalCount = await _customerServices.getTotalCustomersCount();
      final cityCount = await _customerServices.getCustomersCountByCity();
      
      int filteredCount = totalCount;
      if (state is CustomerLoaded) {
        final currentState = state as CustomerLoaded;
        filteredCount = currentState.filteredCustomers.length;
      }

      emit(CustomerStatisticsLoaded(
        totalCustomers: totalCount,
        filteredCustomers: filteredCount,
        cityCount: cityCount,
      ));
    } catch (e) {
      emit(CustomerStatisticsError('فشل في جلب الإحصائيات: ${e.toString()}'));
    }
  }

  // الحصول على قائمة المدن المتاحة
  List<String> getAvailableCities() {
    return _allCustomers
        .map((s) => s.address)
        .where((address) => address.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }
}