import 'package:vintilux/models/product_model.dart';

class CartItem {
  final String id;
  final String userId;
  final Product product;
  final int quantity;
  final double price;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
    required this.price,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'product_id': product.id,
    'quantity': quantity,
    'price': price,
    'color': color,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>;
    final product = Product(
      id: productData['id'].toString(),
      name: productData['product_name'] as String,
      description: '', // API doesn't return this
      price: (productData['product_price'] as num).toDouble(),
      size: '', // API doesn't return this
      colors: [], // API doesn't return this
      quantity: 0, // API doesn't return this
      category: '', // API doesn't return this
      image: productData['product_image'] as String,
      gallery: [], // API doesn't return this
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return CartItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      product: product,
      quantity: int.parse(json['quantity'].toString()),
      price: (json['price'] as num).toDouble(),
      color: json['color'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
