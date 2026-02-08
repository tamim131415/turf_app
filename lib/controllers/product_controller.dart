import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';

class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> favoriteProducts = <Product>[].obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString selectedTeam = 'All'.obs;
  final RxString selectedBrand = 'All'.obs;
  final RxString filterType = 'category'.obs; // 'category', 'team', or 'brand'
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
        products.value = firestoreProducts;
        isOnline.value = true;
        // Save to local storage as backup
        if (firestoreProducts.isNotEmpty) {
          await _localStorageService.saveProducts(firestoreProducts);
        }
      } catch (e) {
        print('Firestore failed: $e, trying local storage...');
        isOnline.value = false;

        // Fallback to local storage
        final localProducts = await _localStorageService.getProducts();
        products.value = localProducts;
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
          brand: product.brand,
          imageUrl: product.imageUrl,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isFavorite: newFavoriteStatus,
          sizes: product.sizes,
          colors: product.colors,
          description: product.description,
          quantity: product.quantity,
        );
      }

      updateFavoriteProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite: $e');
    }
  }

  void updateFavoriteProducts() {
    favoriteProducts.value = products.where((p) => p.isFavorite).toList();
  }

  void addToCart(Product product, {int quantity = 1}) async {
    // Check if product already in cart
    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      // Product exists, increment quantity
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      // Add new product with specified quantity
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    await _localStorageService.saveCartItems(cartItems);
    Get.snackbar('Success', '${product.name} added to cart');
  }

  void removeFromCart(CartItem cartItem) async {
    cartItems.remove(cartItem);
    await _localStorageService.saveCartItems(cartItems);
    Get.snackbar('Success', '${cartItem.product.name} removed from cart');
  }

  void updateCartItemQuantity(CartItem cartItem, int newQuantity) async {
    if (newQuantity <= 0) {
      removeFromCart(cartItem);
      return;
    }

    final index = cartItems.indexWhere(
      (item) => item.product.id == cartItem.product.id,
    );

    if (index != -1) {
      cartItems[index].quantity = newQuantity;
      cartItems.refresh();
      await _localStorageService.saveCartItems(cartItems);
    }
  }

  void incrementCartItem(CartItem cartItem) async {
    updateCartItemQuantity(cartItem, cartItem.quantity + 1);
  }

  void decrementCartItem(CartItem cartItem) async {
    updateCartItemQuantity(cartItem, cartItem.quantity - 1);
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
      filterType.value = 'category';
      selectedCategory.value = category;
      selectedTeam.value = 'All';
      selectedBrand.value = 'All';
      isLoading.value = true;

      // Try Firebase first, fallback to local
      List<Product> categoryProducts = [];
      try {
        if (isOnline.value) {
          final firestoreProducts = await _firestoreService
              .getProductsByCategory(category);
          categoryProducts = firestoreProducts;
        } else {
          throw Exception('Offline mode');
        }
      } catch (e) {
        final localProducts = await _localStorageService.getProductsByCategory(
          category,
        );
        categoryProducts = localProducts;
      }

      products.value = categoryProducts;
      updateFavoriteProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByTeam(String team) async {
    try {
      filterType.value = 'team';
      selectedTeam.value = team;
      selectedCategory.value = 'All';
      selectedBrand.value = 'All';
      isLoading.value = true;

      // Load all products and filter by team
      try {
        if (isOnline.value) {
          final firestoreProducts = await _firestoreService
              .getProductsByCategory('All');
          products.value = firestoreProducts;
        } else {
          final localProducts = await _localStorageService
              .getProductsByCategory('All');
          products.value = localProducts;
        }
      } catch (e) {
        print('Error loading products: $e');
      }

      updateFavoriteProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByBrand(String brand) async {
    try {
      filterType.value = 'brand';
      selectedBrand.value = brand;
      selectedCategory.value = 'All';
      selectedTeam.value = 'All';
      isLoading.value = true;

      // Load all products and filter by brand (currently we'll show all)
      try {
        if (isOnline.value) {
          final firestoreProducts = await _firestoreService
              .getProductsByCategory('All');
          products.value = firestoreProducts;
        } else {
          final localProducts = await _localStorageService
              .getProductsByCategory('All');
          products.value = localProducts;
        }
      } catch (e) {
        print('Error loading products: $e');
      }

      updateFavoriteProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to filter products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Product> get filteredProducts {
    if (filterType.value == 'team' && selectedTeam.value != 'All') {
      return products.where((p) => p.team == selectedTeam.value).toList();
    } else if (filterType.value == 'brand' && selectedBrand.value != 'All') {
      return products.where((p) => p.brand == selectedBrand.value).toList();
    } else if (selectedCategory.value == 'All') {
      return products;
    }
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  double get cartTotal {
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Place order and reduce inventory
  Future<void> placeOrder() async {
    try {
      isLoading.value = true;

      // Reduce inventory for each cart item
      for (CartItem cartItem in cartItems) {
        final productIndex = products.indexWhere(
          (p) => p.id == cartItem.product.id,
        );

        if (productIndex != -1) {
          // Update product quantity
          final updatedProduct = Product(
            id: products[productIndex].id,
            name: products[productIndex].name,
            price: products[productIndex].price,
            originalPrice: products[productIndex].originalPrice,
            team: products[productIndex].team,
            category: products[productIndex].category,
            brand: products[productIndex].brand,
            imageUrl: products[productIndex].imageUrl,
            rating: products[productIndex].rating,
            reviewCount: products[productIndex].reviewCount,
            isFavorite: products[productIndex].isFavorite,
            sizes: products[productIndex].sizes,
            colors: products[productIndex].colors,
            description: products[productIndex].description,
            quantity: products[productIndex].quantity - cartItem.quantity,
          );

          // Update in Firebase
          try {
            await _firestoreService.updateProduct(
              updatedProduct.id,
              updatedProduct.toMap(),
            );
          } catch (e) {
            print('Failed to update product in Firebase: $e');
          }

          // Update locally
          products[productIndex] = updatedProduct;
          await _localStorageService.saveProducts(products);
        }
      }

      // Clear cart
      cartItems.clear();
      await _localStorageService.saveCartItems(cartItems);

      Get.snackbar(
        'Success',
        'Order placed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
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

      if (localProducts.isNotEmpty) {
        // Upload each product to Firebase
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
      } else {
        Get.snackbar(
          'No Data',
          'No products found to sync',
          backgroundColor: Colors.orange,
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

      final localProducts = await _localStorageService.getProducts();

      if (localProducts.isEmpty) {
        Get.snackbar(
          'No Data',
          'No products found to upload',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        isLoading.value = false;
        return;
      }

      Get.snackbar(
        'Uploading',
        'Sending ${localProducts.length} products to Firebase...',
        duration: Duration(seconds: 2),
      );

      int successCount = 0;
      int totalCount = localProducts.length;

      for (int i = 0; i < localProducts.length; i++) {
        try {
          Product product = localProducts[i];
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
          brand: product.brand,
          imageUrl: product.imageUrl,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isFavorite: product.isFavorite,
          sizes: product.sizes,
          colors: product.colors,
          description: product.description,
          quantity: product.quantity,
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

  // Delete all products
  Future<void> deleteAllProducts() async {
    try {
      isLoading.value = true;

      // Try to delete all from Firebase
      try {
        final batch = FirebaseFirestore.instance.batch();
        for (var product in products) {
          final docRef = FirebaseFirestore.instance
              .collection('products')
              .doc(product.id);
          batch.delete(docRef);
        }
        await batch.commit();
        print('All products deleted from Firebase');
        isOnline.value = true;
      } catch (e) {
        print('Firebase batch delete failed: $e');
        isOnline.value = false;
      }

      // Clear local products list
      products.clear();
      filteredProducts.clear();
      favoriteProducts.clear();
      cartItems.clear();

      // Clear local storage
      await _localStorageService.saveProducts([]);

      Get.snackbar(
        'Success',
        'All products have been deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete all products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a single product
  Future<void> deleteProduct(String productId) async {
    try {
      isLoading.value = true;

      // Try to delete from Firebase
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .delete();
        print('Product deleted from Firebase');
        isOnline.value = true;
      } catch (e) {
        print('Firebase delete failed: $e');
        isOnline.value = false;
      }

      // Remove from local products list
      products.removeWhere((p) => p.id == productId);
      filteredProducts.removeWhere((p) => p.id == productId);
      favoriteProducts.removeWhere((p) => p.id == productId);
      cartItems.removeWhere((p) => p.product.id == productId);

      // Update local storage
      await _localStorageService.saveProducts(products);

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Product has been deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      // Navigate back to inventory screen after a short delay
      await Future.delayed(Duration(milliseconds: 300));
      Get.back();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to delete product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    try {
      isLoading.value = true;

      // Try to update in Firebase first
      try {
        await _firestoreService.updateProduct(product.id, product.toMap());
        print('Product updated in Firebase: ${product.name}');
        isOnline.value = true;
      } catch (e) {
        print('Firebase update failed: $e');
        isOnline.value = false;
      }

      // Update local product list
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
      }

      // Update filtered products if it contains this product
      final filteredIndex = filteredProducts.indexWhere(
        (p) => p.id == product.id,
      );
      if (filteredIndex != -1) {
        filteredProducts[filteredIndex] = product;
      }

      // Update favorites if it contains this product
      final favoriteIndex = favoriteProducts.indexWhere(
        (p) => p.id == product.id,
      );
      if (favoriteIndex != -1) {
        favoriteProducts[favoriteIndex] = product;
      }

      // Save to local storage
      await _localStorageService.saveProducts(products);

      print('Product updated locally: ${product.name}');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
