import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/cart_item.dart';
import '../utils/responsive_helper.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPadding(context, small: 16, medium: 20, large: 24),
        vertical: ResponsiveHelper.getPadding(context, small: 8, medium: 10, large: 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 12, medium: 14, large: 16)),
        child: Row(
          children: [
            // Product Image
            Container(
              width: ResponsiveHelper.isMobile(context) ? 80 : (ResponsiveHelper.isTablet(context) ? 100 : 120),
              height: ResponsiveHelper.isMobile(context) ? 80 : (ResponsiveHelper.isTablet(context) ? 100 : 120),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(cartItem.product.imageUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '৳${cartItem.product.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveHelper.getFontSize(context, small: 14, medium: 15, large: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, size: ResponsiveHelper.getIconSize(context)),
                              onPressed: () {
                                controller.decrementCartItem(cartItem);
                              },
                              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 4, medium: 5, large: 6)),
                              constraints: BoxConstraints(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getPadding(context, small: 12, medium: 14, large: 16),
                              ),
                              child: Obx(() {
                                final updatedCartItem = controller.cartItems
                                    .firstWhere(
                                      (item) =>
                                          item.product.id ==
                                          cartItem.product.id,
                                      orElse: () => cartItem,
                                    );
                                return Text(
                                  '${updatedCartItem.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18),
                                  ),
                                );
                              }),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, size: ResponsiveHelper.getIconSize(context)),
                              onPressed: () {
                                controller.incrementCartItem(cartItem);
                              },
                              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 4, medium: 5, large: 6)),
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        '৳${cartItem.totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18),
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                controller.removeFromCart(cartItem);
              },
            ),
          ],
        ),
      ),
    );
  }
}
