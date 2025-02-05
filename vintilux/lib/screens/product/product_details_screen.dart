import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/wishlist_heart_button.dart';
import '../../models/cart_item.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  static Route route({required Product product}) {
    return MaterialPageRoute(
      builder: (context) => ProductDetailsScreen(product: product),
      settings: RouteSettings(
        name: '/product',
        arguments: {'product': product},
      ),
    );
  }

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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.product.name),
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Image Gallery
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              _imageUrls[_selectedImageIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported, size: 50),
                                      SizedBox(height: 8),
                                      Text('Unable to load image'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_imageUrls.length > 1)
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
                                        width: 72,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _selectedImageIndex == index
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[300]!,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            _imageUrls[index],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Right side - Product Details
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'LKR ${widget.product.price.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WishlistHeartButton(
                                product: widget.product,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                widget.product.quantity > 0 
                                    ? Icons.check_circle 
                                    : Icons.remove_circle,
                                color: widget.product.quantity > 0 
                                    ? Colors.green 
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.product.quantity > 0
                                    ? 'In Stock (${widget.product.quantity} available)'
                                    : 'Out of Stock',
                                style: TextStyle(
                                  color: widget.product.quantity > 0 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (widget.product.colors.isNotEmpty) ...[
                            Text(
                              'Colors',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: widget.product.colors.map((color) {
                                return ChoiceChip(
                                  label: Text(color),
                                  selected: _selectedColor == color,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedColor = selected ? color : null;
                                    });
                                  },
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
                          Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              return Column(
                                children: [
                                  if (cartProvider.error.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        cartProvider.error,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: widget.product.quantity > 0
                                        ? () {
                                            final cartItem = cartProvider.items.firstWhere(
                                              (item) => item.product.id == widget.product.id,
                                              orElse: () => CartItem(
                                                id: '',
                                                userId: '',
                                                product: widget.product,
                                                quantity: 0,
                                                price: 0,
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                              ),
                                            );

                                            if (cartItem.quantity >= widget.product.quantity) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Cannot add more than available stock (${widget.product.quantity} items)',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            cartProvider.addToCart(
                                              widget.product,
                                              color: _selectedColor ?? widget.product.colors.first,
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.product.quantity > 0 
                                          ? Theme.of(context).primaryColor 
                                          : Colors.grey,
                                    ),
                                    child: Text(
                                      widget.product.quantity > 0
                                          ? 'Add to Cart'
                                          : 'Out of Stock',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
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
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'LKR ${widget.product.price.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              WishlistHeartButton(
                                product: widget.product,
                                size: 32,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                widget.product.quantity > 0 
                                    ? Icons.check_circle 
                                    : Icons.remove_circle,
                                color: widget.product.quantity > 0 
                                    ? Colors.green 
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.product.quantity > 0
                                    ? 'In Stock (${widget.product.quantity} available)'
                                    : 'Out of Stock',
                                style: TextStyle(
                                  color: widget.product.quantity > 0 
                                      ? Colors.green 
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (widget.product.colors.isNotEmpty) ...[
                            Text(
                              'Colors',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: widget.product.colors.map((color) {
                                return ChoiceChip(
                                  label: Text(color),
                                  selected: _selectedColor == color,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedColor = selected ? color : null;
                                    });
                                  },
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
                          Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              return Column(
                                children: [
                                  if (cartProvider.error.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Text(
                                        cartProvider.error,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: widget.product.quantity > 0
                                        ? () {
                                            final cartItem = cartProvider.items.firstWhere(
                                              (item) => item.product.id == widget.product.id,
                                              orElse: () => CartItem(
                                                id: '',
                                                userId: '',
                                                product: widget.product,
                                                quantity: 0,
                                                price: 0,
                                                createdAt: DateTime.now(),
                                                updatedAt: DateTime.now(),
                                              ),
                                            );

                                            if (cartItem.quantity >= widget.product.quantity) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Cannot add more than available stock (${widget.product.quantity} items)',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            cartProvider.addToCart(
                                              widget.product,
                                              color: _selectedColor ?? widget.product.colors.first,
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.product.quantity > 0 
                                          ? Theme.of(context).primaryColor 
                                          : Colors.grey,
                                    ),
                                    child: Text(
                                      widget.product.quantity > 0
                                          ? 'Add to Cart'
                                          : 'Out of Stock',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                          color: _selectedColor ?? widget.product.colors.first,
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
