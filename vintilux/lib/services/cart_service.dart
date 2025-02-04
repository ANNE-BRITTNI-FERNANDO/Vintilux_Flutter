import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/cart_item_model.dart';

class CartService {
  Future<List<CartItem>> getCartItems() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.cart),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CartItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      throw Exception('Failed to load cart items: $e');
    }
  }
  
  Future<void> addToCart(String productId, int quantity, String color) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.addToCart),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
          'color': color,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add item to cart');
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }
  
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.removeFromCart + '/$cartItemId'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to remove item from cart');
      }
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }
  
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.cart + '/$cartItemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quantity': quantity,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update cart item quantity');
      }
    } catch (e) {
      throw Exception('Failed to update cart item quantity: $e');
    }
  }
  
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.baseUrl + ApiConfig.updateCart),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'quantity': quantity,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update cart item quantity');
      }
    } catch (e) {
      throw Exception('Failed to update cart item quantity: $e');
    }
  }
}
