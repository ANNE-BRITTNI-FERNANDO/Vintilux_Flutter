import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/product_provider.dart';
import 'package:provider/provider.dart';
import '../products/products_screen.dart';

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('VINTILUX & CO.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
        ],
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
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/wishlist');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Shop'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/cart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner Image
            Image.asset(
              'images/Home-Handbags 2.jpeg',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading banner: $error');
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // Latest Arrivals Carousel
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.products.isEmpty) {
                  productProvider.fetchProducts();
                  return const Center(child: CircularProgressIndicator());
                }
                
                final products = productProvider.products.take(4).toList();
                final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                final carouselHeight = isLandscape ? 200.0 : 250.0;
                final itemsPerRow = isLandscape ? 4 : 2;

                return Column(
                  children: [
                    const Text(
                      'Latest Arrivals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CarouselSlider.builder(
                      itemCount: (products.length / itemsPerRow).ceil(),
                      itemBuilder: (context, index, _) {
                        return Row(
                          children: [
                            for (int i = 0; i < itemsPerRow; i++)
                              if (index * itemsPerRow + i < products.length)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/product',
                                      arguments: {'product': products[index * itemsPerRow + i]},
                                    ),
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Image.network(
                                              products[index * itemsPerRow + i].fullImageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: Icon(Icons.image_not_supported),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  products[index * itemsPerRow + i].name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '\$${products[index * itemsPerRow + i].price}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                      options: CarouselOptions(
                        height: carouselHeight,
                        viewportFraction: 0.95,
                        enableInfiniteScroll: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            'HANDBAGS',
                            'images/Home-HandBags.png',
                            () => Navigator.pushNamed(
                              context,
                              '/products',
                              arguments: {'category': 'handbags'},
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildCategoryCard(
                            'ACCESSORIES',
                            'images/Accesroeis-Intro.jpg',
                            () => Navigator.pushNamed(
                              context,
                              '/products',
                              arguments: {'category': 'accessories'},
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildCategoryCard(
                        'HANDBAGS',
                        'images/Home-HandBags.png',
                        () => Navigator.pushNamed(
                          context,
                          '/products',
                          arguments: {'category': 'handbags'},
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCategoryCard(
                        'ACCESSORIES',
                        'images/Accesroeis-Intro.jpg',
                        () => Navigator.pushNamed(
                          context,
                          '/products',
                          arguments: {'category': 'accessories'},
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/wishlist');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/products');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/cart');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 150,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Enter a search term to begin'),
          ],
        ),
      );
    }

    final productProvider = Provider.of<ProductProvider>(context);
    if (productProvider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = productProvider.products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No products found matching "$query"'),
            const SizedBox(height: 8),
            const Text('Try using different keywords'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: SizedBox(
            width: 60,
            height: 60,
            child: Image.network(
              product.fullImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading search result image: $error');
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          title: Text(product.name),
          subtitle: Text('\$${product.price}'),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product',
              arguments: {'product': product},
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
