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
      updates['updated_at'] = FieldValue.serverTimestamp();
      await productsCollection.doc(productId).update(updates);
      print('Product updated: $productId');
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
      print('Product deleted: $productId');
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

  // Add sample data with 5 products per category (25 total)
  Future<void> addSampleData() async {
    try {
      // Check if data already exists
      QuerySnapshot existingData = await productsCollection.limit(1).get();
      if (existingData.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      print('Adding sample data to Firebase...');

      // Sample products with 5 products per category (25 total)
      List<Product> sampleProducts = [
        // JERSEYS CATEGORY (5 products)
        Product(
          id: 'arg_jersey_001',
          name: 'Argentina World Cup Jersey 2022 - Messi Edition',
          price: 4999.0,
          originalPrice: 5999.0,
          team: 'Argentina',
          category: 'Jerseys',
          imageUrl:
              'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=200&h=300&fit=crop&q=80', // Argentina jersey
          rating: 4.9,
          reviewCount: 287,
          isFavorite: true,
          sizes: ['S', 'M', 'L', 'XL', 'XXL'],
          colors: [Color(0xFF87CEEB), Color(0xFFFFFFFF)], // Light Blue, White
          description:
              'Official Argentina National Team Jersey worn during the 2022 FIFA World Cup. Features Messi\'s iconic number 10.',
        ),
        Product(
          id: 'bra_jersey_002',
          name: 'Brazil Seleção Home Jersey - Neymar Jr.',
          price: 4599.0,
          originalPrice: 5299.0,
          team: 'Brazil',
          category: 'Jerseys',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=200&h=300&fit=crop&q=80',
          rating: 4.7,
          reviewCount: 198,
          isFavorite: false,
          sizes: ['S', 'M', 'L', 'XL'],
          colors: [Color(0xFFFFD700), Color(0xFF228B22)], // Gold, Green
          description:
              'Brazil\'s iconic yellow jersey with Neymar Jr.\'s number 10. Perfect for showcasing your Brazilian football passion.',
        ),
        Product(
          id: 'fra_jersey_003',
          name: 'France National Team Jersey - Mbappé',
          price: 4699.0,
          team: 'France',
          category: 'Jerseys',
          imageUrl:
              'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=200&h=300&fit=crop&q=80',
          rating: 4.6,
          reviewCount: 234,
          isFavorite: true,
          sizes: ['S', 'M', 'L', 'XL'],
          colors: [Color(0xFF000080), Color(0xFFFFFFFF)], // Navy Blue, White
          description:
              'France national team jersey featuring Kylian Mbappé. Represents the current world champions.',
        ),
        Product(
          id: 'ger_jersey_004',
          name: 'Germany Away Jersey - Müller Edition',
          price: 4299.0,
          originalPrice: 4899.0,
          team: 'Germany',
          category: 'Jerseys',
          imageUrl:
              'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=200&h=300&fit=crop&q=80',
          rating: 4.4,
          reviewCount: 167,
          isFavorite: false,
          sizes: ['M', 'L', 'XL', 'XXL'],
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)], // Black, White
          description:
              'Germany Away Jersey with advanced moisture-wicking technology. Features Müller\'s number.',
        ),
        Product(
          id: 'spa_jersey_005',
          name: 'Spain La Roja Home Jersey - Pedri',
          price: 4399.0,
          team: 'Spain',
          category: 'Jerseys',
          imageUrl:
              'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=200&h=300&fit=crop&q=80',
          rating: 4.5,
          reviewCount: 189,
          isFavorite: true,
          sizes: ['S', 'M', 'L', 'XL'],
          colors: [Color(0xFFDC143C), Color(0xFFFFD700)], // Crimson, Gold
          description:
              'Spain home jersey featuring rising star Pedri. Classic Spanish red with modern design.',
        ),

        // SHOES CATEGORY (5 products)
        Product(
          id: 'nike_mercurial_001',
          name: 'Nike Mercurial Superfly 9 Elite FG',
          price: 18999.0,
          originalPrice: 21999.0,
          team: 'Nike',
          category: 'Shoes',
          imageUrl:
              'https://images.unsplash.com/photo-1544966503-7cc5ac882d5a?w=200&h=300&fit=crop&q=80',
          rating: 4.6,
          reviewCount: 156,
          isFavorite: false,
          sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'],
          colors: [Color(0xFFFF4500), Color(0xFF000000)], // Orange Red, Black
          description:
              'Nike\'s flagship football boot designed for explosive speed. Features Nike Grip technology.',
        ),
        Product(
          id: 'adidas_predator_002',
          name: 'Adidas Predator Accuracy.1 FG',
          price: 16999.0,
          team: 'Adidas',
          category: 'Shoes',
          imageUrl:
              'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=200&h=300&fit=crop&q=80',
          rating: 4.5,
          reviewCount: 124,
          isFavorite: true,
          sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9', 'UK 10'],
          colors: [Color(0xFF000000), Color(0xFFFF0000)], // Black, Red
          description:
              'Adidas Predator boots engineered for precision and control. Perfect for players who demand accuracy.',
        ),
        Product(
          id: 'puma_future_003',
          name: 'Puma Future 1.4 Netfit FG/AG',
          price: 14999.0,
          originalPrice: 17999.0,
          team: 'Puma',
          category: 'Shoes',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.4,
          reviewCount: 98,
          isFavorite: false,
          sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10'],
          colors: [Color(0xFF00FF00), Color(0xFF000000)], // Lime, Black
          description:
              'Puma Future with revolutionary Netfit technology for customizable lacing and superior ball control.',
        ),
        Product(
          id: 'umbro_velocita_004',
          name: 'Umbro Velocita 6 Pro FG',
          price: 12999.0,
          team: 'Umbro',
          category: 'Shoes',
          imageUrl:
              'https://images.unsplash.com/photo-1606890822999-97b52c8e40b4?w=200&h=300&fit=crop&q=80',
          rating: 4.2,
          reviewCount: 76,
          isFavorite: false,
          sizes: ['UK 6', 'UK 7', 'UK 8', 'UK 9'],
          colors: [Color(0xFF4169E1), Color(0xFFFFFFFF)], // Royal Blue, White
          description:
              'Umbro Velocita designed for speed and agility. Lightweight construction with excellent touch.',
        ),
        Product(
          id: 'mizuno_morelia_005',
          name: 'Mizuno Morelia Neo III Elite',
          price: 15999.0,
          team: 'Mizuno',
          category: 'Shoes',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.7,
          reviewCount: 134,
          isFavorite: true,
          sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'],
          colors: [Color(0xFF000000), Color(0xFFFFD700)], // Black, Gold
          description:
              'Mizuno Morelia Neo III with premium K-leather upper for unmatched comfort and ball feel.',
        ),

        // BALLS CATEGORY (5 products)
        Product(
          id: 'fifa_match_ball_001',
          name: 'FIFA Official Match Ball 2023',
          price: 8999.0,
          team: 'FIFA',
          category: 'Balls',
          imageUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=300&fit=crop&q=80',
          rating: 4.9,
          reviewCount: 89,
          isFavorite: false,
          sizes: ['Size 5'],
          colors: [Color(0xFFFFFFFF), Color(0xFF4169E1)], // White, Royal Blue
          description:
              'Official FIFA match ball used in professional tournaments. Premium leather with perfect weight distribution.',
        ),
        Product(
          id: 'nike_strike_ball_002',
          name: 'Nike Strike Football Size 5',
          price: 3999.0,
          originalPrice: 4599.0,
          team: 'Nike',
          category: 'Balls',
          imageUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=300&fit=crop&q=80',
          rating: 4.3,
          reviewCount: 145,
          isFavorite: true,
          sizes: ['Size 4', 'Size 5'],
          colors: [Color(0xFFFF4500), Color(0xFF000000)], // Orange, Black
          description:
              'Nike Strike ball with excellent durability for training and matches. Perfect for all playing surfaces.',
        ),
        Product(
          id: 'adidas_tango_ball_003',
          name: 'Adidas Tango Rosario Training Ball',
          price: 2999.0,
          team: 'Adidas',
          category: 'Balls',
          imageUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=300&fit=crop&q=80',
          rating: 4.1,
          reviewCount: 67,
          isFavorite: false,
          sizes: ['Size 3', 'Size 4', 'Size 5'],
          colors: [Color(0xFFFFFFFF), Color(0xFF000000)], // White, Black
          description:
              'Adidas Tango classic design with modern performance. Great for street football and training.',
        ),
        Product(
          id: 'puma_evospeed_ball_004',
          name: 'Puma EvoSpeed 5.5 Training Ball',
          price: 3499.0,
          team: 'Puma',
          category: 'Balls',
          imageUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=300&fit=crop&q=80',
          rating: 4.2,
          reviewCount: 92,
          isFavorite: false,
          sizes: ['Size 4', 'Size 5'],
          colors: [Color(0xFF32CD32), Color(0xFF000000)], // Lime Green, Black
          description:
              'Puma EvoSpeed ball engineered for consistent performance. Excellent for training sessions.',
        ),
        Product(
          id: 'umbro_neo_ball_005',
          name: 'Umbro Neo Professional Match Ball',
          price: 6999.0,
          originalPrice: 7999.0,
          team: 'Umbro',
          category: 'Balls',
          imageUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=300&fit=crop&q=80',
          rating: 4.6,
          reviewCount: 78,
          isFavorite: true,
          sizes: ['Size 5'],
          colors: [Color(0xFFFFFFFF), Color(0xFF4169E1)], // White, Royal Blue
          description:
              'Umbro Neo professional match ball with FIFA approved quality. Premium synthetic leather construction.',
        ),

        // ACCESSORIES CATEGORY (5 products)
        Product(
          id: 'gk_gloves_001',
          name: 'Professional Goalkeeper Gloves - Reusch',
          price: 3999.0,
          originalPrice: 4599.0,
          team: 'Reusch',
          category: 'Accessories',
          imageUrl:
              'https://images.unsplash.com/photo-1622123477034-57c5dd8e72eb?w=200&h=300&fit=crop&q=80',
          rating: 4.4,
          reviewCount: 67,
          isFavorite: false,
          sizes: ['Size 7', 'Size 8', 'Size 9', 'Size 10'],
          colors: [Color(0xFF32CD32), Color(0xFF000000)], // Lime Green, Black
          description:
              'Professional goalkeeper gloves with superior grip technology. Excellent for amateur and professional players.',
        ),
        Product(
          id: 'shin_pads_002',
          name: 'Nike Mercurial Lite Shin Guards',
          price: 1999.0,
          team: 'Nike',
          category: 'Accessories',
          imageUrl:
              'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=200&h=300&fit=crop&q=80',
          rating: 4.3,
          reviewCount: 134,
          isFavorite: true,
          sizes: ['XS', 'S', 'M', 'L'],
          colors: [Color(0xFF000000), Color(0xFFFF4500)], // Black, Orange
          description:
              'Nike Mercurial shin guards with lightweight protection. Anatomical design for maximum comfort.',
        ),
        Product(
          id: 'captain_armband_003',
          name: 'Captain Armband Set (2 pieces)',
          price: 799.0,
          team: 'Generic',
          category: 'Accessories',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=200&h=300&fit=crop&q=80',
          rating: 4.0,
          reviewCount: 45,
          isFavorite: false,
          sizes: ['One Size'],
          colors: [Color(0xFFFFD700), Color(0xFF000000)], // Gold, Black
          description:
              'Premium captain armbands made from durable elastic material. Adjustable fit for all players.',
        ),
        Product(
          id: 'water_bottle_004',
          name: 'Sports Water Bottle - 1L Capacity',
          price: 1299.0,
          originalPrice: 1599.0,
          team: 'Hydro Pro',
          category: 'Accessories',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=200&h=300&fit=crop&q=80',
          rating: 4.5,
          reviewCount: 89,
          isFavorite: false,
          sizes: ['1L'],
          colors: [Color(0xFF4169E1), Color(0xFF000000)], // Royal Blue, Black
          description:
              'BPA-free sports water bottle with leak-proof design. Perfect for training sessions and matches.',
        ),
        Product(
          id: 'football_socks_005',
          name: 'Performance Football Socks Pack (3 pairs)',
          price: 1599.0,
          team: 'Adidas',
          category: 'Accessories',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=200&h=300&fit=crop&q=80',
          rating: 4.2,
          reviewCount: 156,
          isFavorite: true,
          sizes: ['S', 'M', 'L', 'XL'],
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFF000000),
            Color(0xFF4169E1),
          ], // White, Black, Blue
          description:
              'High-performance football socks with cushioning and moisture-wicking. Pack of 3 pairs.',
        ),

        // TRAINING CATEGORY (5 products)
        Product(
          id: 'training_cones_001',
          name: 'Training Cones Set (12 pieces)',
          price: 1299.0,
          team: 'Training Pro',
          category: 'Training',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.2,
          reviewCount: 145,
          isFavorite: false,
          sizes: ['Standard'],
          colors: [Color(0xFFFF8C00), Color(0xFF00FF00)], // Dark Orange, Lime
          description:
              'Set of 12 professional training cones for agility drills and field marking. Durable and lightweight.',
        ),
        Product(
          id: 'agility_ladder_002',
          name: 'Speed Agility Ladder - 20 Rungs',
          price: 2299.0,
          originalPrice: 2799.0,
          team: 'Fitness Pro',
          category: 'Training',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.6,
          reviewCount: 87,
          isFavorite: true,
          sizes: ['20 Rungs'],
          colors: [Color(0xFFFFFF00), Color(0xFF000000)], // Yellow, Black
          description:
              'Professional agility ladder for speed and coordination training. Adjustable rungs with carry bag.',
        ),
        Product(
          id: 'resistance_bands_003',
          name: 'Football Training Resistance Bands Set',
          price: 1899.0,
          team: 'Strength Pro',
          category: 'Training',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.3,
          reviewCount: 112,
          isFavorite: false,
          sizes: ['Light', 'Medium', 'Heavy'],
          colors: [
            Color(0xFF32CD32),
            Color(0xFFFF0000),
            Color(0xFF0000FF),
          ], // Green, Red, Blue
          description:
              'Set of 3 resistance bands for football-specific strength training. Different resistance levels included.',
        ),
        Product(
          id: 'speed_hurdles_004',
          name: 'Adjustable Speed Hurdles (6 pack)',
          price: 3299.0,
          team: 'Athletic Pro',
          category: 'Training',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.4,
          reviewCount: 76,
          isFavorite: true,
          sizes: ['6-12 inch height'],
          colors: [Color(0xFFFF8C00), Color(0xFFFFFFFF)], // Orange, White
          description:
              'Adjustable speed hurdles for plyometric training. Heights from 6 to 12 inches, includes carry bag.',
        ),
        Product(
          id: 'coordination_poles_005',
          name: 'Coordination Training Poles Set (10 pieces)',
          price: 2599.0,
          originalPrice: 2999.0,
          team: 'Training Elite',
          category: 'Training',
          imageUrl:
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=300&fit=crop&q=80',
          rating: 4.1,
          reviewCount: 63,
          isFavorite: false,
          sizes: ['150cm height'],
          colors: [Color(0xFFFFFF00), Color(0xFF000000)], // Yellow, Black
          description:
              'Professional coordination poles for slalom training and agility drills. Flexible and durable construction.',
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
