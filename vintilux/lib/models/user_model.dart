class UserAddress {
  final String? street;
  final String? city;
  final String? postalCode;

  UserAddress({
    this.street,
    this.city,
    this.postalCode,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      street: json['street'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'postal_code': postalCode,
  };
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserAddress? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] != null ? UserAddress.fromJson(json['address'] as Map<String, dynamic>) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserAddress? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
