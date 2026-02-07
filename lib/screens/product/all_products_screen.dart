import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final ProductController productController = Get.find<ProductController>();
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => isSearching.value
              ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  style: TextStyle(color: Colors.green[800], fontSize: 18),
                )
              : Text('All Products'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (isSearching.value) {
              isSearching.value = false;
              searchController.clear();
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(isSearching.value ? Icons.close : Icons.search),
              onPressed: () {
                isSearching.value = !isSearching.value;
                if (!isSearching.value) {
                  searchController.clear();
                }
              },
            ),
          ),
          Obx(() {
            final filterType = productController.filterType.value;

            return PopupMenuButton<String>(
              icon: Icon(Icons.filter_alt),
              onSelected: (value) {
                if (filterType == 'team') {
                  productController.filterByTeam(value);
                } else if (filterType == 'brand') {
                  productController.filterByBrand(value);
                } else {
                  productController.filterByCategory(value);
                }
              },
              itemBuilder: (context) {
                if (filterType == 'team') {
                  return [
                    PopupMenuItem(value: 'All', child: Text('All Teams')),
                    PopupMenuItem(value: 'Argentina', child: Text('Argentina')),
                    PopupMenuItem(value: 'Brazil', child: Text('Brazil')),
                    PopupMenuItem(value: 'Germany', child: Text('Germany')),
                    PopupMenuItem(value: 'France', child: Text('France')),
                    PopupMenuItem(value: 'Spain', child: Text('Spain')),
                    PopupMenuItem(value: 'England', child: Text('England')),
                    PopupMenuItem(value: 'Others', child: Text('Others')),
                  ];
                } else if (filterType == 'brand') {
                  return [
                    PopupMenuItem(value: 'All', child: Text('All Brands')),
                    PopupMenuItem(value: 'Nike', child: Text('Nike')),
                    PopupMenuItem(value: 'Adidas', child: Text('Adidas')),
                    PopupMenuItem(value: 'Puma', child: Text('Puma')),
                    PopupMenuItem(
                      value: 'New Balance',
                      child: Text('New Balance'),
                    ),
                    PopupMenuItem(value: 'Others', child: Text('Others')),
                  ];
                } else {
                  return [
                    PopupMenuItem(value: 'All', child: Text('All Categories')),
                    PopupMenuItem(value: 'Jerseys', child: Text('Jerseys')),
                    PopupMenuItem(value: 'Shoes', child: Text('Shoes')),
                    PopupMenuItem(value: 'Balls', child: Text('Balls')),
                    PopupMenuItem(
                      value: 'Accessories',
                      child: Text('Accessories'),
                    ),
                    PopupMenuItem(value: 'Training', child: Text('Training')),
                    PopupMenuItem(value: 'Others', child: Text('Others')),
                  ];
                }
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Filter Tabs based on filter type
          Obx(() {
            return Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: _buildFilterChips(),
              ),
            );
          }),
          // Products Grid
          Expanded(
            child: Obx(() {
              // Show loading indicator
              if (productController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.green[700]),
                );
              }

              // Get filtered products from controller, then apply search
              final query = searchQuery.value.toLowerCase();
              final baseProducts = productController.filteredProducts;

              final products = query.isEmpty
                  ? baseProducts
                  : baseProducts.where((product) {
                      final nameMatch = product.name.toLowerCase().contains(
                        query,
                      );
                      final teamMatch = product.team.toLowerCase().contains(
                        query,
                      );
                      final categoryMatch = product.category
                          .toLowerCase()
                          .contains(query);
                      return nameMatch || teamMatch || categoryMatch;
                    }).toList();

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        searchQuery.value.isEmpty
                            ? 'No products found'
                            : 'No results for "${searchQuery.value}"',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  productController.loadProducts();
                },
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      // Floating Action Button for Cart
      floatingActionButton: Obx(() {
        final cartItemCount = productController.cartItems.length;

        if (cartItemCount > 0) {
          return FloatingActionButton.extended(
            onPressed: () {
              Get.toNamed('/cart'); // Assuming cart route exists
            },
            backgroundColor: Colors.green[700],
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                if (cartItemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$cartItemCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              'Cart ($cartItemCount)',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SizedBox.shrink();
      }),
    );
  }

  List<Widget> _buildFilterChips() {
    final filterType = productController.filterType.value;

    if (filterType == 'team') {
      // Show team filter chips
      return [
        _buildFilterChip('All', 'team'),
        _buildFilterChip('Argentina', 'team'),
        _buildFilterChip('Brazil', 'team'),
        _buildFilterChip('Germany', 'team'),
        _buildFilterChip('France', 'team'),
        _buildFilterChip('Spain', 'team'),
        _buildFilterChip('England', 'team'),
        _buildFilterChip('Others', 'team'),
      ];
    } else if (filterType == 'brand') {
      // Show brand filter chips
      return [
        _buildFilterChip('All', 'brand'),
        _buildFilterChip('Nike', 'brand'),
        _buildFilterChip('Adidas', 'brand'),
        _buildFilterChip('Puma', 'brand'),
        _buildFilterChip('New Balance', 'brand'),
        _buildFilterChip('Others', 'brand'),
      ];
    } else {
      // Show category filter chips (default)
      return [
        _buildFilterChip('All', 'category'),
        _buildFilterChip('Jerseys', 'category'),
        _buildFilterChip('Shoes', 'category'),
        _buildFilterChip('Balls', 'category'),
        _buildFilterChip('Accessories', 'category'),
        _buildFilterChip('Training', 'category'),
        _buildFilterChip('Others', 'category'),
      ];
    }
  }

  Widget _buildFilterChip(String value, String type) {
    return Obx(() {
      bool isSelected = false;

      if (type == 'team') {
        isSelected = productController.selectedTeam.value == value;
      } else if (type == 'brand') {
        isSelected = productController.selectedBrand.value == value;
      } else {
        isSelected = productController.selectedCategory.value == value;
      }

      return Container(
        margin: EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(value),
          selected: isSelected,
          onSelected: (selected) {
            if (type == 'team') {
              productController.filterByTeam(value);
            } else if (type == 'brand') {
              productController.filterByBrand(value);
            } else {
              productController.filterByCategory(value);
            }
          },
          selectedColor: Colors.green[100],
          checkmarkColor: Colors.green[700],
          labelStyle: TextStyle(
            color: isSelected ? Colors.green[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
      );
    });
  }

  Widget _buildCategoryChip(String category) {
    return Obx(() {
      final isSelected = productController.selectedCategory.value == category;

      return Container(
        margin: EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            productController.filterByCategory(category);
          },
          selectedColor: Colors.green[100],
          checkmarkColor: Colors.green[700],
          labelStyle: TextStyle(
            color: isSelected ? Colors.green[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
      );
    });
  }
}
