import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class LocalImageService extends GetxService {
  static LocalImageService get instance => Get.find<LocalImageService>();

  // Get app's cache directory
  Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  // Get app's documents directory (permanent storage)
  Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  // Save image to local storage
  Future<String?> saveImageLocally(
    File imageFile,
    String productId, {
    bool permanent = false,
    bool compress = true,
  }) async {
    try {
      print('💾 Saving image locally for product: $productId');

      // Choose directory (cache vs permanent)
      Directory directory = permanent
          ? await getDocumentsDirectory()
          : await getCacheDirectory();

      // Create products subfolder
      Directory productsDir = Directory('${directory.path}/products');
      if (!await productsDir.exists()) {
        await productsDir.create(recursive: true);
      }

      // Generate unique filename
      String fileName =
          '${permanent ? '' : 'scaled_'}${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String localPath = path.join(productsDir.path, fileName);

      File savedFile;

      if (compress) {
        // Compress and resize image
        print('🔧 Compressing image...');
        savedFile = await _compressAndSaveImage(imageFile, localPath);
      } else {
        // Just copy the file
        savedFile = await imageFile.copy(localPath);
      }

      print('✅ Image saved locally: $localPath');
      print('📏 File size: ${await savedFile.length()} bytes');

      Get.snackbar(
        'Success',
        'Image saved to device storage!',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
        snackPosition: SnackPosition.TOP,
        icon: Icon(Icons.save_alt, color: Colors.blue[800]),
      );

      return localPath;
    } catch (e) {
      print('❌ Error saving image locally: $e');
      Get.snackbar(
        'Error',
        'Failed to save image: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  // Compress and resize image
  Future<File> _compressAndSaveImage(
    File originalFile,
    String outputPath,
  ) async {
    // Read original image
    Uint8List imageBytes = Uint8List.fromList(await originalFile.readAsBytes());
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Could not decode image');
    }

    // Resize if too large (max 800x800)
    img.Image resizedImage = originalImage;
    if (originalImage.width > 800 || originalImage.height > 800) {
      resizedImage = img.copyResize(
        originalImage,
        width: originalImage.width > originalImage.height ? 800 : null,
        height: originalImage.height > originalImage.width ? 800 : null,
      );
    }

    // Encode with compression (85% quality)
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);

    // Write to file
    File outputFile = File(outputPath);
    await outputFile.writeAsBytes(Uint8List.fromList(compressedBytes));

    return outputFile;
  }

  // Get all locally saved product images
  Future<List<String>> getLocalImages() async {
    try {
      Directory cacheDir = await getCacheDirectory();
      Directory docsDir = await getDocumentsDirectory();

      List<String> imagePaths = [];

      // Check both directories
      for (Directory dir in [cacheDir, docsDir]) {
        Directory productsDir = Directory('${dir.path}/products');
        if (await productsDir.exists()) {
          List<FileSystemEntity> files = productsDir.listSync();
          for (FileSystemEntity file in files) {
            if (file is File && file.path.toLowerCase().endsWith('.jpg')) {
              imagePaths.add(file.path);
            }
          }
        }
      }

      return imagePaths;
    } catch (e) {
      print('Error getting local images: $e');
      return [];
    }
  }

  // Delete local image
  Future<bool> deleteLocalImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        print('🗑️ Deleted local image: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting local image: $e');
      return false;
    }
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      List<String> images = await getLocalImages();
      int totalImages = images.length;
      int totalSize = 0;

      // Calculate total size
      for (String imagePath in images) {
        File file = File(imagePath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }

      return {
        'totalImages': totalImages,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'cacheDirectory': (await getCacheDirectory()).path,
        'documentsDirectory': (await getDocumentsDirectory()).path,
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {};
    }
  }

  // Clear cache images only
  Future<void> clearCache() async {
    try {
      Directory cacheDir = await getCacheDirectory();
      Directory cacheProductsDir = Directory('${cacheDir.path}/products');

      if (await cacheProductsDir.exists()) {
        await cacheProductsDir.delete(recursive: true);
        print('🧹 Cache cleared');

        Get.snackbar(
          'Success',
          'Cache cleared successfully!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
