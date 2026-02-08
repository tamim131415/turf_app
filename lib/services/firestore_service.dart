import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/order.dart' as app_models;
import '../models/address.dart';
import '../models/payment_method.dart';

class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find<FirestoreService>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get productsCollection =>
      _firestore.collection('products');
  CollectionReference get categoriesCollection =>
      _firestore.collection('categories');
  CollectionReference get ordersCollection => _firestore.collection('orders');
  CollectionReference get addressesCollection =>
      _firestore.collection('addresses');
  CollectionReference get paymentMethodsCollection =>
      _firestore.collection('payment_methods');

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

  // Save order to Firestore
  Future<String?> saveOrder(app_models.Order order) async {
    try {
      String orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> orderData = order.toMap();
      orderData['created_at'] = FieldValue.serverTimestamp();

      print('📦 Saving order to Firebase...');
      print('   Order ID: $orderId');
      print('   User ID: ${order.userId}');
      print('   Items count: ${order.items.length}');
      print('   Total amount: ${order.totalAmount}');

      await ordersCollection.doc(orderId).set(orderData);

      print('✅ Order saved successfully: $orderId');
      return orderId;
    } catch (e) {
      print('❌ Error saving order: $e');
      return null;
    }
  }

  // Get user orders
  Future<List<app_models.Order>> getUserOrders(String userId) async {
    try {
      print('📋 Fetching orders for user: $userId');

      QuerySnapshot snapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      print('   Found ${snapshot.docs.length} orders');

      final orders = snapshot.docs
          .map((doc) => app_models.Order.fromFirestore(doc))
          .toList();

      // Sort by date in memory (descending - newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      print('✅ Returning ${orders.length} orders');
      return orders;
    } catch (e) {
      print('❌ Error getting user orders: $e');
      return [];
    }
  }

  // Get order by ID
  Future<app_models.Order?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return app_models.Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Save address to Firestore
  Future<String?> saveAddress(Address address) async {
    try {
      String addressId = 'address_${DateTime.now().millisecondsSinceEpoch}';

      Map<String, dynamic> addressData = address.toMap();
      addressData['created_at'] = FieldValue.serverTimestamp();

      await addressesCollection.doc(addressId).set(addressData);

      print('Address saved to Firebase: $addressId');
      return addressId;
    } catch (e) {
      print('Error saving address: $e');
      return null;
    }
  }

  // Get user addresses
  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      QuerySnapshot snapshot = await addressesCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Address.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user addresses: $e');
      return [];
    }
  }

  // Update address
  Future<bool> updateAddress(
    String addressId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await addressesCollection.doc(addressId).update(updates);
      print('Address updated: $addressId');
      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await addressesCollection.doc(addressId).delete();
      print('Address deleted: $addressId');
      return true;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    }
  }

  // Save payment method
  Future<bool> savePaymentMethod(PaymentMethod paymentMethod) async {
    try {
      await paymentMethodsCollection.doc(paymentMethod.id).set({
        ...paymentMethod.toMap(),
        'created_at': FieldValue.serverTimestamp(),
      });
      print('Payment method saved: ${paymentMethod.id}');
      return true;
    } catch (e) {
      print('Error saving payment method: $e');
      return false;
    }
  }

  // Get user payment methods
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      QuerySnapshot snapshot = await paymentMethodsCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => PaymentMethod.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting payment methods: $e');
      return [];
    }
  }

  // Update payment method
  Future<bool> updatePaymentMethod(
    String paymentMethodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = FieldValue.serverTimestamp();
      await paymentMethodsCollection.doc(paymentMethodId).update(updates);
      print('Payment method updated: $paymentMethodId');
      return true;
    } catch (e) {
      print('Error updating payment method: $e');
      return false;
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      await paymentMethodsCollection.doc(paymentMethodId).delete();
      print('Payment method deleted: $paymentMethodId');
      return true;
    } catch (e) {
      print('Error deleting payment method: $e');
      return false;
    }
  }
}
