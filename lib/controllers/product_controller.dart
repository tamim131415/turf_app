import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> favoriteProducts = <Product>[].obs;
  final RxList<Product> cartItems = <Product>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isOnline = true.obs;

  final FirestoreService _firestoreService = FirestoreService.instance;
  final LocalStorageService _localStorageService = LocalStorageService.instance;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
    loadProducts();
  }

  // Load products with Firebase/Local fallback
  void loadProducts() async {
    try {
      isLoading.value = true;

      // Try Firebase first
      try {
        final firestoreProducts = await _firestoreService.getProducts();
        if (firestoreProducts.isNotEmpty) {
          products.value = firestoreProducts;
          isOnline.value = true;
          // Save to local storage as backup
          await _localStorageService.saveProducts(firestoreProducts);
        } else {
          // If Firebase is empty, initialize with sample data
          print('Firebase is empty, adding sample data...');
          await _firestoreService.addSampleData();

          // Try loading again after adding sample data
          final newFirestoreProducts = await _firestoreService.getProducts();
          if (newFirestoreProducts.isNotEmpty) {
            products.value = newFirestoreProducts;
            isOnline.value = true;
            await _localStorageService.saveProducts(newFirestoreProducts);
          } else {
            throw Exception('Failed to load data after adding samples');
          }
        }
      } catch (e) {
        print('Firestore failed: $e, trying local storage...');
        isOnline.value = false;

        // Fallback to local storage
        final localProducts = await _localStorageService.getProducts();
        if (localProducts.isNotEmpty) {
          products.value = localProducts;
        } else {
          // Initialize sample data if nothing exists
          await _localStorageService.initializeSampleData();
          products.value = await _localStorageService.getProducts();
        }
      }

      updateFavoriteProducts();
      Get.snackbar(
        'Status',
        isOnline.value ? 'Connected to Firebase' : 'Working Offline',
        backgroundColor: isOnline.value
            ? null
            : Get.theme.colorScheme.secondary,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favorite with dual storage
  void toggleFavorite(Product product) async {
    try {
      final newFavoriteStatus = !product.isFavorite;

      // Update local storage immediately
      await _localStorageService.toggleFavorite(product.id, newFavoriteStatus);

      // Try to update Firebase in background
      if (isOnline.value) {
        try {
          await _firestoreService.toggleFavorite(product.id, newFavoriteStatus);
        } catch (e) {
          print('Firebase update failed: $e');
          isOnline.value = false;
        }
      }

      // Update local product list
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = Product(
          id: product.id,
          name: product.name,
          price: product.price,
          originalPrice: product.originalPrice,
          team: product.team,
          category: product.category,
          imageUrl: product.imageUrl,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isFavorite: newFavoriteStatus,
          sizes: product.sizes,
          colors: product.colors,
          description: product.description,
        );
      }

      updateFavoriteProducts();
      Get.snackbar(
        'Success',
        newFavoriteStatus ? 'Added to favorites' : 'Removed from favorites',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite: $e');
    }
  }

  void updateFavoriteProducts() {
    favoriteProducts.value = products.where((p) => p.isFavorite).toList();
  }

  void addToCart(Product product) async {
    cartItems.add(product);
    await _localStorageService.saveCartItems(cartItems);
    Get.snackbar('Success', '${product.name} added to cart');
  }

  void removeFromCart(Product product) async {
    cartItems.remove(product);
    await _localStorageService.saveCartItems(cartItems);
    Get.snackbar('Success', '${product.name} removed from cart');
  }

  // Load cart items from local storage
  void loadCartItems() async {
    try {
      cartItems.value = await _localStorageService.getCartItems();
    } catch (e) {
      print('Error loading cart items: $e');
    }
  }

  void filterByCategory(String category) async {
    try {
      selectedCategory.value = category;
      isLoading.value = true;

      // Try Firebase first, fallback to local
      try {
        if (isOnline.value) {
          final firestoreProducts = await _firestoreService
              .getProductsByCategory(category);
          products.value = firestoreProducts;
        } else {
          throw Exception('Offline mode');
        }
      } catch (e) {
        final localProducts = await _localStorageService.getProductsByCategory(
          category,
        );
        products.value = localProducts;
      }

      updateFavoriteProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    if (selectedCategory.value == 'All') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  double get cartTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.price);
  }

  // Initialize sample data (force local initialization)
  void initializeSampleData() async {
    try {
      isLoading.value = true;
      await _localStorageService.clearAllData();
      await _localStorageService.initializeSampleData();
      loadProducts(); // Reload after initialization
      Get.snackbar('Success', 'Sample data loaded successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize data: $e');
    }
  }

  // Sync local data to Firebase when connection is restored
  void syncToFirebase() async {
    try {
      isLoading.value = true;
      Get.snackbar(
        'Syncing',
        'Uploading data to Firebase...',
        duration: Duration(seconds: 2),
      );

      final localProducts = await _localStorageService.getProducts();

      if (localProducts.isEmpty) {
        // Initialize sample data first if none exists
        await _localStorageService.initializeSampleData();
        final sampleProducts = await _localStorageService.getProducts();

        // Upload each sample product to Firebase
        int successCount = 0;
        for (Product product in sampleProducts) {
          try {
            await _firestoreService.addProduct(product);
            successCount++;
          } catch (e) {
            print('Failed to upload product ${product.name}: $e');
          }
        }

        isOnline.value = successCount > 0;
        Get.snackbar(
          'Upload Complete',
          'Successfully uploaded $successCount products to Firebase!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        // Upload existing local data
        int successCount = 0;
        for (Product product in localProducts) {
          try {
            await _firestoreService.addProduct(product);
            successCount++;
          } catch (e) {
            print('Failed to upload product ${product.name}: $e');
          }
        }

        isOnline.value = successCount > 0;
        Get.snackbar(
          'Sync Complete',
          'Successfully synced $successCount products to Firebase!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

      // Reload data from Firebase to confirm
      await Future.delayed(Duration(seconds: 1));
      loadProducts();
    } catch (e) {
      Get.snackbar(
        'Sync Error',
        'Failed to sync data: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Test Firebase connection manually
  void testFirebaseConnection() async {
    try {
      isLoading.value = true;

      // Try to read from Firebase
      final testProducts = await _firestoreService.getProducts();
      isOnline.value = true;

      Get.snackbar(
        'Firebase Test',
        'Connection successful! Found ${testProducts.length} products.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isOnline.value = false;
      Get.snackbar(
        'Firebase Test',
        'Connection failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Force upload local data to Firebase (regardless of online status)
  void forceUploadToFirebase() async {
    try {
      isLoading.value = true;

      // Get or create local data
      final localProducts = await _localStorageService.getProducts();
      List<Product> productsToUpload = localProducts;

      if (productsToUpload.isEmpty) {
        await _localStorageService.initializeSampleData();
        productsToUpload = await _localStorageService.getProducts();
      }

      Get.snackbar(
        'Uploading',
        'Sending ${productsToUpload.length} products to Firebase...',
        duration: Duration(seconds: 2),
      );

      int successCount = 0;
      int totalCount = productsToUpload.length;

      for (int i = 0; i < productsToUpload.length; i++) {
        try {
          Product product = productsToUpload[i];
          await _firestoreService.addProduct(product);
          successCount++;

          // Show progress
          if (i % 2 == 0) {
            // Update every 2 products
            Get.snackbar(
              'Progress',
              'Uploaded ${i + 1}/$totalCount products...',
              duration: Duration(seconds: 1),
            );
          }
        } catch (e) {
          print('Failed to upload product: $e');
        }
      }

      if (successCount > 0) {
        isOnline.value = true;
        Get.snackbar(
          '✅ Upload Success!',
          'Successfully uploaded $successCount/$totalCount products to Firebase database!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );

        // Reload from Firebase to verify
        await Future.delayed(Duration(seconds: 1));
        loadProducts();
      } else {
        Get.snackbar(
          'Upload Failed',
          'No products were uploaded. Check your internet connection.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Upload Error',
        'Failed to upload: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      isLoading.value = true;

      // Try to add to Firebase first
      String? productId = await _firestoreService.addProduct(product);

      if (productId != null) {
        // Product was successfully added to Firebase
        // Create a new product instance with the Firebase ID
        Product updatedProduct = Product(
          id: productId,
          name: product.name,
          price: product.price,
          originalPrice: product.originalPrice,
          team: product.team,
          category: product.category,
          imageUrl: product.imageUrl,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isFavorite: product.isFavorite,
          sizes: product.sizes,
          colors: product.colors,
          description: product.description,
        );

        products.add(updatedProduct);
        isOnline.value = true;

        // Also save to local storage as backup
        await _localStorageService.saveProducts(products);
      } else {
        // Firebase failed, add to local storage only
        products.add(product);
        await _localStorageService.saveProducts(products);
        isOnline.value = false;
      }
    } catch (e) {
      // If everything fails, still try to add locally
      try {
        products.add(product);
        await _localStorageService.saveProducts(products);
        isOnline.value = false;
      } catch (localError) {
        // Re-throw to let the caller handle the error
        rethrow;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
