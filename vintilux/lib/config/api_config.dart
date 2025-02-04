class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://16.171.152.57/api';
  static const String apiVersion = '/v1';
  static const String baseImageUrl = 'http://16.171.152.57';  // Keep AWS for images for now
  static const String storageUrl = 'http://16.171.152.57/storage';

  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/login';
  static const String registerEndpoint = '$baseUrl/register';
  static const String logoutEndpoint = '$baseUrl/auth/logout';
  static const String refreshTokenEndpoint = '$baseUrl/auth/refresh';
  static const String profileEndpoint = '$baseUrl/profile';
  static const String updateProfileEndpoint = '$baseUrl/profile/update';
  static const String changePasswordEndpoint = '$baseUrl/profile/change-password';

  // Product endpoints
  static const String productsEndpoint = '$baseUrl/products';  // Simplified endpoint
  static const String productDetailsEndpoint = '$baseUrl/products';  // Base endpoint for product details
  static const String productCategoriesEndpoint = '$baseUrl/categories';
  static const String categoriesEndpoint = '$baseUrl/categories';

  // Cart endpoints
  static const String cartEndpoint = '$baseUrl/cart';
  static const String addToCartEndpoint = '$baseUrl/cart/add';
  static const String removeFromCartEndpoint = '$baseUrl/cart/remove';
  static const String updateCartEndpoint = '$baseUrl/cart/update';

  // Wishlist endpoints
  static const String wishlistEndpoint = '$baseUrl/wishlist';
  static const String addToWishlistEndpoint = '$baseUrl/wishlist/add';
  static const String removeFromWishlistEndpoint = '$baseUrl/wishlist/remove';

  // Order endpoints
  static const String ordersEndpoint = '$baseUrl/orders';
  static const String orderDetailsEndpoint = '$baseUrl/orders';
  static const String createOrderEndpoint = '$baseUrl/orders/create';

  // Helper methods for image URLs
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '$baseImageUrl/api/images/placeholder.jpg';
    }
    
    if (path.startsWith('http')) {
      return path;
    }

    // Clean the path by replacing escaped slashes
    final cleanPath = path.replaceAll(r'\/', '/');
    
    // Extract just the filename part if it includes a directory
    final filename = cleanPath.split('/').last;
    final directory = cleanPath.split('/').first;
    
    final url = '$baseImageUrl/api/images/$directory/$filename';
    print('Constructed image URL: $url');
    return url;
  }

  static String getGalleryImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final filename = imagePath.split('/').last;
    return '$baseImageUrl/api/images/product_galleries/$filename';
  }

  static String getProfileImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    final filename = imagePath.split('/').last;
    return '$baseImageUrl/api/images/profiles/$filename';
  }

  // Helper method to get headers with auth token
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
