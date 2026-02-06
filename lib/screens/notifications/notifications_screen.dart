import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.snackbar(
                'Success',
                'All notifications marked as read',
                backgroundColor: Colors.green[100],
              );
            },
            child: Text(
              'Mark all as read',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildNotificationItem(
            'Order Shipped',
            'Your order #TM-2024-00123 has been shipped and will arrive in 2-3 business days',
            Icons.local_shipping,
            Colors.green,
            '2 hours ago',
            false,
          ),
          _buildNotificationItem(
            'Special Offer',
            '30% off on all national team jerseys this weekend! Limited time offer.',
            Icons.local_offer,
            Colors.orange,
            '1 day ago',
            false,
          ),
          _buildNotificationItem(
            'New Arrival',
            'Check out the new Brazil 2024 kit collection with exclusive designs',
            Icons.new_releases,
            Colors.blue,
            '2 days ago',
            false,
          ),
          _buildNotificationItem(
            'Payment Successful',
            'Your payment of ৳4,998 has been processed successfully',
            Icons.payment,
            Colors.purple,
            '3 days ago',
            true,
          ),
          _buildNotificationItem(
            'Welcome!',
            'Welcome to TurfMart! Enjoy exclusive deals and premium football gear.',
            Icons.waving_hand,
            Colors.indigo,
            '1 week ago',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
    bool isRead,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[200]! : Colors.green[100]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(
                color: isRead ? Colors.grey[600] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        onTap: () {
          Get.snackbar(
            'Notification',
            'Opening notification: $title',
            backgroundColor: Colors.blue[100],
          );
        },
      ),
    );
  }
}
