import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_stock/models/pos/pos_cart_model.dart';
import 'package:management_stock/models/product.dart';
import 'package:uuid/uuid.dart';

class POSSaleModel {
  final String id;
  final DateTime saleDate;
  final List<POSCartItem> items;
  final double total;

  POSSaleModel({
    String? id,
    DateTime? saleDate,
    required this.items,
  })  : id = id ?? const Uuid().v4(),
        saleDate = saleDate ?? DateTime.now(),
        total = items.fold(0, (sum, item) => sum + item.total);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleDate': saleDate, // Firestore هيخزنها Timestamp تلقائيًا
      'total': total,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory POSSaleModel.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['items'] ?? []) as List;
    return POSSaleModel(
      id: map['id'] ?? '',
      saleDate: (map['saleDate'] is Timestamp)
          ? (map['saleDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['saleDate']?.toString() ?? '') ?? DateTime.now(),
      items: rawItems.map((item) {
        final i = Map<String, dynamic>.from(item);
        return POSCartItem(
          product: ProductModel(
            id: i['productId'] ?? '',
            name: i['name'] ?? '',
            category: '',
            image: '',
            purchasePrice: 0,
            sellPrice: (i['price'] ?? 0).toDouble(),
            pointPrice: 0,
            quantity: 0,
            barcode: '',
          ),
          quantity: (i['quantity'] ?? 1).toInt(),
        );
      }).toList(),
    );
  }
}
