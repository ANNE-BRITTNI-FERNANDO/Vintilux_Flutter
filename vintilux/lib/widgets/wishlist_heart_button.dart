import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';

class WishlistHeartButton extends StatelessWidget {
  final Product product;
  final bool showBackground;
  final double size;
  final VoidCallback? onToggle;

  const WishlistHeartButton({
    Key? key,
    required this.product,
    this.showBackground = true,
    this.size = 24.0,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishlistProvider, AuthProvider>(
      builder: (context, wishlistProvider, authProvider, _) {
        final isInWishlist = wishlistProvider.isInWishlist(product);

        return Container(
          alignment: Alignment.center,
          decoration: showBackground
              ? BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: size,
            ),
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.grey,
              size: size * 0.8,
            ),
            onPressed: () async {
              if (!authProvider.isAuthenticated) {
                // Show login dialog
                final shouldLogin = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Login Required'),
                    content: const Text('Please login to add items to your wishlist.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                );

                if (shouldLogin == true) {
                  Navigator.pushNamed(context, '/login');
                  return;
                }
                return;
              }

              if (isInWishlist) {
                await wishlistProvider.removeFromWishlist(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product removed from wishlist'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                await wishlistProvider.addToWishlist(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product added to wishlist'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              onToggle?.call();
            },
          ),
        );
      },
    );
  }
}