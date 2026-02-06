import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                authController.userName.value.isNotEmpty
                    ? authController.userName.value
                    : 'John Doe',
              ),
              accountEmail: Text(
                authController.userEmail.value.isNotEmpty
                    ? authController.userEmail.value
                    : 'john.doe@example.com',
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (authController.userName.value.isNotEmpty
                      ? authController.userName.value[0].toUpperCase()
                      : 'J'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
              decoration: BoxDecoration(color: Colors.green[700]),
            ),
            _buildProfileTile(
              Icons.shopping_bag,
              'My Orders',
              'View your order history and track deliveries',
              () {
                Get.snackbar(
                  'Coming Soon',
                  'Order history feature will be available soon',
                  backgroundColor: Colors.blue[100],
                );
              },
            ),
            _buildProfileTile(
              Icons.favorite,
              'Wishlist',
              'View and manage your favorite products',
              () {
                Get.toNamed('/wishlist');
              },
            ),
            _buildProfileTile(
              Icons.location_on,
              'Addresses',
              'Manage your delivery addresses',
              () {
                Get.snackbar(
                  'Coming Soon',
                  'Address management feature will be available soon',
                  backgroundColor: Colors.blue[100],
                );
              },
            ),
            _buildProfileTile(
              Icons.payment,
              'Payment Methods',
              'Manage your payment cards and methods',
              () {
                Get.snackbar(
                  'Coming Soon',
                  'Payment methods feature will be available soon',
                  backgroundColor: Colors.blue[100],
                );
              },
            ),
            _buildProfileTile(
              Icons.notifications,
              'Notifications',
              'View your recent notifications',
              () {
                Get.toNamed('/notifications');
              },
            ),
            Divider(thickness: 1),
            _buildProfileTile(
              Icons.settings,
              'Settings',
              'App preferences and account settings',
              () {
                Get.snackbar(
                  'Coming Soon',
                  'Settings page will be available soon',
                  backgroundColor: Colors.blue[100],
                );
              },
            ),
            _buildProfileTile(
              Icons.help,
              'Help & Support',
              'Get help and contact customer support',
              () {
                Get.snackbar(
                  'Coming Soon',
                  'Help & Support feature will be available soon',
                  backgroundColor: Colors.blue[100],
                );
              },
            ),
            _buildProfileTile(
              Icons.info_outline,
              'About',
              'App version and company information',
              () {
                Get.dialog(
                  AlertDialog(
                    title: Text('About TurfMart'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Version: 1.0.0'),
                        SizedBox(height: 8),
                        Text(
                          'Your premium destination for football gear and accessories.',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildProfileTile(
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () {
                Get.dialog(
                  AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          authController.logout();
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              isLogout: true,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red[50] : Colors.green[50],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red[700] : Colors.green[700],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red[700] : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
