import 'dart:convert';

enum UserRole {
  admin,
  cashier,
  warehouseManager,
  viewer,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? phone;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone,
    required this.createdAt,
    this.isActive = true,
  });

  /// من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: _roleFromString(json['role']),
      phone: json['phone'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  /// إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// دالة مساعدة لتحويل string لصلاحية
  static UserRole _roleFromString(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'cashier':
        return UserRole.cashier;
      case 'warehouseManager':
        return UserRole.warehouseManager;
      case 'viewer':
        return UserRole.viewer;
      default:
        return UserRole.viewer;
    }
  }

  /// دالة نسخ (لو حبيت تعدل حاجة)
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? phone,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// تحويل لقيمة String (لو حبيت تخزنها كـ JSON في SharedPrefs)
  String toJsonString() => jsonEncode(toJson());

  /// إنشاء من String JSON
  factory UserModel.fromJsonString(String jsonStr) =>
      UserModel.fromJson(jsonDecode(jsonStr));
}
