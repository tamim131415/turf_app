import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:crypto/crypto.dart';

class CloudinaryService extends GetxService {
  static CloudinaryService get instance => Get.find<CloudinaryService>();

  // 🔥 আপনার Cloudinary credentials এখানে দিন
  static const String CLOUD_NAME = 'dmebauqnq'; // ✅ Updated
  static const String API_KEY = '811429924971981'; // ✅ Updated
  static const String API_SECRET = 'UmTZiu9xOxhn_6pt5VagF2BHl_g'; // ✅ Updated

  static const String UPLOAD_URL =
      'https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/upload';

  final dio.Dio _dio = dio.Dio();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
    _testConnection();
  }

  void _initializeDio() {
    _dio.options = dio.BaseOptions(
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 60),
      sendTimeout: Duration(seconds: 60),
    );
  }

  Future<void> _testConnection() async {
    try {
      print('🌤️ Testing Cloudinary connection...');
      print('📋 Using Cloud Name: $CLOUD_NAME');
      print('📋 Using API Key: $API_KEY');

      // Simple test - check if cloud name is accessible
      final response = await _dio.get(
        'https://res.cloudinary.com/$CLOUD_NAME/image/upload/test.png',
        options: dio.Options(
          validateStatus: (status) =>
              status! < 500, // Accept 4xx as valid response
        ),
      );

      // 404 is expected for non-existent image, but means cloud name is valid
      if (response.statusCode == 404 || response.statusCode == 200) {
        print('✅ Cloudinary connection successful!');
        print(
          '🌐 Cloud accessible at: https://res.cloudinary.com/$CLOUD_NAME/',
        );
      } else {
        print('⚠️ Unexpected response code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Cloudinary connection test failed: $e');

      // Check if it's a cloud name issue
      if (e.toString().contains('404')) {
        print('💡 Cloud name "$CLOUD_NAME" might be incorrect');
        print('💡 Please verify your cloud name from Cloudinary dashboard');
      } else {
        print('💡 Please check your internet connection');
      }
    }
  }

  // Generate signature for authenticated uploads
  String _generateSignature(Map<String, dynamic> params) {
    // Remove api_key from params for signature (Cloudinary requirement)
    Map<String, dynamic> signatureParams = Map.from(params);
    signatureParams.remove('api_key');

    // Sort parameters alphabetically
    var sortedKeys = signatureParams.keys.toList()..sort();

    // Create query string in format key1=value1&key2=value2
    String queryString = sortedKeys
        .map((key) => '$key=${signatureParams[key]}')
        .join('&');

    // Add API secret at the end (without & separator)
    String stringToSign = queryString + API_SECRET;

    print('🔐 Signature string: $stringToSign');

    // Generate SHA1 hash
    var bytes = utf8.encode(stringToSign);
    var digest = sha1.convert(bytes);

    String signature = digest.toString();
    print('🔐 Generated signature: $signature');

    return signature;
  }

  // Upload image to Cloudinary
  Future<String?> uploadProductImage(File imageFile, String productId) async {
    try {
      if (CLOUD_NAME == 'your_cloud_name') {
        Get.snackbar(
          'Configuration Error',
          'Please setup Cloudinary credentials first',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }

      print('🌤️ Starting Cloudinary upload for product: $productId');
      print('📁 File path: ${imageFile.path}');
      print('📏 File size: ${await imageFile.length()} bytes');

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Selected file does not exist');
      }

      // Prepare upload parameters (simplified for testing)
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      String publicId =
          'products/${productId}_$timestamp'; // Fixed: remove duplicate path

      Map<String, dynamic> params = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
        'folder': 'turf_app/products',
      };

      print('📋 Upload parameters (before signature):');
      params.forEach((key, value) {
        print('  $key: $value');
      });

      // Generate signature
      String signature = _generateSignature(params);

      // Create form data
      dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(imageFile.path),
        'api_key': API_KEY,
        'timestamp': params['timestamp'],
        'public_id': params['public_id'],
        'folder': params['folder'],
        'signature': signature,
      });

      print('🚀 Uploading to Cloudinary...');

      // Upload with progress tracking
      dio.Response response = await _dio.post(
        UPLOAD_URL,
        data: formData,
        onSendProgress: (sent, total) {
          double progress = sent / total;
          print('📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        String imageUrl = responseData['secure_url'];

        print('✅ Cloudinary upload successful!');
        print('🌐 Image URL: $imageUrl');
        print('📊 Upload info:');
        print('  - Public ID: ${responseData['public_id']}');
        print('  - Format: ${responseData['format']}');
        print('  - Size: ${responseData['bytes']} bytes');
        print('  - Width: ${responseData['width']}px');
        print('  - Height: ${responseData['height']}px');

        return imageUrl;
      } else {
        throw Exception(
          'Upload failed with status code: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ ERROR during Cloudinary upload:');
      print('🔥 Error: $e');
      print('📍 Stack trace: $stackTrace');

      String errorMessage = 'Failed to upload image';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else if (e.toString().contains('401') ||
          e.toString().contains('authentication')) {
        errorMessage = 'Authentication failed. Please try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Upload timeout. Try again with smaller image.';
      }

      Get.snackbar(
        'Upload Error',
        errorMessage,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error, color: Colors.red[800]),
      );
      return null;
    }
  }

  // Delete image from Cloudinary
  Future<bool> deleteProductImage(String imageUrl) async {
    try {
      // Extract public_id from Cloudinary URL
      Uri uri = Uri.parse(imageUrl);
      String path = uri.path;

      // Extract public_id (remove version and file extension)
      RegExp publicIdRegex = RegExp(r'/(?:v\d+/)?(.+)\.[^.]+$');
      Match? match = publicIdRegex.firstMatch(path);

      if (match == null) {
        throw Exception('Could not extract public_id from URL');
      }

      String publicId = match.group(1)!;
      print('🗑️ Deleting Cloudinary image: $publicId');

      // Prepare deletion parameters
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      Map<String, dynamic> params = {
        'public_id': publicId,
        'timestamp': timestamp.toString(),
      };

      String signature = _generateSignature(params);

      // Delete request
      dio.FormData formData = dio.FormData.fromMap({
        'public_id': publicId,
        'api_key': API_KEY,
        'timestamp': params['timestamp'],
        'signature': signature,
      });

      dio.Response response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$CLOUD_NAME/image/destroy',
        data: formData,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;
        String result = responseData['result'] ?? '';

        if (result == 'ok') {
          print('✅ Cloudinary image deleted successfully');
          return true;
        } else {
          print('⚠️ Cloudinary deletion result: $result');
          return false;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error deleting Cloudinary image: $e');
      return false;
    }
  }

  // Get upload usage info
  Future<Map<String, dynamic>> getUsageInfo() async {
    try {
      final response = await _dio.get(
        'https://api.cloudinary.com/v1_1/$CLOUD_NAME/usage',
        options: dio.Options(
          headers: {
            'Authorization':
                'Basic ${base64Encode(utf8.encode('$API_KEY:$API_SECRET'))}',
          },
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return {
          'used_percent': data['storage']?['used_percent'] ?? 0,
          'used_size': data['storage']?['used_size'] ?? 0,
          'limit': data['storage']?['limit'] ?? 0,
          'transformations': data['transformations']?['usage'] ?? 0,
          'bandwidth': data['bandwidth']?['usage'] ?? 0,
        };
      }

      return {};
    } catch (e) {
      print('Error getting Cloudinary usage: $e');
      return {};
    }
  }
}
