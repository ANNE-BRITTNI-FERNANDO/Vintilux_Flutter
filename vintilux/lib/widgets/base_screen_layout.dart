import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class BaseScreenLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;
  final Function(int) onNavIndexChanged;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const BaseScreenLayout({
    Key? key,
    required this.body,
    required this.title,
    this.actions,
    required this.currentIndex,
    required this.onNavIndexChanged,
    this.scaffoldKey,
  }) : super(key: key);

  void _handleNavigation(BuildContext context, int index) {
    onNavIndexChanged(index);
    String route = '/';
    switch (index) {
      case 0:
        route = '/';
        break;
      case 1:
        route = '/wishlist';
        break;
      case 2:
        route = '/products';
        break;
      case 3:
        route = '/cart';
        break;
      case 4:
        route = '/profile';
        break;
    }
    
    // Close the drawer if it's open
    if (scaffoldKey?.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    // Only navigate if we're not already on the target route
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
        title: Text(title),
        actions: actions,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'VINTILUX & CO.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Luxury at your fingertips',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: currentIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _handleNavigation(context, 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              selected: currentIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _handleNavigation(context, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Shop'),
              selected: currentIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _handleNavigation(context, 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              selected: currentIndex == 3,
              onTap: () {
                Navigator.pop(context);
                _handleNavigation(context, 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              selected: currentIndex == 4,
              onTap: () {
                Navigator.pop(context);
                _handleNavigation(context, 4);
              },
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleNavigation(context, index),
      ),
    );
  }
}
