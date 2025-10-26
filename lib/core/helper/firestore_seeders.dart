// import 'package:management_stock/core/helper/firestore_services.dart';

// class FirestoreSeeder {
//   final _firestore = FirestoreServices.instance;

//   /// 🛍️ رفع المنتجات التجريبية
//   Future<void> uploadDemoProducts() async {
//     for (final product in demoProducts) {
//       final productData = {
//         'name': product.name,
//         'description': product.description,
//         'price': product.price,
//         'discountPrice': product.discountPrice,
//         'image': product.image,
//         'images': product.images,
//         'oldPrice': product.oldPrice,
//         'category': product.category,
//         'stock': product.stock,
//         'rating': product.rating,
//         'reviewsCount': product.reviewsCount,
//         'features': product.features,
//         'specifications': product.specifications,
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       await _firestore.setData(
//         path: ApiPaths.product(product.id),
//         data: productData,
//       );

//     }

//   }

//   /// 🗂️ رفع الكاتيجوريز التجريبية
//   Future<void> uploadDemoCategories() async {
//     for (final category in demoCategories) {
//       final categoryData = {
//         'name': category.name,
//         'image': category.image,
//         'productsCount': category.productsCount,
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       await _firestore.setData(
//         path: ApiPaths.categories() + category.id,
//         data: categoryData,
//       );

//     }

//   }
// }
