import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/customer.dart';

abstract class CustomerServices {
  Future<List<Customer>> getCustomers();
  Stream<List<Customer>> customersStream();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);

  // للإحصائيات
  Future<Map<String, int>> getCustomersCountByCity();
  Future<int> getTotalCustomersCount();
}

class CustomerServicesImpl implements CustomerServices {
  final _firestore = FirestoreServices.instance;

  @override
  Future<List<Customer>> getCustomers() async {
    return await _firestore.getCollection(
      path: ApiPaths.customers(),
      builder: (data, documentId) =>
          Customer.fromJson({...data, 'id': documentId}),
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  @override
  Stream<List<Customer>> customersStream() {
    return _firestore.collectionStream(
      path: ApiPaths.customers(),
      builder: (data, documentId) =>
          Customer.fromJson({...data, 'id': documentId}),
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _firestore.setData(
      path: ApiPaths.customer(customer.id),
      data: customer.toJson(),
    );
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _firestore.setData(
      path: ApiPaths.customer(customer.id),
      data: customer.toJson(),
    );
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _firestore.deleteData(path: ApiPaths.customer(customerId));
  }

  @override
  Future<Map<String, int>> getCustomersCountByCity() async {
    final customers = await getCustomers();
    final cityCount = <String, int>{};

    for (var customer in customers) {
      if (customer.address.isNotEmpty) {
        cityCount[customer.address] = (cityCount[customer.address] ?? 0) + 1;
      }
    }

    return cityCount;
  }

  @override
  Future<int> getTotalCustomersCount() async {
    final customers = await getCustomers();
    return customers.length;
  }
}
