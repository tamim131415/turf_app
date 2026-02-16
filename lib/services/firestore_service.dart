import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/order.dart' as app_models;
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/review.dart';

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
  CollectionReference get reviewsCollection => _firestore.collection('reviews');

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

  // Increment product soldCount (when order is delivered)
  Future<bool> incrementProductSoldCount(String productId, int quantity) async {
    try {
      await productsCollection.doc(productId).update({
        'soldCount': FieldValue.increment(quantity),
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Incremented soldCount for product $productId by $quantity');
      return true;
    } catch (e) {
      debugPrint('❌ Error incrementing soldCount: $e');
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

  // Get all orders (Admin)
  Future<List<app_models.Order>> getAllOrders() async {
    try {
      debugPrint('🔄 Fetching all orders from Firestore...');
      QuerySnapshot snapshot = await ordersCollection.get();

      debugPrint('📦 Found ${snapshot.docs.length} order documents');

      final orders = snapshot.docs
          .map((doc) {
            try {
              return app_models.Order.fromFirestore(doc);
            } catch (e) {
              debugPrint('❌ Error parsing order ${doc.id}: $e');
              return null;
            }
          })
          .whereType<app_models.Order>()
          .toList();

      debugPrint('✅ Successfully parsed ${orders.length} orders');

      // Sort by date in memory (descending - newest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

      return orders;
    } catch (e) {
      debugPrint('❌ Error in getAllOrders: $e');
      return [];
    }
  }

  // Update order (Admin)
  Future<bool> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      debugPrint('📝 Updating order: $orderId');
      debugPrint('📝 Update data: $updates');

      await ordersCollection.doc(orderId).update(updates);

      debugPrint('✅ Order updated successfully in Firestore');

      // Verify update
      final doc = await ordersCollection.doc(orderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint('✅ Verified orderStatus: ${data['orderStatus']}');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error updating order: $e');
      return false;
    }
  }

  // ==================== Review Methods ====================

  // Save a review
  Future<String?> saveReview(Review review) async {
    try {
      debugPrint('💾 Saving review for product: "${review.productId}"');
      debugPrint('   Review ID: ${review.id}');
      debugPrint('   Rating: ${review.rating}');
      debugPrint(
        '   Comment: ${review.comment.substring(0, review.comment.length > 50 ? 50 : review.comment.length)}...',
      );

      final reviewData = review.toMap();
      debugPrint('   Review data to save: $reviewData');

      await reviewsCollection.doc(review.id).set(reviewData);
      debugPrint('✅ Review saved to Firestore');

      // Update product rating and review count
      debugPrint(
        '🔄 Triggering product rating update for: "${review.productId}"',
      );
      await _updateProductRating(review.productId);
      debugPrint('✅ Product rating update completed');

      return review.id;
    } catch (e) {
      debugPrint('❌ Error saving review: $e');
      return null;
    }
  }

  // Get review by order and product
  Future<Review?> getReviewByOrderAndProduct(
    String orderId,
    String productId,
  ) async {
    try {
      final snapshot = await reviewsCollection
          .where('orderId', isEqualTo: orderId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Review.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('❌ Error getting review: $e');
      return null;
    }
  }

  // Get all reviews for a product
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final snapshot = await reviewsCollection
          .where('productId', isEqualTo: productId)
          .get();

      final reviews = snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();

      // Sort in memory instead of Firestore query (no index needed)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return reviews;
    } catch (e) {
      debugPrint('❌ Error getting product reviews: $e');
      return [];
    }
  }

  // Update product rating based on all reviews
  Future<void> _updateProductRating(String productId) async {
    try {
      debugPrint('🔄 Updating rating for product: $productId');

      final reviews = await getProductReviews(productId);
      debugPrint('📊 Found ${reviews.length} reviews for product $productId');

      if (reviews.isEmpty) {
        debugPrint('⚠️ No reviews found, skipping rating update');
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var review in reviews) {
        debugPrint('  ⭐ Review rating: ${review.rating}');
        totalRating += review.rating;
      }
      double averageRating = totalRating / reviews.length;

      debugPrint(
        '📈 Calculated average: $averageRating from $totalRating total',
      );

      // Update product
      await productsCollection.doc(productId).update({
        'rating': averageRating,
        'reviewCount': reviews.length,
      });

      // Verify update
      final doc = await productsCollection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        debugPrint(
          '✅ Verified in Firestore - rating: ${data['rating']}, reviewCount: ${data['reviewCount']}',
        );
      }

      debugPrint(
        '✅ Updated product $productId rating: $averageRating (${reviews.length} reviews)',
      );
    } catch (e) {
      debugPrint('❌ Error updating product rating: $e');
    }
  }

  // ==================== SUPPORT TICKETS ====================

  // Create a new support ticket
  Future<String?> createSupportTicket({
    required String userId,
    required String userName,
    required String userEmail,
    required String issue,
  }) async {
    try {
      final ticketId = DateTime.now().millisecondsSinceEpoch.toString();
      final ticket = {
        'id': ticketId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'issue': issue,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'replies': [],
        'hasUnreadReplies': false,
      };

      await _firestore.collection('supportTickets').doc(ticketId).set(ticket);
      debugPrint('✅ Support ticket created: $ticketId');
      return ticketId;
    } catch (e) {
      debugPrint('❌ Error creating support ticket: $e');
      return null;
    }
  }

  // Get all support tickets (for admin)
  Stream<List<Map<String, dynamic>>> getAllSupportTickets() {
    return _firestore
        .collection('supportTickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  // Get user's support tickets
  Stream<List<Map<String, dynamic>>> getUserSupportTickets(String userId) {
    try {
      return _firestore
          .collection('supportTickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => doc.data()).toList();
          })
          .handleError((error) {
            debugPrint('❌ Error in getUserSupportTickets: $error');
            // If index error, return empty list
            return <Map<String, dynamic>>[];
          });
    } catch (e) {
      debugPrint('❌ Error creating getUserSupportTickets stream: $e');
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  // Get a single support ticket
  Future<Map<String, dynamic>?> getSupportTicket(String ticketId) async {
    try {
      final doc = await _firestore
          .collection('supportTickets')
          .doc(ticketId)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('❌ Error getting support ticket: $e');
      return null;
    }
  }

  // Get support ticket as stream (for real-time updates)
  Stream<Map<String, dynamic>?> getSupportTicketStream(String ticketId) {
    return _firestore
        .collection('supportTickets')
        .doc(ticketId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Add reply to support ticket
  Future<void> addTicketReply({
    required String ticketId,
    required String message,
    required bool isAdmin,
    required String senderName,
  }) async {
    try {
      final replyId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final reply = {
        'id': replyId,
        'message': message,
        'isAdmin': isAdmin,
        'senderName': senderName,
        'createdAt': Timestamp.fromDate(
          now,
        ), // Use Timestamp instead of FieldValue
      };

      final updateData = {
        'replies': FieldValue.arrayUnion([reply]),
        'updatedAt': FieldValue.serverTimestamp(),
        'hasUnreadReplies': !isAdmin, // If admin replies, user has unread
      };

      if (isAdmin) {
        updateData['status'] = 'in-progress';
      }

      await _firestore
          .collection('supportTickets')
          .doc(ticketId)
          .update(updateData);

      debugPrint('✅ Reply added to ticket: $ticketId');
    } catch (e) {
      debugPrint('❌ Error adding ticket reply: $e');
      rethrow;
    }
  }

  // Update support ticket status
  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _firestore.collection('supportTickets').doc(ticketId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Ticket status updated: $ticketId -> $status');
    } catch (e) {
      debugPrint('❌ Error updating ticket status: $e');
      rethrow;
    }
  }

  // Mark ticket replies as read (for user)
  Future<void> markTicketRepliesAsRead(String ticketId) async {
    try {
      await _firestore.collection('supportTickets').doc(ticketId).update({
        'hasUnreadReplies': false,
      });
      debugPrint('✅ Ticket marked as read: $ticketId');
    } catch (e) {
      debugPrint('❌ Error marking ticket as read: $e');
    }
  }

  // Get count of unread tickets (for user)
  Future<int> getUnreadTicketsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('supportTickets')
          .where('userId', isEqualTo: userId)
          .where('hasUnreadReplies', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting unread tickets count: $e');
      return 0;
    }
  }

  // Get count of pending tickets (for admin)
  Future<int> getPendingTicketsCount() async {
    try {
      final snapshot = await _firestore
          .collection('supportTickets')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting pending tickets count: $e');
      return 0;
    }
  }
}
