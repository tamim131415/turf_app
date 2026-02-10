import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  // Team flag mapping
  final Map<String, String> teamFlags = const {
    'Argentina': '🇦🇷',
    'Brazil': '🇧🇷',
    'Germany': '🇩🇪',
    'France': '🇫🇷',
    'Spain': '🇪🇸',
    'England': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    'Others': '🌍',
  };

  // Category emoji mapping
  final Map<String, String> categoryEmojis = const {
    'Jerseys': '👕',
    'Shoes': '👟',
    'Accessories': '🎽',
    'Balls': '⚽',
    'Training': '🏋️',
    'Others': '🛍️',
  };

  // Brand emoji mapping
  final Map<String, String> brandEmojis = const {
    'Nike': '✔️',
    'Adidas': '🔺',
    'Puma': '🐆',
    'New Balance': '⚖️',
    'Others': '🏷️',
  };

  // Brand image mapping
  final Map<String, String> brandImages = const {
    'Nike': 'assets/brands/nike.png',
    'Adidas': 'assets/brands/adidas.png',
    'Puma': 'assets/brands/puma.png',
    'New Balance': 'assets/brands/newbalance.png',
  };

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            productController.loadProducts();
          },
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              _buildCategorySection('Popular Teams', Icons.group, [
                'Argentina',
                'Brazil',
                'Germany',
                'France',
                'Spain',
                'England',
                'Others',
              ]),
              _buildCategorySection('Categories', Icons.category, [
                'Jerseys',
                'Shoes',
                'Accessories',
                'Balls',
                'Training',
              ]),
              _buildCategorySection('Brands', Icons.business, [
                'Nike',
                'Adidas',
                'Puma',
                'New Balance',
                'Others',
              ]),
              _buildProductSection(
                'Trending Products',
                productController.products.take(4).toList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategorySection(
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  final ProductController productController =
                      Get.find<ProductController>();

                  // Determine filter type based on section title
                  if (title == 'Popular Teams') {
                    productController.filterByTeam(items[index]);
                  } else if (title == 'Brands') {
                    productController.filterByBrand(items[index]);
                  } else {
                    // Categories
                    productController.filterByCategory(items[index]);
                  }

                  Get.toNamed('/all-products');
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Center(
                    child:
                        (title == 'Popular Teams' ||
                            title == 'Categories' ||
                            title == 'Brands')
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (title == 'Brands' &&
                                  brandImages.containsKey(items[index]))
                                Image.asset(
                                  brandImages[items[index]]!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      brandEmojis[items[index]] ?? '🏷️',
                                      style: TextStyle(fontSize: 32),
                                    );
                                  },
                                )
                              else
                                Text(
                                  title == 'Popular Teams'
                                      ? (teamFlags[items[index]] ?? '🌍')
                                      : title == 'Categories'
                                      ? (categoryEmojis[items[index]] ?? '🛍️')
                                      : (brandEmojis[items[index]] ?? '🏷️'),
                                  style: TextStyle(fontSize: 32),
                                ),
                              SizedBox(height: 4),
                              Text(
                                items[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Text(
                            items[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductSection(String title, List products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed('/product-detail', arguments: product);
                },
                child: Container(
                  margin: EdgeInsets.only(right: 12),
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(product.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                product.team,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '৳${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
