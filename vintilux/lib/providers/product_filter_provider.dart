import 'package:flutter/material.dart';

class ProductFilterProvider extends ChangeNotifier {
  String _searchKeyword = '';
  RangeValues _priceRange = const RangeValues(0, 10000); // Adjust max as needed

  String get searchKeyword => _searchKeyword;
  RangeValues get priceRange => _priceRange;

  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void setPriceRange(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _searchKeyword = '';
    _priceRange = const RangeValues(0, 10000);
    notifyListeners();
  }
}
