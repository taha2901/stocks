import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/suppliers.dart';

abstract class SupplierServices {
  Future<List<Supplier>> getSuppliers();
  Stream<List<Supplier>> suppliersStream();
  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String supplierId);
  
  // للإحصائيات
  Future<Map<String, int>> getSuppliersCountByCity();
  Future<int> getTotalSuppliersCount();
}

class SupplierServicesImpl implements SupplierServices {
  final _firestore = FirestoreServices.instance;

  @override
  Future<List<Supplier>> getSuppliers() async {
    return await _firestore.getCollection(
      path: ApiPaths.suppliers(),
      builder: (data, documentId) => Supplier.fromJson({
        ...data,
        'id': documentId,
      }),
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  @override
  Stream<List<Supplier>> suppliersStream() {
    return _firestore.collectionStream(
      path: ApiPaths.suppliers(),
      builder: (data, documentId) => Supplier.fromJson({
        ...data,
        'id': documentId,
      }),
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    await _firestore.setData(
      path: ApiPaths.supplier(supplier.id),
      data: supplier.toJson(),
    );
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await _firestore.setData(
      path: ApiPaths.supplier(supplier.id),
      data: supplier.toJson(),
    );
  }

  @override
  Future<void> deleteSupplier(String supplierId) async {
    await _firestore.deleteData(
      path: ApiPaths.supplier(supplierId),
    );
  }

  @override
  Future<Map<String, int>> getSuppliersCountByCity() async {
    final suppliers = await getSuppliers();
    final cityCount = <String, int>{};
    
    for (var supplier in suppliers) {
      if (supplier.address.isNotEmpty) {
        cityCount[supplier.address] = (cityCount[supplier.address] ?? 0) + 1;
      }
    }
    
    return cityCount;
  }

  @override
  Future<int> getTotalSuppliersCount() async {
    final suppliers = await getSuppliers();
    return suppliers.length;
  }
}