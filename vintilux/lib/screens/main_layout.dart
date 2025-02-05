import 'package:flutter/material.dart';
import '../widgets/base_screen_layout.dart';
import 'home/new_home_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'products/products_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const NewHomeScreen(),
    const WishlistScreen(),
    const ProductsScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'VINTILUX & CO.',
    'Wishlist',
    'Shop',
    'Cart',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      scaffoldKey: _scaffoldKey,
      title: _titles[_selectedIndex],
      currentIndex: _selectedIndex,
      onNavIndexChanged: _onItemTapped,
      actions: _selectedIndex == 0 ? [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search functionality
          },
        ),
      ] : null,
      body: _screens[_selectedIndex],
    );
  }
}
