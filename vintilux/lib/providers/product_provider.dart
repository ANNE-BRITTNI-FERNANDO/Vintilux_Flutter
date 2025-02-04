import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Fetching products from: ${ApiConfig.productsEndpoint}');
      final response = await http.get(Uri.parse(ApiConfig.productsEndpoint));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final List<dynamic> productsJson = responseData['data'];
          _products = productsJson.map((json) => Product.fromJson(json)).toList();
          _error = '';
        } else {
          _error = 'Invalid response format';
          _products = [];
        }
      } else {
        _error = 'Failed to load products';
        _products = [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
