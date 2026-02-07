import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/cart_item.dart';
import '../../app/routes/app_routes.dart';

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
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  onPressed: () => Get.back(),
                  child: Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }

        // Group products by ID and count quantities
        Map<String, int> productQuantities = {};
        for (var product in controller.cartItems) {
          productQuantities[product.id] =
              (productQuantities[product.id] ?? 0) + 1;
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: productQuantities.length,
                itemBuilder: (context, index) {
                  final productId = productQuantities.keys.elementAt(index);
                  final product = controller.cartItems.firstWhere(
                    (p) => p.id == productId,
                  );
                  final quantity = productQuantities[productId]!;

                  return CartItem(product: product, quantity: quantity);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:', style: TextStyle(fontSize: 16)),
                      Obx(
                        () => Text(
                          '৳${controller.cartTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
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
                      Text('Shipping:', style: TextStyle(fontSize: 16)),
                      Text('৳100.00', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '৳${(controller.cartTotal + 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
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
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                      onPressed: () {
                        Get.toNamed(Routes.CHECKOUT);
                      },
                      child: Text(
                        'PROCEED TO CHECKOUT',
                        style: TextStyle(fontSize: 16),
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
