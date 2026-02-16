import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OneSignalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  // Initialize OneSignal
  Future<void> initialize(String appId) async {
    try {
      // Initialize OneSignal
      OneSignal.initialize(appId);

      // Set up subscription listener to save Player ID when it becomes available
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint('🔔 OneSignal subscription changed');
        final playerId = state.current.id;
        if (playerId != null && _currentUserId != null) {
          debugPrint('📱 New Player ID received: $playerId');
          _savePlayerIdToFirestore(_currentUserId!, playerId);
        }
      });

      // Request notification permission
      debugPrint('🔔 Requesting notification permission...');
      final permissionGranted = await OneSignal.Notifications.requestPermission(
        true,
      );

      if (permissionGranted) {
        debugPrint('✅ Notification permission granted');
      } else {
        debugPrint('❌ Notification permission denied');
      }

      debugPrint('✅ OneSignal initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing OneSignal: $e');
    }
  }

  // Save Player ID to Firestore (internal method)
  Future<void> _savePlayerIdToFirestore(String userId, String playerId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'oneSignalPlayerId': playerId,
        'playerIdUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ OneSignal Player ID saved for user: $userId');
      debugPrint('📱 Player ID: $playerId');
    } catch (e) {
      debugPrint('❌ Error saving OneSignal Player ID: $e');
    }
  }

  // Save OneSignal Player ID to Firestore for a user
  Future<void> savePlayerIdForUser(String userId) async {
    try {
      _currentUserId = userId; // Store for the subscription listener

      // Get OneSignal player ID (subscription ID)
      final playerId = OneSignal.User.pushSubscription.id;

      if (playerId != null) {
        await _savePlayerIdToFirestore(userId, playerId);
      } else {
        debugPrint(
          '⚠️ OneSignal Player ID is null (will be saved when available)',
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving OneSignal Player ID: $e');
    }
  }

  // Delete OneSignal Player ID on logout
  Future<void> deletePlayerId(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'oneSignalPlayerId': FieldValue.delete(),
      });
      debugPrint('✅ OneSignal Player ID deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting OneSignal Player ID: $e');
    }
  }

  // Set external user ID (optional - links OneSignal with your user ID)
  Future<void> setExternalUserId(String userId) async {
    try {
      OneSignal.login(userId);
      debugPrint('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      debugPrint('❌ Error setting external user ID: $e');
    }
  }

  // Remove external user ID on logout
  Future<void> removeExternalUserId() async {
    try {
      OneSignal.logout();
      debugPrint('✅ OneSignal external user ID removed');
    } catch (e) {
      debugPrint('❌ Error removing external user ID: $e');
    }
  }

  // Send notification to a specific user
  // Note: This requires OneSignal REST API and should be called from backend
  // For now, we'll create a notification request in Firestore
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's OneSignal player ID from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final playerId = userDoc.data()?['oneSignalPlayerId'] as String?;

      if (playerId == null) {
        debugPrint('❌ No OneSignal Player ID found for user: $userId');
        return;
      }

      // Create notification request in Firestore
      // This can be processed by a Cloud Function or backend service
      await _firestore.collection('notificationQueue').add({
        'userId': userId,
        'playerId': playerId,
        'title': title,
        'message': message,
        'data': data ?? {},
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Notification queued for user: $userId');
      debugPrint('📱 Player ID: $playerId');
      debugPrint('📝 Title: $title');
      debugPrint('💬 Message: $message');
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
    }
  }

  // Send notification when order is confirmed
  Future<void> sendOrderConfirmedNotification({
    required String userId,
    required String orderId,
    required String orderNumber,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: '✅ Order Confirmed!',
      message:
          'Your order #$orderNumber has been confirmed. We are preparing your items.',
      data: {
        'type': 'order_confirmed',
        'orderId': orderId,
        'orderNumber': orderNumber,
      },
    );
  }

  // Send notification when order is shipped
  Future<void> sendOrderShippedNotification({
    required String userId,
    required String orderId,
    required String orderNumber,
    String? trackingNumber,
  }) async {
    String message =
        'Your order #$orderNumber has been shipped and is on the way!';
    if (trackingNumber != null && trackingNumber.isNotEmpty) {
      message += ' Tracking: $trackingNumber';
    }

    await sendNotificationToUser(
      userId: userId,
      title: '📦 Order Shipped!',
      message: message,
      data: {
        'type': 'order_shipped',
        'orderId': orderId,
        'orderNumber': orderNumber,
        'trackingNumber': trackingNumber ?? '',
      },
    );
  }

  // Send notification when order is delivered
  Future<void> sendOrderDeliveredNotification({
    required String userId,
    required String orderId,
    required String orderNumber,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: '🎉 Order Delivered!',
      message:
          'Your order #$orderNumber has been delivered successfully. Thank you for shopping with us!',
      data: {
        'type': 'order_delivered',
        'orderId': orderId,
        'orderNumber': orderNumber,
      },
    );
  }

  // Send notification when order is cancelled
  Future<void> sendOrderCancelledNotification({
    required String userId,
    required String orderId,
    required String orderNumber,
    String? reason,
  }) async {
    String message = 'Your order #$orderNumber has been cancelled.';
    if (reason != null && reason.isNotEmpty) {
      message += ' Reason: $reason';
    }

    await sendNotificationToUser(
      userId: userId,
      title: '❌ Order Cancelled',
      message: message,
      data: {
        'type': 'order_cancelled',
        'orderId': orderId,
        'orderNumber': orderNumber,
        'reason': reason ?? '',
      },
    );
  }

  // Handle notification click
  void setupNotificationClickHandler() {
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('📱 Notification clicked');
      debugPrint('Data: ${event.notification.additionalData}');

      // Handle navigation based on notification data
      final data = event.notification.additionalData;
      if (data != null) {
        final type = data['type'];
        if (type == 'order_delivered') {
          // Navigate to order details or review screen
          debugPrint('Navigate to order: ${data['orderId']}');
        }
      }
    });
  }
}
