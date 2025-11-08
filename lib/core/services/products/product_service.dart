import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/product.dart';

abstract class ProductServices {
  Future<List<ProductModel>> getProducts();
  Future<void> addProduct(ProductModel item);
  Future<void> updateProduct(ProductModel item);
  Future<void> deleteProduct(String productId);
}

class ProductServicesImpl implements ProductServices {
  final _firestore = FirestoreServices.instance;

  @override
  Future<List<ProductModel>> getProducts() async {
    return await _firestore.getCollection(
      path: ApiPaths.products(),
      builder: (data, documentId) => ProductModel.fromMap({
        ...data,
        'id': documentId,
      }),
    );
  }

  @override
  Future<void> addProduct(ProductModel item) async {
    await _firestore.setData(
      path: ApiPaths.product(item.id),
      data: item.toMap(),
    );
  }

  @override
  Future<void> updateProduct(ProductModel item) async {
    await _firestore.setData(
      path: ApiPaths.product(item.id),
      data: item.toMap(),
    );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _firestore.deleteData(path: ApiPaths.product(productId));
  }
}