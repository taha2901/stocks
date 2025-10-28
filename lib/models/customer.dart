class Customer {
  final String id; // إضافة معرف فريد
  final String name;
  final String phone;
  final String address;
  final String notes;
  final String type;
  final double? creditLimit;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    this.type = "آخر",
    this.creditLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'type': type,
      'creditLimit': creditLimit,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
      type: json['type'] ?? 'آخر',
      creditLimit: json['creditLimit'] != null 
          ? (json['creditLimit'] is int 
              ? (json['creditLimit'] as int).toDouble()
              : json['creditLimit'] as double)
          : null,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    String? type,
    double? creditLimit,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }
}

// Dummy data for testing
final List<Customer> dummyCustomers = [
  Customer(
    id: '1',
    name: "أحمد محمد",
    phone: "01012345678",
    address: "القاهرة - مدينة نصر",
    notes: "عميل مميز",
    type: "قطاعي",
    creditLimit: 10000,
  ),
  Customer(
    id: '2',
    name: "منى خالد",
    phone: "01198765432",
    address: "الجيزة - فيصل",
    notes: "تحتاج خصم دائم",
    type: "جملة",
    creditLimit: 5000,
  ),
  Customer(
    id: '3',
    name: "طارق علي",
    phone: "01234567890",
    address: "الإسكندرية - سموحة",
    notes: "فاتورة شهرية",
    type: "آخر",
    creditLimit: 15000,
  ),
];