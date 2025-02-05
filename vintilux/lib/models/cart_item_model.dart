import 'package:flutter/foundation.dart';
import 'product_model.dart';


@immutable
class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String color; // Changed from String? to String to always have a color
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.color = 'Default', // Set default color if none provided
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      color: json['color'] as String? ?? 'Default', // Always provide a color
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(), // Fixed: Call toJson on product
      'quantity': quantity,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get totalPrice => product.price * quantity;
}
