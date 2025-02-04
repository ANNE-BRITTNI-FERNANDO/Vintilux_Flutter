import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  final List<String> _imageUrls = [];
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _imageUrls.add(widget.product.fullImageUrl);
    _imageUrls.addAll(widget.product.fullGalleryUrls);
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ProductDetailsScreen for ${widget.product.name}');
    print('Image URLs: $_imageUrls');
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image with Gallery
            SizedBox(
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Image.network(
                      _imageUrls[_selectedImageIndex],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image in details: $error');
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported, size: 50),
                              const SizedBox(height: 8),
                              const Text('Unable to load image'),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_imageUrls.length > 1) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImageIndex = index;
                                });
                              },
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedImageIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.product.size.isNotEmpty) ...[
                    Text(
                      'Size: ${widget.product.size}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (widget.product.colors.isNotEmpty) ...[
                    Text(
                      'Available Colors:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.product.colors.map((color) {
                        final isSelected = color == _selectedColor;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(color),
                          onSelected: (selected) {
                            setState(() {
                              _selectedColor = selected ? color : null;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.product.inStock ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.product.inStock 
                          ? 'In Stock (${widget.product.quantity} available)' 
                          : 'Out of Stock',
                      style: TextStyle(
                        color: widget.product.inStock ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, _) {
                final isInWishlist = wishlistProvider.isInWishlist(widget.product);
                return IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : null,
                  ),
                  onPressed: () async {
                    if (isInWishlist) {
                      await wishlistProvider.removeFromWishlist(widget.product);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Removed from wishlist')),
                      );
                    } else {
                      await wishlistProvider.addToWishlist(widget.product);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to wishlist')),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.inStock && (_selectedColor != null || widget.product.colors.isEmpty)
                    ? () async {
                        final cartProvider = context.read<CartProvider>();
                        await cartProvider.addToCart(
                          widget.product,
                          color: _selectedColor ?? 'Default',
                        );
                        if (!mounted) return;
                        
                        // Refresh the cart after adding the product
                        cartProvider.fetchCart();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(cartProvider.error.isNotEmpty 
                                ? cartProvider.error 
                                : 'Added to cart'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: cartProvider.error.isNotEmpty
                                ? Theme.of(context).colorScheme.error
                                : Colors.green,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.product.colors.isNotEmpty && _selectedColor == null
                      ? 'Select a Color'
                      : 'Add to Cart'
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
