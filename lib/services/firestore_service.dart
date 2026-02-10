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

      return productId;
    } catch (e) {
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
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      await productsCollection.doc(productId).delete();
      return true;
    } catch (e) {
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

      await ordersCollection.doc(orderId).set(orderData);

      return orderId;
    } catch (e) {
      return null;
    }
  }

  // Get user orders
  Future<List<app_models.Order>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      final orders = snapshot.docs
          .map((doc) => app_models.Order.fromFirestore(doc))
          .toList();

      // Sort by date in memory (descending - newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      return orders;
    } catch (e) {
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

      return addressId;
    } catch (e) {
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
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await addressesCollection.doc(addressId).delete();
      return true;
    } catch (e) {
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
      return true;
    } catch (e) {
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
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      await paymentMethodsCollection.doc(paymentMethodId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
