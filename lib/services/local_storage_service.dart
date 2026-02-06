import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

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
  Future<void> saveCartItems(List<Product> cartItems) async {
    final cartJson = cartItems.map((product) => product.toMap()).toList();
    await _prefs.setString(_cartKey, json.encode(cartJson));
  }

  // Get cart items
  Future<List<Product>> getCartItems() async {
    final cartString = _prefs.getString(_cartKey);
    if (cartString != null) {
      final List<dynamic> cartJson = json.decode(cartString);
      return cartJson
          .map((json) => Product.fromMap(json, json['id'] ?? ''))
          .toList();
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

  // Initialize sample data
  Future<void> initializeSampleData() async {
    if (isDataInitialized()) {
      print('Sample data already exists in local storage');
      return;
    }

    // Turf/Football related sample products
    final sampleProducts = [
      Product(
        id: 'product_001',
        name: 'Argentina World Cup Jersey 2022 - Messi Edition',
        price: 4999.0,
        originalPrice: 5999.0,
        team: 'Argentina',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=1',
        rating: 4.9,
        reviewCount: 287,
        isFavorite: true,
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: [Color(0xFF87CEEB), Color(0xFFFFFFFF)], // Light Blue, White
        description:
            'Official Argentina National Team Jersey worn during the 2022 FIFA World Cup. Features Messi\'s iconic number 10. Made with premium moisture-wicking fabric.',
      ),
      Product(
        id: 'product_002',
        name: 'Brazil Seleção Home Jersey - Neymar Jr.',
        price: 4599.0,
        originalPrice: 5299.0,
        team: 'Brazil',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=2',
        rating: 4.7,
        reviewCount: 198,
        isFavorite: false,
        sizes: ['S', 'M', 'L', 'XL'],
        colors: [Color(0xFFFFD700), Color(0xFF228B22)], // Gold, Green
        description:
            'Brazil\'s iconic yellow jersey with Neymar Jr.\'s number 10. Perfect for showcasing your Brazilian football passion.',
      ),
      Product(
        id: 'product_003',
        name: 'Portugal Cristiano Ronaldo CR7 Jersey',
        price: 4799.0,
        team: 'Portugal',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=3',
        rating: 4.8,
        reviewCount: 345,
        isFavorite: true,
        sizes: ['M', 'L', 'XL'],
        colors: [Color(0xFF8B0000), Color(0xFF006400)], // Dark Red, Dark Green
        description:
            'Official Portugal jersey featuring CR7. Premium quality fabric with excellent breathability.',
      ),
      Product(
        id: 'product_004',
        name: 'Nike Mercurial Superfly 9 Elite FG',
        price: 18999.0,
        originalPrice: 21999.0,
        team: 'Nike',
        category: 'Shoes',
        imageUrl: 'https://picsum.photos/200/300?random=4',
        rating: 4.6,
        reviewCount: 156,
        isFavorite: false,
        sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'],
        colors: [Color(0xFFFF4500), Color(0xFF000000)], // Orange Red, Black
        description:
            'Nike\'s flagship football boot designed for explosive speed. Features Nike Grip technology and lightweight design.',
      ),
      Product(
        id: 'product_005',
        name: 'Adidas Predator Accuracy.1 FG',
        price: 16999.0,
        team: 'Adidas',
        category: 'Shoes',
        imageUrl: 'https://picsum.photos/200/300?random=5',
        rating: 4.5,
        reviewCount: 124,
        isFavorite: true,
        sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10'],
        colors: [Color(0xFF000000), Color(0xFFFF0000)], // Black, Red
        description:
            'Adidas Predator boots engineered for precision and control. Perfect for players who demand accuracy.',
      ),
      Product(
        id: 'product_006',
        name: 'FIFA Official Match Ball 2023',
        price: 8999.0,
        team: 'FIFA',
        category: 'Balls',
        imageUrl: 'https://picsum.photos/200/300?random=6',
        rating: 4.9,
        reviewCount: 89,
        isFavorite: false,
        sizes: ['Size 5'],
        colors: [Color(0xFFFFFFFF), Color(0xFF4169E1)], // White, Royal Blue
        description:
            'Official FIFA match ball used in professional tournaments. Premium leather with perfect weight distribution.',
      ),
      Product(
        id: 'product_007',
        name: 'Professional Goalkeeper Gloves',
        price: 3999.0,
        originalPrice: 4599.0,
        team: 'Reusch',
        category: 'Accessories',
        imageUrl: 'https://picsum.photos/200/300?random=7',
        rating: 4.4,
        reviewCount: 67,
        isFavorite: false,
        sizes: ['Size 7', 'Size 8', 'Size 9', 'Size 10'],
        colors: [Color(0xFF32CD32), Color(0xFF000000)], // Lime Green, Black
        description:
            'Professional goalkeeper gloves with superior grip technology. Excellent for amateur and professional players.',
      ),
      Product(
        id: 'product_008',
        name: 'Training Cones Set (12 pieces)',
        price: 1299.0,
        team: 'Training Pro',
        category: 'Training',
        imageUrl: 'https://picsum.photos/200/300?random=8',
        rating: 4.2,
        reviewCount: 145,
        isFavorite: false,
        sizes: ['Standard'],
        colors: [Color(0xFFFF8C00), Color(0xFF00FF00)], // Dark Orange, Lime
        description:
            'Set of 12 professional training cones for agility drills and field marking. Durable and lightweight.',
      ),
      Product(
        id: 'product_009',
        name: 'France National Team Jersey - Mbappé',
        price: 4699.0,
        team: 'France',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=9',
        rating: 4.6,
        reviewCount: 234,
        isFavorite: true,
        sizes: ['S', 'M', 'L', 'XL'],
        colors: [Color(0xFF000080), Color(0xFFFFFFFF)], // Navy Blue, White
        description:
            'France national team jersey featuring Kylian Mbappé. Represents the current world champions.',
      ),
      Product(
        id: 'product_010',
        name: 'England Home Jersey - Harry Kane',
        price: 4399.0,
        team: 'England',
        category: 'Jerseys',
        imageUrl: 'https://picsum.photos/200/300?random=10',
        rating: 4.3,
        reviewCount: 178,
        isFavorite: false,
        sizes: ['M', 'L', 'XL', 'XXL'],
        colors: [Color(0xFFFFFFFF), Color(0xFF000080)], // White, Navy Blue
        description:
            'England home jersey with Harry Kane\'s number. Classic white design with modern performance technology.',
      ),
    ];

    await saveProducts(sampleProducts);
    await setDataInitialized(true);
    print('Sample data initialized successfully in local storage');
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_productsKey);
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_cartKey);
    await _prefs.remove(_isDataInitializedKey);
  }
}
