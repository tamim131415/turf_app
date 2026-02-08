import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class LocalStorageService extends GetxService {
  static LocalStorageService get instance => Get.find<LocalStorageService>();

  late SharedPreferences _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys for local storage
  static const String _productsKey = 'turf_products';
  static const String _favoritesKey = 'turf_favorites';
  static const String _cartKey = 'turf_cart';
  static const String _isDataInitializedKey = 'turf_data_initialized';

  // Save products to local storage
  Future<void> saveProducts(List<Product> products) async {
    final productsJson = products.map((product) => product.toMap()).toList();
    await _prefs.setString(_productsKey, json.encode(productsJson));
  }

  // Get products from local storage
  Future<List<Product>> getProducts() async {
    final productsString = _prefs.getString(_productsKey);
    if (productsString != null) {
      final List<dynamic> productsJson = json.decode(productsString);
      return productsJson
          .map((json) => Product.fromMap(json, json['id'] ?? ''))
          .toList();
    }
    return [];
  }

  // Save single product
  Future<void> saveProduct(Product product) async {
    final products = await getProducts();
    final existingIndex = products.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      products[existingIndex] = product;
    } else {
      products.add(product);
    }

    await saveProducts(products);
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId, bool isFavorite) async {
    final products = await getProducts();
    final productIndex = products.indexWhere((p) => p.id == productId);

    if (productIndex != -1) {
      final product = products[productIndex];
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        originalPrice: product.originalPrice,
        team: product.team,
        category: product.category,
        imageUrl: product.imageUrl,
        rating: product.rating,
        reviewCount: product.reviewCount,
        isFavorite: isFavorite,
        sizes: product.sizes,
        colors: product.colors,
        description: product.description,
      );

      products[productIndex] = updatedProduct;
      await saveProducts(products);
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getProducts();
    if (category == 'All') {
      return products;
    }
    return products.where((p) => p.category == category).toList();
  }

  // Get favorite products
  Future<List<Product>> getFavoriteProducts() async {
    final products = await getProducts();
    return products.where((p) => p.isFavorite).toList();
  }

  // Save cart items
  Future<void> saveCartItems(List<CartItem> cartItems) async {
    final cartJson = cartItems.map((item) => item.toMap()).toList();
    await _prefs.setString(_cartKey, json.encode(cartJson));
  }

  // Get cart items
  Future<List<CartItem>> getCartItems() async {
    final cartString = _prefs.getString(_cartKey);
    if (cartString != null) {
      final List<dynamic> cartJson = json.decode(cartString);
      return cartJson.map((json) => CartItem.fromMap(json)).toList();
    }
    return [];
  }

  // Check if data is initialized
  bool isDataInitialized() {
    return _prefs.getBool(_isDataInitializedKey) ?? false;
  }

  // Mark data as initialized
  Future<void> setDataInitialized(bool initialized) async {
    await _prefs.setBool(_isDataInitializedKey, initialized);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_productsKey);
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_cartKey);
    await _prefs.remove(_isDataInitializedKey);
  }
}
