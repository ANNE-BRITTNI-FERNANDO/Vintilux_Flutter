import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<Product> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;

  bool isInWishlist(Product product) {
    return _items.any((item) => item.id == product.id);
  }

  Future<void> fetchWishlist() async {
    // Local implementation, no API call needed
    notifyListeners();
  }

  Future<void> addToWishlist(Product product) async {
    try {
      if (!_items.any((item) => item.id == product.id)) {
        _items.add(product);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to add item to wishlist';
    }
  }

  Future<void> removeFromWishlist(Product product) async {
    try {
      _items.removeWhere((item) => item.id == product.id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove item from wishlist';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
