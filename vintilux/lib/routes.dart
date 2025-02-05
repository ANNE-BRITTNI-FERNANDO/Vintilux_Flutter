import 'package:flutter/material.dart';
import 'screens/home/new_home_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/product/product_details_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/wishlist/wishlist_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'models/product_model.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/orders/order_history_screen.dart';

// Remove the routes map since we're using onGenerateRoute
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
    case '/home':
      return MaterialPageRoute(builder: (_) => const NewHomeScreen());
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case '/cart':
      return MaterialPageRoute(builder: (_) => const CartScreen());
    case '/wishlist':
      return MaterialPageRoute(builder: (_) => const WishlistScreen());
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    case '/products':
      return MaterialPageRoute(builder: (_) => const ProductsScreen());
    case '/product':
      final args = settings.arguments as Map<String, dynamic>;
      final product = args['product'] as Product;
      return ProductDetailsScreen.route(product: product);
    case '/checkout':
      return MaterialPageRoute(builder: (_) => const CheckoutScreen());
    case '/orders':
      return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => const NewHomeScreen(),
      );
  }
  
}
