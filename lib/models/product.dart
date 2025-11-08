class ProductModel {
  final String id; // ممكن نستخدمه لاحقًا مع Firebase
  final String name;
  final String category;
  final double purchasePrice;
  final double sellPrice;
  final double pointPrice;
  final int quantity;
  final String barcode;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.purchasePrice,
    required this.sellPrice,
    required this.pointPrice,
    required this.quantity,
    required this.barcode,
  });
  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? purchasePrice,
    double? sellPrice,
    double? pointPrice,
    int? quantity,
    String? barcode,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellPrice: sellPrice ?? this.sellPrice,
      pointPrice: pointPrice ?? this.pointPrice,
      quantity: quantity ?? this.quantity,
      barcode: barcode ?? this.barcode,
    );
  }

  // ✅ fromJson
  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      purchasePrice: (json['purchasePrice'] ?? 0).toDouble(),
      sellPrice: (json['sellPrice'] ?? 0).toDouble(),
      pointPrice: (json['pointPrice'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      barcode: json['barcode'] ?? '',
    );
  }
  //copyWith
  
  // ✅ toJson
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellPrice': sellPrice,
      'pointPrice': pointPrice,
      'quantity': quantity,
      'barcode': barcode,
    };
  }
}
