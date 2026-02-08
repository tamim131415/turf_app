import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/product.dart';
import '../../app/routes/app_routes.dart';
import '../../controllers/product_controller.dart';

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Product initialProduct = Get.arguments as Product;
    final ProductController productController = Get.find<ProductController>();

    return Obx(() {
      // Get the latest product from the controller
      final Product product =
          productController.products.firstWhereOrNull(
            (p) => p.id == initialProduct.id,
          ) ??
          initialProduct;

      final stockStatus = product.quantity == 0
          ? 'Out of Stock'
          : product.quantity < 10
          ? 'Low Stock'
          : 'In Stock';

      final stockColor = product.quantity == 0
          ? Colors.red
          : product.quantity < 10
          ? Colors.orange
          : Colors.green;

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.grey[700]),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.EDIT_PRODUCT, arguments: product);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.edit, color: Colors.blue[700]),
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(
                        context,
                        product,
                        productController,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.delete, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Center(
                        child: Hero(
                          tag: 'product_${product.id}',
                          child: Container(
                            height: 280,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 80,
                                                color: Colors.grey[400],
                                              ),
                                            );
                                          },
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Product Name
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),

                      // Team and Category
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.team,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Price
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          if (product.originalPrice != null)
                            Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Text(
                                '\$${product.originalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Stock Status Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: stockColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: stockColor, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Stock Status',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: stockColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    stockStatus,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 40,
                                  color: stockColor,
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available Quantity',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${product.quantity} units',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: stockColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (product.quantity < 10 && product.quantity > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange[700],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Low stock alert! Consider restocking soon.',
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (product.quantity == 0)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[700],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Out of stock! Restock immediately.',
                                        style: TextStyle(
                                          color: Colors.red[900],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Product Info
                      Text(
                        'Product Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),

                      // Brand
                      _buildInfoRow('Brand', product.brand),
                      Divider(),

                      // Rating
                      _buildInfoRow(
                        'Rating',
                        '${product.rating.toStringAsFixed(1)} ⭐ (${product.reviewCount} reviews)',
                      ),
                      Divider(),

                      // Available Sizes
                      if (product.sizes.isNotEmpty) ...[
                        _buildInfoRow(
                          'Available Sizes',
                          product.sizes.join(', '),
                        ),
                        Divider(),
                      ],

                      // Description
                      if (product.description.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Product product,
    ProductController productController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await productController.deleteProduct(product.id);
                  // Navigation is handled in the controller
                } catch (e) {
                  // Error handling is done in the controller
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
