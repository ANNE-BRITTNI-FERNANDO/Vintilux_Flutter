import 'package:vintilux/models/product_model.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String? productName;
  final int quantity;
  final double? price;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    required this.quantity,
    this.price,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      quantity: int.parse(json['quantity'].toString()),
      price: json['price']?.toDouble(),
      color: json['color'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Order {
  final String id;
  final String status;
  final String userId;
  final double totalAmount;
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String city;
  final String postalCode;
  final String phoneNumber;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.userId,
    required this.totalAmount,
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.city,
    required this.postalCode,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      status: json['status'] as String,
      userId: json['user_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      streetAddress: json['street_address'] as String,
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      phoneNumber: json['phone_number'] as String,
      paymentMethod: json['payment_method'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
