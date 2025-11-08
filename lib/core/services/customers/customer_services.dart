import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/customer.dart';
abstract class CustomerServices {
  Future<List<Customer>> getCustomers();
  
  // الـ CRUD operations
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String customerId);
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
}
