import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../utils/app_strings.dart';
import '../../widgets/product_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ProductController productController = Get.find<ProductController>();
  List<String> _trendingProductIds = []; // Store only IDs to maintain order
  Worker? _productsWorker;

  @override
  void initState() {
    super.initState();
    // Initialize trending products once
    _updateTrendingProducts();

    // Listen to product changes only to update when new products are loaded
    _productsWorker = ever(productController.products, (_) {
      // Only recalculate if we don't have trending IDs or product count changed significantly
      if (_trendingProductIds.isEmpty ||
          (productController.products.length - _trendingProductIds.length)
                  .abs() >
              3) {
        _updateTrendingProducts();
      }
    });
  }

  void _updateTrendingProducts() {
    if (productController.products.isNotEmpty) {
      final sortedProducts = List<Product>.from(productController.products);
      sortedProducts.sort((a, b) => b.soldCount.compareTo(a.soldCount));
      setState(() {
        _trendingProductIds = sortedProducts.take(6).map((p) => p.id).toList();
      });
    }
  }

  // Get trending products by IDs (maintains order but gets latest data)
  List<Product> get _trendingProducts {
    return _trendingProductIds
        .map(
          (id) =>
              productController.products.firstWhereOrNull((p) => p.id == id),
        )
        .whereType<Product>()
        .toList();
  }

  @override
  void dispose() {
    _productsWorker?.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.explore),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          productController.loadProducts();
          _updateTrendingProducts();
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
            Obx(
              () =>
                  _buildProductSection('Trending Products', _trendingProducts),
            ),
          ],
        ),
      ),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
