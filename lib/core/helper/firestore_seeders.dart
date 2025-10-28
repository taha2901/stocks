import 'package:management_stock/core/helper/api_paths.dart';
import 'package:management_stock/core/helper/firestore_services.dart';
import 'package:management_stock/models/product.dart';

class FirestoreSeeder {
  final _firestore = FirestoreServices.instance;

  /// 🛍️ رفع المنتجات التجريبية
  Future<void> uploadDemoProducts() async {
    for (final product in dummyProducts) {
      final productData = {
        'id': product.id,
        'name': product.name,
        'category':  product.category,
        'image': product.image,
        'purchasePrice': product.purchasePrice,
        'sellPrice': product.sellPrice,
        'pointPrice': product.pointPrice,
        'quantity': product.quantity,
        'barcode': product.barcode,
      };

      await _firestore.setData(
        path: ApiPaths.product(product.id),
        data: productData,
      );
    }
  }

  /// 🗂️ رفع الكاتيجوريز التجريبية
  // Future<void> uploadDemoCategories() async {
  //   for (final category in demoCategories) {
  //     final categoryData = {
  //       'name': category.name,
  //       'image': category.image,
  //       'productsCount': category.productsCount,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     };

  //     await _firestore.setData(
  //       path: ApiPaths.categories() + category.id,
  //       data: categoryData,
  //     );

  //   }

  // }
}
