import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as app_models;
import '../models/order_status_history.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/app_strings.dart';

class OrderController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<app_models.Order> orders = <app_models.Order>[].obs;
  final RxList<app_models.Order> allOrders = <app_models.Order>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.uid;

      if (userId != null) {
        orders.value = await _firestoreService.getUserOrders(userId);
      }
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToLoadOrders);
    } finally {
      isLoading.value = false;
    }
  }

  // Admin: Load all orders (for all users)
  Future<void> loadAllOrders() async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Loading all orders...');

      final fetchedOrders = await _firestoreService.getAllOrders();
      allOrders.value = fetchedOrders;

      debugPrint('✅ Loaded ${allOrders.length} orders');

      if (allOrders.isEmpty) {
        debugPrint('⚠️ No orders found in database');
      }
    } catch (e) {
      debugPrint('❌ Error loading orders: $e');
      Get.snackbar(
        AppStrings.error,
        'Failed to load orders: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withValues(alpha: 0.1),
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Admin: Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    required String updatedBy,
    String? note,
    String? trackingNumber,
  }) async {
    try {
      isLoading.value = true;
      debugPrint('\n🔄 Starting order status update...');
      debugPrint('📋 Order ID: $orderId');
      debugPrint('📋 New Status: $newStatus');

      // Get current order
      final order = await _firestoreService.getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }
      debugPrint('✅ Current order status: ${order.orderStatus}');

      // Create new status history entry
      final statusHistory = OrderStatusHistory(
        status: newStatus,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
        note: note,
      );

      // Prepare update data
      Map<String, dynamic> updateData = {
        'orderStatus': newStatus,
        'statusHistory': FieldValue.arrayUnion([statusHistory.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add timestamp fields based on status
      switch (newStatus) {
        case 'Confirmed':
          updateData['confirmedAt'] = FieldValue.serverTimestamp();
          break;
        case 'Shipped':
          updateData['shippedAt'] = FieldValue.serverTimestamp();
          if (trackingNumber != null && trackingNumber.isNotEmpty) {
            updateData['trackingNumber'] = trackingNumber;
          }
          break;
        case 'Delivered':
          updateData['deliveredAt'] = FieldValue.serverTimestamp();
          break;
      }

      if (note != null && note.isNotEmpty) {
        updateData['deliveryNote'] = note;
      }

      // Update in Firestore
      debugPrint('📤 Sending update to Firestore...');
      final success = await _firestoreService.updateOrder(orderId, updateData);

      if (!success) {
        throw Exception('Failed to update order in Firestore');
      }

      debugPrint('🔄 Reloading all orders...');
      // Reload orders
      await loadAllOrders();

      debugPrint('✅ Order status update completed successfully!');
    } catch (e) {
      Get.snackbar(AppStrings.error, 'Failed to update order status: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
