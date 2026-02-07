import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turf_app/services/cloudinary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authController = Get.find<AuthController>();
  final _cloudinaryService = Get.find<CloudinaryService>();
  final _picker = ImagePicker();

  String? _profileImageUrl;
  String? _coverImageUrl;
  File? _tempProfileImage;
  File? _tempCoverImage;
  bool _isLoading = false;
  bool _isEditingCover = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profile_image_url');
      _coverImageUrl = prefs.getString('cover_image_url');
    });
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Show local preview
      final imageFile = File(image.path);
      setState(() {
        if (isProfile) {
          _tempProfileImage = imageFile;
        } else {
          _tempCoverImage = imageFile;
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _uploadImages() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      bool uploadedAny = false;

      // Upload profile image if selected
      if (_tempProfileImage != null) {
        final imageId = 'profile_${authController.userEmail.value}';
        final imageUrl = await _cloudinaryService.uploadProductImage(
          _tempProfileImage!,
          imageId,
        );

        if (imageUrl != null) {
          await prefs.setString('profile_image_url', imageUrl);
          setState(() {
            _profileImageUrl = imageUrl;
            _tempProfileImage = null;
          });
          uploadedAny = true;
        }
      }

      // Upload cover image if selected
      if (_tempCoverImage != null) {
        final imageId = 'cover_${authController.userEmail.value}';
        final imageUrl = await _cloudinaryService.uploadProductImage(
          _tempCoverImage!,
          imageId,
        );

        if (imageUrl != null) {
          await prefs.setString('cover_image_url', imageUrl);
          setState(() {
            _coverImageUrl = imageUrl;
            _tempCoverImage = null;
          });
          uploadedAny = true;
        }
      }

      if (uploadedAny) {
        setState(() => _isEditingCover = false);
        Get.snackbar(
          'Success',
          'Image(s) uploaded successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        final email = authController.userEmail.value.isNotEmpty
            ? authController.userEmail.value
            : 'No email';
        final username = authController.userName.value.isNotEmpty
            ? authController.userName.value
            : (email != 'No email' ? email.split('@')[0] : 'User');

        return Stack(
          children: [
            ListView(
              children: [
                // Cover Image Section
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    image: _tempCoverImage != null
                        ? DecorationImage(
                            image: FileImage(_tempCoverImage!),
                            fit: BoxFit.cover,
                          )
                        : _coverImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_coverImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Edit/Save Toggle Button (Top Right)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              _isEditingCover ? Icons.check : Icons.edit,
                              color: Colors.green[700],
                              size: 20,
                            ),
                            onPressed: () {
                              if (_isEditingCover &&
                                  (_tempCoverImage != null ||
                                      _tempProfileImage != null)) {
                                // Upload when tick is clicked
                                _uploadImages();
                              } else {
                                setState(() {
                                  _isEditingCover = !_isEditingCover;
                                  if (!_isEditingCover) {
                                    _tempCoverImage = null;
                                    _tempProfileImage = null;
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      // Upload Cover Image Button (shown when editing)
                      if (_isEditingCover)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _pickImage(false),
                            ),
                          ),
                        ),
                      // Profile Picture
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: _tempProfileImage != null
                                  ? FileImage(_tempProfileImage!)
                                  : _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : null,
                              child:
                                  (_tempProfileImage == null &&
                                      _profileImageUrl == null)
                                  ? Text(
                                      username.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            // Camera button (shown when editing)
                            if (_isEditingCover)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.green[700],
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: () => _pickImage(true),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // User Info Section
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Divider(),
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
            ),
            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
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
