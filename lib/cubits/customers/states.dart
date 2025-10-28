import 'package:management_stock/models/customer.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String searchQuery;
  final String? cityFilter;

  CustomerLoaded({
    required this.customers,
    List<Customer>? filteredCustomers,
    this.searchQuery = '',
    this.cityFilter,
  }) : filteredCustomers = filteredCustomers ?? customers;

  CustomerLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
    String? cityFilter,
    bool clearCityFilter = false,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
      cityFilter: clearCityFilter ? null : (cityFilter ?? this.cityFilter),
    );
  }
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError(this.message);
}

// حالات العمليات
class CustomerOperationLoading extends CustomerState {}

class CustomerAdded extends CustomerState {
  final Customer customer;

  CustomerAdded(this.customer);
}

class CustomerUpdated extends CustomerState {
  final Customer customer;

  CustomerUpdated(this.customer);
}

class CustomerDeleted extends CustomerState {
  final String customerId;

  CustomerDeleted(this.customerId);
}

class CustomerOperationError extends CustomerState {
  final String message;

  CustomerOperationError(this.message);
}

// حالات الإحصائيات
class CustomerStatisticsLoading extends CustomerState {}

class CustomerStatisticsLoaded extends CustomerState {
  final int totalCustomers;
  final int filteredCustomers;
  final Map<String, int> cityCount;

  CustomerStatisticsLoaded({
    required this.totalCustomers,
    required this.filteredCustomers,
    required this.cityCount,
  });
}

class CustomerStatisticsError extends CustomerState {
  final String message;

  CustomerStatisticsError(this.message);
}