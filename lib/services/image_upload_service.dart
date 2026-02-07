import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageUploadService extends GetxService {
  static ImageUploadService get instance => Get.find<ImageUploadService>();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getter for storage instance (for testing purposes)
  FirebaseStorage get storage => _storage;

  @override
  void onInit() {
    super.onInit();
    _testFirebaseStorageConnection();
  }

  // Test Firebase Storage connection
  Future<void> _testFirebaseStorageConnection() async {
    try {
      print('🔥 Testing Firebase Storage connection...');

      // Try to get storage bucket info
      final ref = _storage.ref();
      print('📦 Storage bucket: ${ref.bucket}');

      // Try to list root directory (should work even if empty)
      await ref.list(ListOptions(maxResults: 1));

      print('✅ Firebase Storage connection successful!');
    } catch (e) {
      print('❌ Firebase Storage connection failed: $e');
      print('🚨 Please check Firebase configuration and Storage rules');
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      print('🔥 Starting image upload for product: $productId');
      print('📁 File path: ${imageFile.path}');
      print('📏 File size: ${await imageFile.length()} bytes');

      // Check if file exists
      if (!await imageFile.exists()) {
        print('❌ File does not exist');
        throw Exception('Selected file does not exist');
      }

      // Create a unique filename
      final String fileName =
          'products/${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      print('📝 Upload filename: $fileName');

      // Get reference to the file location
      final Reference storageRef = _storage.ref().child(fileName);
      print('🎯 Storage reference: ${storageRef.fullPath}');

      // Show upload progress
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.green[700]),
              SizedBox(height: 16),
              Text('Uploading image...'),
              SizedBox(height: 8),
              Text(
                'File: ${fileName.split('/').last}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      print('🚀 Starting Firebase upload...');

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'productId': productId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      print('⏳ Waiting for upload completion...');
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      print('✅ Upload completed successfully!');
      print('📊 Upload state: ${snapshot.state}');
      print('📈 Bytes transferred: ${snapshot.bytesTransferred}');

      print('🔗 Getting download URL...');
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Close loading dialog
      Get.back();

      print('🎉 Image upload successful!');
      print('🌐 Download URL: $downloadUrl');

      // Show success message
      Get.snackbar(
        'Success',
        'Image uploaded successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.cloud_done, color: Colors.green[800]),
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ ERROR during image upload:');
      print('🔥 Error: $e');
      print('📍 Stack trace: $stackTrace');

      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Determine error type
      String errorMessage = 'Failed to upload image';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Check Firebase Storage rules.';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'Storage quota exceeded';
      }

      Get.snackbar(
        'Upload Error',
        '$errorMessage\n\nError: ${e.toString()}',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
      return null;
    }
  }

  // Delete image from Firebase Storage
  Future<bool> deleteProductImage(String imageUrl) async {
    try {
      // Extract file path from download URL
      final Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();

      print('Image deleted successfully: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Get storage usage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      // List all files in products directory
      final ListResult result = await _storage.ref('products').listAll();

      int totalFiles = result.items.length;
      int totalSize = 0;

      // Calculate total size (approximate)
      for (Reference ref in result.items) {
        try {
          final FullMetadata metadata = await ref.getMetadata();
          totalSize += metadata.size ?? 0;
        } catch (e) {
          // Skip if metadata not available
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {'totalFiles': 0, 'totalSize': 0, 'totalSizeMB': '0.00'};
    }
  }

  // Compress image if needed (basic implementation)
  Future<File> compressImage(File imageFile) async {
    // For now, return the original file
    // You can add image compression logic here using packages like flutter_image_compress
    return imageFile;
  }
}
