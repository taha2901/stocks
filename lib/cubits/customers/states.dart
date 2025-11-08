import 'package:management_stock/models/customer.dart';
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

// State الحالي بتاعك (اتركه زي ما هو)
class CustomerLoaded extends CustomerState {
  final List<Customer> customers; // ✅ مش allCustomers
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
