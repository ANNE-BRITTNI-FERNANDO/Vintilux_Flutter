import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';
import '../product/product_details_screen.dart';
import '../../widgets/base_screen_layout.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch wishlist when screen loads
    Future.microtask(() {
      context.read<WishlistProvider>().fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return BaseScreenLayout(
      scaffoldKey: scaffoldKey,
      title: 'My Wishlist',
      currentIndex: 1, // Wishlist is index 1
      onNavIndexChanged: (index) {
        // Navigation will be handled by BaseScreenLayout
      },
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    wishlistProvider.error,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => wishlistProvider.fetchWishlist(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (wishlistProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your wishlist is empty',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: wishlistProvider.items.length,
            itemBuilder: (context, index) {
              final product = wishlistProvider.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(
                    product.fullImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product.name),
                  subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await wishlistProvider.removeFromWishlist(product);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from wishlist'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
