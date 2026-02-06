import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/product_card.dart';

class AllProductsScreen extends StatelessWidget {
  AllProductsScreen({super.key});

  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Filter/Search icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_alt),
            onSelected: (category) {
              productController.filterByCategory(category);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All Products')),
              PopupMenuItem(value: 'Jersey', child: Text('Jerseys')),
              PopupMenuItem(value: 'Kit', child: Text('Kits')),
              PopupMenuItem(value: 'Accessories', child: Text('Accessories')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Obx(() {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All'),
                  _buildCategoryChip('Jersey'),
                  _buildCategoryChip('Kit'),
                  _buildCategoryChip('Accessories'),
                ],
              );
            }),
          ),
          // Products Grid
          Expanded(
            child: Obx(() {
              final products = productController.filteredProducts;

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
                        'No products found',
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
