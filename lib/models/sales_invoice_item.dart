import 'package:management_stock/models/product.dart';

class SalesInvoiceItem {
  ProductModel product;
  int quantity;
  double buyPrice;
  double sellPrice;

  SalesInvoiceItem({
    required this.product,
    this.quantity = 1,
    double? buyPrice,
    double? sellPrice,
  })  : buyPrice = buyPrice ?? product.purchasePrice,
        sellPrice = sellPrice ?? product.sellPrice;

  double get subtotal => sellPrice * quantity; // 🔥 البيع بسعر البيع مش الشراء

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'productName': product.name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'subtotal': subtotal,
    };
  }

  factory SalesInvoiceItem.fromMap(Map<String, dynamic> map) {
    return SalesInvoiceItem(
      product: ProductModel(
        id: map['productId'],
        name: map['productName'],
        category: '',
        image: '',
        purchasePrice: map['buyPrice']?.toDouble() ?? 0,
        sellPrice: map['sellPrice']?.toDouble() ?? 0,
        pointPrice: 0,
        quantity: 0,
        barcode: '',
      ),
      quantity: map['quantity'] ?? 1,
      buyPrice: map['buyPrice']?.toDouble() ?? 0,
      sellPrice: map['sellPrice']?.toDouble() ?? 0,
    );
  }
}