class Supplier {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String notes;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
    };
  }
}

// ============= Dummy Data =============
final List<Supplier> dummySuppliers = [
  Supplier(
    id: '1',
    name: 'طه',
    phone: '0152365245748',
    address: 'Assuit',
    notes: '',
  ),
  Supplier(
    id: '2',
    name: 'عطية',
    phone: '01258746523',
    address: 'ديروط - ابو جبل',
    notes: '',
  ),
  Supplier(
    id: '3',
    name: 'sdr',
    phone: '01102477265',
    address: 'fdsfq',
    notes: '',
  ),
];