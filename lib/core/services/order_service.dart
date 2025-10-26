// import 'package:websiteme/core/helper/api_paths.dart';
// import 'package:websiteme/core/helper/firestore_services.dart';
// import 'package:websiteme/models/cart_item.dart';

// abstract class OrderServices {
//   Future<void> placeOrder({
//     required String userId,
//     required List<CartItemModel> items,
//     required double total,
//     required String paymentMethod,
//     required Map<String, dynamic> address,
//   });

//   // Future<List<Order>> getUserOrders(String userId);
// }

// class OrderServicesImpl implements OrderServices {
//   final _firestore = FirestoreServices.instance;

//   @override
//   Future<void> placeOrder({
//     required String userId,
//     required List<CartItemModel> items,
//     required double total,
//     required String paymentMethod,
//     required Map<String, dynamic> address,
//   }) async {
//     final orderId = DateTime.now().millisecondsSinceEpoch.toString();

//     final orderData = {
//       'id': orderId,
//       'userId': userId,
//       'items': items.map((i) => i.toMap()).toList(),
//       'total': total,
//       'paymentMethod': paymentMethod,
//       'address': address,
//       'status': 'pending',
//       'createdAt': DateTime.now().toIso8601String(),
//     };

//     await _firestore.setData(
//       path: '${ApiPaths.orders()}/$orderId',
//       data: orderData,
//     );
//   }

 
// }
