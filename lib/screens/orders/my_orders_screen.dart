import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/order_controller.dart';
import '../../utils/app_strings.dart';
import '../../models/order.dart' as app_models;
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.put(OrderController());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myOrders),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (orderController.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 100,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Text(
                  'No Orders Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your order history will appear here',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => orderController.loadOrders(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(app_models.Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

    Color statusColor;
    IconData statusIcon;

    switch (order.orderStatus.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'shipped':
        statusColor = Colors.purple;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateFormat.format(order.orderDate),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      SizedBox(width: 4),
                      Text(
                        order.orderStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 24),
            // Order Items
            ...order.items.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '৳${item.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 24),
            // Order Total and Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      order.paymentMethod,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '৳${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            // Delivery Address
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(order.address, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
