import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';

class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find<FirestoreService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get productsCollection =>
      _firestore.collection('products');
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');

  // Get all products
  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await productsCollection.get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Add a product
  Future<String?> addProduct(Product product) async {
    try {
      // Generate unique ID if product doesn't have one
      String productId = product.id.isNotEmpty
          ? product.id
          : 'product_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> productData = product.toMap();
      productData['created_at'] = FieldValue.serverTimestamp();
      productData['updated_at'] = FieldValue.serverTimestamp();

      // Use set instead of add to use custom ID
      await productsCollection.doc(productId).set(productData);

      print('Product added to Firebase: ${product.name} with ID: $productId');
      return productId;
    } catch (e) {
      print('Error adding product: $e');
      return null;
    }
  }

  // Update a product
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await productsCollection.doc(productId).update(updates);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String productId, bool isFavorite) async {
    try {
      await productsCollection.doc(productId).update({
        'isFavorite': isFavorite,
      });
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot;
      if (category == 'All') {
        snapshot = await productsCollection.get();
      } else {
        snapshot = await productsCollection
            .where('category', isEqualTo: category)
            .get();
      }
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Get favorite products
  Future<List<Product>> getFavoriteProducts() async {
    try {
      QuerySnapshot snapshot = await productsCollection
          .where('isFavorite', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting favorite products: $e');
      return [];
    }
  }

  // Listen to products stream (real-time updates)
  Stream<List<Product>> getProductsStream() {
    return productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Add sample data (for initial setup)
  Future<void> addSampleData() async {
    try {
      // Check if data already exists
      QuerySnapshot existingData = await productsCollection.limit(1).get();
      if (existingData.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      print('Adding sample data to Firebase...');

      // Sample products from your demo service
      List<Product> sampleProducts = [
        Product(
          id: 'arg_jersey_001',
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
          id: 'bra_jersey_002',
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
          id: 'por_jersey_003',
          name: 'Portugal Cristiano Ronaldo CR7 Jersey',
          price: 4799.0,
          team: 'Portugal',
          category: 'Jerseys',
          imageUrl: 'https://picsum.photos/200/300?random=3',
          rating: 4.8,
          reviewCount: 345,
          isFavorite: true,
          sizes: ['M', 'L', 'XL'],
          colors: [
            Color(0xFF8B0000),
            Color(0xFF006400),
          ], // Dark Red, Dark Green
          description:
              'Official Portugal jersey featuring CR7. Premium quality fabric with excellent breathability.',
        ),
        Product(
          id: 'nike_boots_004',
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
          id: 'adidas_boots_005',
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
          id: 'fifa_ball_006',
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
          id: 'gk_gloves_007',
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
          id: 'training_cones_008',
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
          id: 'fra_jersey_009',
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
          id: 'eng_jersey_010',
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

      // Add each product to Firestore with proper structure
      int successCount = 0;
      for (Product product in sampleProducts) {
        try {
          Map<String, dynamic> productData = {
            'name': product.name,
            'price': product.price,
            'originalPrice': product.originalPrice,
            'team': product.team,
            'category': product.category,
            'imageUrl': product.imageUrl,
            'rating': product.rating,
            'reviewCount': product.reviewCount,
            'isFavorite': product.isFavorite,
            'sizes': product.sizes,
            'colors': product.colors.map((color) => color.value).toList(),
            'description': product.description,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          };

          await productsCollection.doc(product.id).set(productData);
          successCount++;
          print('Added product: ${product.name}');
        } catch (e) {
          print('Failed to add product ${product.name}: $e');
        }
      }

      print(
        'Sample data added successfully: $successCount/${sampleProducts.length} products',
      );
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }
}
