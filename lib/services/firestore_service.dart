import 'package:cloud_firestore/cloud_firestore.dart';
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
}
