import '../config/api_config.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String size;
  final List<String> colors;
  final int quantity;
  final String category;
  final String image;
  final List<String> gallery;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.size,
    required this.colors,
    required this.quantity,
    required this.category,
    required this.image,
    required this.gallery,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullImageUrl => ApiConfig.getImageUrl(image);
  List<String> get fullGalleryUrls => gallery.map((img) => ApiConfig.getImageUrl(img)).toList();
  bool get inStock => quantity > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle both full product response and simplified cart/wishlist response
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['product_name'] as String? ?? '',
      description: json['product_description'] as String? ?? '',
      price: (json['product_price'] as num?)?.toDouble() ?? 0.0,
      size: json['product_size'] as String? ?? '',
      colors: (json['product_colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      quantity: (json['product_quantity'] as num?)?.toInt() ?? 0,
      category: json['product_category'] as String? ?? '',
      image: json['product_image'] as String? ?? '',
      gallery: (json['product_gallery'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['product_status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': name,
      'product_description': description,
      'product_price': price,
      'product_size': size,
      'product_colors': colors,
      'product_quantity': quantity,
      'product_category': category,
      'product_image': image,
      'product_gallery': gallery,
      'product_status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? size,
    List<String>? colors,
    int? quantity,
    String? category,
    String? image,
    List<String>? gallery,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      size: size ?? this.size,
      colors: colors ?? this.colors,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      image: image ?? this.image,
      gallery: gallery ?? this.gallery,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
