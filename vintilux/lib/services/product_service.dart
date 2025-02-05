import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/product_model.dart';

class ProductService {
  final storage = const FlutterSecureStorage();

  Future<List<Product>> getProducts() async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': token,
        },
      );
      
      developer.log('Products response status: ${response.statusCode}');
      developer.log('Products response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> productsData = responseData['data'];
          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to parse products data');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error loading products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
  
  Future<Product> getProductDetails(String productId) async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse('${ApiConfig.productDetailsEndpoint}/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': token,
        },
      );
      
      developer.log('Product details response status: ${response.statusCode}');
      developer.log('Product details response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return Product.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to parse product details');
        }
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error loading product details: $e');
      throw Exception('Failed to load product details: $e');
    }
  }
}
