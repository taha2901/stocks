import 'package:management_stock/models/product.dart';

class PurchaseInvoiceModel {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime invoiceDate;
  final double totalBeforeDiscount;
  final double discount;
  final List<PurchaseInvoiceItem> items;
  final DateTime createdAt;

  PurchaseInvoiceModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.invoiceDate,
    required this.totalBeforeDiscount,
    required this.discount,
    required this.items,
    required this.createdAt,
  });

  // حساب الإجمالي بعد الخصم
  double get totalAfterDiscount => totalBeforeDiscount - discount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'invoiceDate': invoiceDate.toIso8601String(),
      'totalBeforeDiscount': totalBeforeDiscount,
      'discount': discount,
      'totalAfterDiscount': totalAfterDiscount,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PurchaseInvoiceModel.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceModel(
      id: map['id'] ?? '',
      supplierId: map['supplierId'] ?? '',
      supplierName: map['supplierName'] ?? '',
      invoiceDate: DateTime.parse(map['invoiceDate']),
      totalBeforeDiscount: (map['totalBeforeDiscount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      items: (map['items'] as List)
          .map((item) => PurchaseInvoiceItem.fromMap(item))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class PurchaseInvoiceItem {
  ProductModel product;
  int quantity;
  double buyPrice;
  double sellPrice;

  PurchaseInvoiceItem({
    required this.product,
    this.quantity = 1,
    double? buyPrice,
    double? sellPrice,
  })  : buyPrice = buyPrice ?? product.purchasePrice,
        sellPrice = sellPrice ?? product.sellPrice;

  double get subtotal => buyPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'productCategory': product.category,
      // 'productImage': product.image,
      'productBarcode': product.barcode,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'subtotal': subtotal,
    };
  }

  factory PurchaseInvoiceItem.fromMap(Map<String, dynamic> map) {
    return PurchaseInvoiceItem(
      product: ProductModel(
        id: map['productId'] ?? '',
        name: map['productName'] ?? '',
        category: map['productCategory'] ?? '',
        // image: map['productImage'] ?? '',
        purchasePrice: (map['buyPrice'] ?? 0).toDouble(),
        sellPrice: (map['sellPrice'] ?? 0).toDouble(),
        pointPrice: (map['sellPrice'] ?? 0).toDouble(),
        quantity: (map['quantity'] ?? 0).toInt(),
        barcode: map['productBarcode'] ?? '',
      ),
      quantity: (map['quantity'] ?? 0).toInt(),
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
    );
  }
}
