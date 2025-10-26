// import 'package:websiteme/core/helper/api_paths.dart';
// import 'package:websiteme/core/helper/firestore_services.dart';
// import 'package:websiteme/models/cart_item.dart';

// abstract class CartServices {
//   Future<List<CartItemModel>> getCartItems(String userId);
//   Future<void> setCartItem(String userId, CartItemModel item);
//   Future<void> removeCartItem(String userId, String itemId);
//   Future<void> clearCart(String userId);
// }

// class CartServicesImpl implements CartServices {
//   final _firestore = FirestoreServices.instance;

//   @override
//   Future<List<CartItemModel>> getCartItems(String userId) async {
//     return await _firestore.getCollection(
//       path: ApiPaths.cartItems(userId),
//       builder: (data, documentId) => CartItemModel.fromMap(data, documentId),
//     );
//   }

//   @override
//   Future<void> setCartItem(String userId, CartItemModel item) async {
//     await _firestore.setData(
//       path: ApiPaths.cartItem(userId, item.id),
//       data: item.toMap(),
//     );
//   }

//   @override
//   Future<void> removeCartItem(String userId, String itemId) async {
//     await _firestore.deleteData(path: ApiPaths.cartItem(userId, itemId));
//   }

//   @override
//   Future<void> clearCart(String userId) async {
//     final items = await getCartItems(userId);
//     for (final i in items) {
//       await removeCartItem(userId, i.id);
//     }
//   }
// }
