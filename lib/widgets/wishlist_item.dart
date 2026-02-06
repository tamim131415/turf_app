import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../controllers/product_controller.dart';

class WishlistItem extends StatelessWidget {
  final Product product;

  const WishlistItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => Get.toNamed('/product-detail', arguments: product),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => Get.toNamed('/product-detail', arguments: product),
          child: Text(
            product.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.team),
            SizedBox(height: 4),
            Text(
              '৳${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                productController.toggleFavorite(product);
                Get.snackbar(
                  'Removed',
                  '${product.name} removed from wishlist',
                  backgroundColor: Colors.red[100],
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.favorite, color: Colors.red, size: 20),
              ),
            ),
            GestureDetector(
              onTap: () {
                productController.addToCart(product);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
