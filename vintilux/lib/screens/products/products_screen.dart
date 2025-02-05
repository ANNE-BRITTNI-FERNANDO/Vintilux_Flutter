import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../providers/wishlist_provider.dart';
import 'product_detail_screen.dart';
import '../../widgets/base_screen_layout.dart'; // Correct import path

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = isLandscape ? 4 : 2;

    return BaseScreenLayout(
      title: 'Shop',
      currentIndex: 2, // Shop is index 2
      onNavIndexChanged: (index) {
        // Navigation will be handled by BaseScreenLayout
      },
      body: Column(
        children: [
          // Category Filter Header
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Our Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterButton(
                        icon: Icons.shopping_bag,
                        label: 'All Products',
                        onTap: () {
                          setState(() {
                            _filteredProducts = _products;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildFilterButton(
                        icon: Icons.shopping_basket,
                        label: 'Handbags',
                        onTap: () {
                          setState(() {
                            _filteredProducts = _products
                                .where((p) => p.category.toLowerCase() == 'handbags')
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildFilterButton(
                        icon: Icons.watch,
                        label: 'Accessories',
                        onTap: () {
                          setState(() {
                            _filteredProducts = _products
                                .where((p) => p.category.toLowerCase() == 'accessories')
                                .toList();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Product Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProducts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_error, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProducts,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? const Center(child: Text('No products found'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.7,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_filteredProducts[index]);
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product',
            arguments: {'product': product},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                  // Wishlist button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, _) {
                        final isInWishlist = wishlistProvider.isInWishlist(product);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isInWishlist ? Colors.red : Theme.of(context).primaryColor,
                            ),
                            onPressed: () => wishlistProvider.toggleWishlist(product),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
