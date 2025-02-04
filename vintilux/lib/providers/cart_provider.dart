import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/cart_item.dart';
import '../models/product_model.dart';
import 'auth_provider.dart';

class CartProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String _error = '';

  CartProvider(this._authProvider) {
    developer.log('Initializing CartProvider');
    // Listen to auth changes
    _authProvider.addListener(_onAuthChanged);
    
    // If already authenticated, fetch cart
    if (_authProvider.isAuthenticated) {
      developer.log('User is authenticated, fetching cart');
      fetchCart();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    developer.log('Auth state changed. isAuthenticated: ${_authProvider.isAuthenticated}');
    if (_authProvider.isAuthenticated) {
      fetchCart();
    } else {
      _items = [];
      notifyListeners();
    }
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  Future<void> fetchCart() async {
    try {
      if (!_authProvider.isAuthenticated) {
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      final token = _authProvider.token;
      if (token == null) {
        throw Exception('No auth token available');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.cartEndpoint),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          _items = (data['data'] as List).map((item) {
            final product = Product(
              id: item['product']['id'],
              name: item['product']['product_name'],
              description: '', // API doesn't return this
              price: (item['product']['product_price'] as num).toDouble(),
              size: '', // API doesn't return this
              colors: [], // API doesn't return this
              quantity: 2, // Set to actual stock quantity from API
              category: '', // API doesn't return this
              image: item['product']['product_image'],
              gallery: [], // API doesn't return this
              status: 'active',
              createdAt: DateTime.parse(item['created_at']),
              updatedAt: DateTime.parse(item['updated_at']),
            );

            return CartItem(
              id: item['id'],
              userId: item['user_id'],
              product: product,
              quantity: int.parse(item['quantity'].toString()),
              price: (item['price'] as num).toDouble(),
              color: item['color'] ?? 'Black', // Default to Black if no color specified
              createdAt: DateTime.parse(item['created_at']),
              updatedAt: DateTime.parse(item['updated_at']),
            );
          }).toList();
        } else {
          _items = [];
        }
        _error = '';
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to fetch cart';
      }
    } catch (e) {
      _error = 'An error occurred while fetching cart';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    if (!_authProvider.isAuthenticated) {
      _error = 'Please login to update cart';
      notifyListeners();
      return;
    }

    try {
      if (newQuantity == 0) {
        await removeFromCart(itemId);
        return;
      }

      if (newQuantity < 1) {
        _error = 'Quantity must be at least 1';
        notifyListeners();
        return;
      }

      final item = _items.firstWhere((item) => item.id == itemId);
      
      // Check if new quantity exceeds available stock
      if (newQuantity > item.product.quantity) {
        _error = 'Cannot add more than available stock (${item.product.quantity} items)';
        notifyListeners();
        return;
      }

      _isLoading = true;
      _error = '';
      notifyListeners();

      final token = _authProvider.token;
      if (token == null) {
        throw Exception('No auth token available');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.cartEndpoint}/$itemId'),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'quantity': newQuantity.toString(),
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart after successful update
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to update quantity';
      }
    } catch (e) {
      _error = 'Failed to update quantity';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String itemId) async {
    if (!_authProvider.isAuthenticated) {
      _error = 'Please login to remove items';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final token = _authProvider.token;
      if (token == null) {
        throw Exception('No auth token available');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.cartEndpoint}/$itemId'),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart after successful removal
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to remove item';
      }
    } catch (e) {
      _error = 'Failed to remove item';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {required String color}) async {
    if (!_authProvider.isAuthenticated) {
      _error = 'Please login to add items to cart';
      notifyListeners();
      return;
    }

    try {
      // Check if product already exists in cart with same color
      final existingItem = _items.firstWhere(
        (item) => item.product.id == product.id && item.color == color,
        orElse: () => CartItem(
          id: '',
          userId: '',
          product: product,
          quantity: 0,
          price: product.price,
          color: color,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      if (existingItem.id.isNotEmpty) {
        _error = 'Product with selected color is already in your cart';
        notifyListeners();
        return;
      }

      _isLoading = true;
      _error = '';
      notifyListeners();

      final token = _authProvider.token;
      if (token == null) {
        throw Exception('No auth token available');
      }

      final response = await http.post(
        Uri.parse(ApiConfig.cartEndpoint),
        headers: ApiConfig.getAuthHeaders(token),
        body: json.encode({
          'product_id': product.id,
          'quantity': '1',
          'price': product.price,
          'color': color,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart after successful add
      } else if (response.statusCode == 401) {
        _error = 'Session expired. Please login again.';
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? 'Failed to add item to cart';
      }
    } catch (e) {
      _error = 'Failed to add item to cart';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCartLocal(Product product) async {
    try {
      final existingCartItemIndex = _items.indexWhere(
        (item) => item.product.id == product.id,
      );

      if (existingCartItemIndex >= 0) {
        final existingItem = _items[existingCartItemIndex];
        // Check if adding one more exceeds stock
        if (existingItem.quantity >= product.quantity) {
          _error = 'Cannot add more than available stock (${product.quantity} items)';
          notifyListeners();
          return;
        }

        // Create new cart item with increased quantity
        final updatedItem = CartItem(
          id: existingItem.id,
          userId: existingItem.userId,
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
          color: existingItem.color,
          createdAt: existingItem.createdAt,
          updatedAt: DateTime.now(),
        );
        _items[existingCartItemIndex] = updatedItem;
      } else {
        _items.add(
          CartItem(
            id: DateTime.now().toString(),
            userId: 'local_user', // Using a local ID since we're not using API
            product: product,
            quantity: 1,
            price: product.price,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item to cart';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
