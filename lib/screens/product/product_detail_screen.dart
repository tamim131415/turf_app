import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive_helper.dart';

class ProductDetailController extends GetxController {
  final RxString selectedSize = ''.obs;
  final RxInt quantity = 1.obs;

  void selectSize(String size) {
    selectedSize.value = size;
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }
}

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({super.key});

  final ProductDetailController detailController = Get.put(
    ProductDetailController(),
  );
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments as Product;

    // Initialize with first size if available
    if (product.sizes.isNotEmpty &&
        detailController.selectedSize.value.isEmpty) {
      detailController.selectedSize.value = product.sizes.first;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button and Share
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 16, medium: 20, large: 24)),
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
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Get the latest product state from controller
                      final currentProduct = productController.products
                          .firstWhereOrNull((p) => p.id == product.id);
                      if (currentProduct != null) {
                        productController.toggleFavorite(currentProduct);
                        Get.snackbar(
                          currentProduct.isFavorite
                              ? 'Removed from Wishlist'
                              : 'Added to Wishlist',
                          currentProduct.isFavorite
                              ? '${currentProduct.name} removed from wishlist'
                              : '${currentProduct.name} added to wishlist',
                          backgroundColor: currentProduct.isFavorite
                              ? Colors.red[100]
                              : Colors.green[100],
                          duration: Duration(seconds: 2),
                        );
                      }
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
                      child: Obx(() {
                        final isFavorite = productController.favoriteProducts
                            .any((p) => p.id == product.id);
                        return Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[700],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            // Product Image
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: ResponsiveHelper.isMobile(context) ? 300 : (ResponsiveHelper.isTablet(context) ? 400 : 500),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Product Info
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 20, medium: 24, large: 28)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getPadding(context, small: 8, medium: 10, large: 12)),
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, small: 24, medium: 26, large: 28),
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getPadding(context, small: 16, medium: 18, large: 20)),
                          // Rating and Reviews
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: ResponsiveHelper.getFontSize(context, small: 16, medium: 18, large: 20),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '৳${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: ResponsiveHelper.getFontSize(context, small: 28, medium: 30, large: 32),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                  if (product.originalPrice != null) ...[
                                    SizedBox(width: 12),
                                    Text(
                                      '৳${product.originalPrice!.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'SAVE ৳${(product.originalPrice! - product.price).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ResponsiveHelper.getFontSize(context, small: 12, medium: 13, large: 14),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 8),
                              // Total Price
                              Obx(
                                () => Text(
                                  'Total: ৳${(product.price * detailController.quantity.value).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Stock Availability
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: product.quantity > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: product.quantity > 0
                                    ? Colors.green[200]!
                                    : Colors.red[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  product.quantity > 0
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: product.quantity > 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                  size: ResponsiveHelper.getIconSize(context),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  product.quantity > 0
                                      ? 'In Stock (${product.quantity} available)'
                                      : 'Out of Stock',
                                  style: TextStyle(
                                    color: product.quantity > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.getFontSize(context, small: 14, medium: 15, large: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // Description
                          Text(
                            'Product Description',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          // Size Selection (Only for Jerseys and Shoes)
                          if ((product.category == 'Jerseys' ||
                                  product.category == 'Shoes') &&
                              product.sizes.isNotEmpty) ...[
                            Text(
                              'Select Size',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: product.sizes.length,
                                itemBuilder: (context, index) {
                                  return Obx(() {
                                    final size = product.sizes[index];
                                    final isSelected =
                                        detailController.selectedSize.value ==
                                        size;

                                    return GestureDetector(
                                      onTap: () =>
                                          detailController.selectSize(size),
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green[700]
                                              : Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.green[700]!
                                                : Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            size,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                          // Quantity Selection
                          Row(
                            children: [
                              Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed:
                                          detailController.decrementQuantity,
                                      icon: Icon(Icons.remove, size: 20),
                                    ),
                                    Obx(
                                      () => Text(
                                        '${detailController.quantity.value}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed:
                                          detailController.incrementQuantity,
                                      icon: Icon(Icons.add, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // Action Buttons
                          if (product.quantity > 0)
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        productController.addToCart(
                                          product,
                                          quantity:
                                              detailController.quantity.value,
                                        );
                                      },
                                      child: Text(
                                        AppStrings.addToCart.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        elevation: 5,
                                      ),
                                      onPressed: () {
                                        productController.addToCart(
                                          product,
                                          quantity:
                                              detailController.quantity.value,
                                        );
                                        Get.toNamed(Routes.cart);
                                      },
                                      child: Text(
                                        'BUY NOW',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: null,
                                child: Text(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
