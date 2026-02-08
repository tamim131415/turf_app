import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';
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
  final _authService = Get.find<AuthService>();
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
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // First load from SharedPreferences for quick display (user-specific)
      final prefs = await SharedPreferences.getInstance();
      final userId = authController.firebaseUser.value?.uid ?? '';

      if (userId.isNotEmpty) {
        setState(() {
          _profileImageUrl = prefs.getString('profile_image_url_$userId');
          _coverImageUrl = prefs.getString('cover_image_url_$userId');
        });

        // Then fetch from Firestore for the latest data
        final profileData = await _authService.getUserProfile();
        if (profileData != null) {
          setState(() {
            _profileImageUrl = profileData['profileImageUrl'] as String?;
            _coverImageUrl = profileData['coverImageUrl'] as String?;
          });

          // Update SharedPreferences with latest data
          if (_profileImageUrl != null) {
            await prefs.setString(
              'profile_image_url_$userId',
              _profileImageUrl!,
            );
          }
          if (_coverImageUrl != null) {
            await prefs.setString('cover_image_url_$userId', _coverImageUrl!);
          }
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
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
      final userId = authController.firebaseUser.value?.uid ?? '';

      if (userId.isEmpty) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      bool uploadedAny = false;

      // Upload profile image if selected
      if (_tempProfileImage != null) {
        final imageId = 'profile_$userId';
        final imageUrl = await _cloudinaryService.uploadProductImage(
          _tempProfileImage!,
          imageId,
        );

        if (imageUrl != null) {
          // Update Firestore
          await _authService.updateProfileImage(imageUrl);

          // Update SharedPreferences (user-specific key)
          await prefs.setString('profile_image_url_$userId', imageUrl);

          setState(() {
            _profileImageUrl = imageUrl;
            _tempProfileImage = null;
          });
          uploadedAny = true;
        }
      }

      // Upload cover image if selected
      if (_tempCoverImage != null) {
        final imageId = 'cover_$userId';
        final imageUrl = await _cloudinaryService.uploadProductImage(
          _tempCoverImage!,
          imageId,
        );

        if (imageUrl != null) {
          // Update Firestore
          await _authService.updateCoverImage(imageUrl);

          // Update SharedPreferences (user-specific key)
          await prefs.setString('cover_image_url_$userId', imageUrl);

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green[800],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              setState(() {
                _isEditingCover = !_isEditingCover;
                if (!_isEditingCover) {
                  _tempCoverImage = null;
                  _tempProfileImage = null;
                }
              });
            },
            tooltip: 'Edit Profile',
          ),
        ],
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
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green[700]!, Colors.green[900]!],
                    ),
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
                      // Overlay gradient for better text readability
                      if (_coverImageUrl != null || _tempCoverImage != null)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      // Save Button (Top Right) - shown when editing
                      if (_isEditingCover &&
                          (_tempCoverImage != null ||
                              _tempProfileImage != null))
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: _uploadImages,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Upload Cover Image Button (shown when editing)
                      if (_isEditingCover)
                        Positioned(
                          right: 16,
                          bottom: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: () => _pickImage(false),
                              tooltip: 'Change Cover',
                            ),
                          ),
                        ),
                      // Profile Picture
                      Positioned(
                        left: 24,
                        bottom: 16,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: Colors.green[100],
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
                                          fontSize: 42,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            // Camera button (shown when editing)
                            if (_isEditingCover)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.all(8),
                                    constraints: BoxConstraints(),
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () => _pickImage(true),
                                    tooltip: 'Change Photo',
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
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[900],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.green[700],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                // Account Section
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'ACCOUNT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildProfileTile(
                  Icons.shopping_bag,
                  'My Orders',
                  'View your order history and track deliveries',
                  () {
                    Get.toNamed('/my-orders');
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
                    Get.toNamed('/addresses');
                  },
                ),
                _buildProfileTile(
                  Icons.payment,
                  'Payment Methods',
                  'Manage your payment cards and methods',
                  () {
                    Get.toNamed('/payment-methods');
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
                SizedBox(height: 16),
                // Settings Section
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Text(
                    'SUPPORT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
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
                      Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.green[50]!, Colors.white],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Icon
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/icon.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // App Name
                              Text(
                                'Turf Mate',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Version
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              // Divider
                              Container(
                                height: 1,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.green[200]!,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),
                              // Description
                              Text(
                                'Your Premium Destination',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[900],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'for Football Gear & Accessories',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              // Features
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureChip(
                                    Icons.verified,
                                    'Authentic',
                                  ),
                                  _buildFeatureChip(
                                    Icons.local_shipping,
                                    'Fast Delivery',
                                  ),
                                  _buildFeatureChip(
                                    Icons.support_agent,
                                    '24/7 Support',
                                  ),
                                ],
                              ),
                              SizedBox(height: 32),
                              // Close Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => Get.back(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red[700]),
                            SizedBox(width: 12),
                            Text('Logout'),
                          ],
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              authController.logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  isLogout: true,
                ),
                SizedBox(height: 32),
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLogout ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout ? Colors.red[700] : Colors.green[700],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isLogout ? Colors.red[700] : Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[200]!, width: 2),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
