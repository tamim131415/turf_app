import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/wishlist_item.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();
    final bool canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        automaticallyImplyLeading: canGoBack,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Clear Wishlist'),
                  content: Text(
                    'Are you sure you want to remove all items from your wishlist?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Clear all favorites
                        for (var product
                            in productController.favoriteProducts) {
                          productController.toggleFavorite(product);
                        }
                        Get.back();
                        Get.snackbar('Success', 'Wishlist cleared');
                      },
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        return productController.favoriteProducts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your wishlist is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Start adding your favorite products',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => Get.toNamed('/explore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        'Start Shopping',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: productController.favoriteProducts.length,
                itemBuilder: (context, index) {
                  return WishlistItem(
                    product: productController.favoriteProducts[index],
                  );
                },
              );
      }),
    );
  }
}
