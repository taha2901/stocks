class Customer {
  final String name;
  final String phone;
  final String address;
  final String notes;
  final String type; // جديد: نوع العميل
  final double? creditLimit;

  Customer({
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    this.type = "آخر",
    this.creditLimit,
  });
}



final List<Customer> dummyCustomers = [
  Customer(
    name: "أحمد محمد",
    phone: "01012345678",
    address: "القاهرة - مدينة نصر",
    notes: "عميل مميز",
    type: "قطاعي",
    creditLimit: 10000,
  ),
  Customer(
    name: "منى خالد",
    phone: "01198765432",
    address: "الجيزة - فيصل",
    notes: "تحتاج خصم دائم",
    type: "جملة",
    creditLimit: 5000,
  ),
  Customer(
    name: "طارق علي",
    phone: "01234567890",
    address: "الإسكندرية - سموحة",
    notes: "فاتورة شهرية",
    type: "مورد",
    creditLimit: 15000,
  ),
];
