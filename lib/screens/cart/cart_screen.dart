import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/cart_item.dart';
import '../../app/routes/app_routes.dart';
import '../../utils/app_strings.dart';
import '../../utils/responsive_helper.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: ResponsiveHelper.isMobile(context) ? 80 : 100,
                  color: Colors.grey[400],
                ),
                SizedBox(height: ResponsiveHelper.getPadding(context, small: 16, medium: 20, large: 24)),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 20, large: 22),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getPadding(context, small: 16, medium: 20, large: 24)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  onPressed: () => Get.back(),
                  child: Text(AppStrings.continueShopping),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];
                  return CartItemCard(cartItem: cartItem);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, small: 16, medium: 20, large: 24)),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.subtotalLabel,
                        style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18)),
                      ),
                      Obx(
                        () => Text(
                          '৳${controller.cartTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.shippingLabel,
                        style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18)),
                      ),
                      Text(
                        AppStrings.shippingAmount,
                        style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '৳${(controller.cartTotal + 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, small: 18, medium: 19, large: 20),
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.isMobile(context) ? 50 : 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.checkout);
                      },
                      child: Text(
                        'PROCEED TO CHECKOUT',
                        style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, small: 16, medium: 17, large: 18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
