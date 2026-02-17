import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import '../screens/support/ticket_detail_screen.dart';
import '../controllers/auth_controller.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('📱 Title: ${message.notification?.title}');
  debugPrint('💬 Body: ${message.notification?.body}');
}

class FCMNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _currentUserId;
  RemoteMessage? _pendingNotification; // Store notification when app is killed

  // Notification channel for Android 8+
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'turf_app_notifications',
    'Order Notifications',
    description: 'Notifications for order updates and important messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint('🔔 Foreground message received');
        debugPrint('📱 Title: ${message.notification?.title}');
        debugPrint('💬 Body: ${message.notification?.body}');
        debugPrint('📦 Data: ${message.data}');

        // Show local notification
        if (message.notification != null) {
          await _showLocalNotification(
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🔔 Notification tapped (background)');
        _handleNotificationTap(message);
      });

      // Check if app was opened from a notification (terminated state)
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🔔 App opened from notification (terminated state)');
        debugPrint('📦 Storing notification for later: ${initialMessage.data}');
        // Store the notification, don't navigate immediately
        // Will be handled after app is fully initialized
        _pendingNotification = initialMessage;
      }

      debugPrint('✅ FCM initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 Local notification tapped: ${response.payload}');
          // Payload is not used - notification data is handled in _handleNotificationTap
          // which is called from onMessageOpenedApp
        },
      );

      // Create notification channel for Android 8+
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(_channel);
        debugPrint('✅ Android notification channel created');
      }

      debugPrint('✅ Local notifications initialized');
    } catch (e) {
      debugPrint('❌ Error initializing local notifications: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'turf_app_notifications',
            'Order Notifications',
            channelDescription:
                'Notifications for order updates and important messages',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF4CAF50),
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Local notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  // Request notification permission (call this after login)
  Future<bool> requestNotificationPermission() async {
    try {
      debugPrint('🔔 Requesting notification permission...');

      // For Android 13+ (API 33+), use permission_handler
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();

        if (status.isGranted) {
          debugPrint('✅ Android notification permission granted');
          return true;
        } else if (status.isDenied) {
          debugPrint('❌ Android notification permission denied');
          return false;
        } else if (status.isPermanentlyDenied) {
          debugPrint('⚠️ Android notification permission permanently denied');
          // Show dialog to open app settings
          Get.dialog(
            AlertDialog(
              title: Text('Notification Permission Required'),
              content: Text(
                'Please enable notifications in app settings to receive order updates.',
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
                TextButton(
                  onPressed: () {
                    Get.back();
                    openAppSettings();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
          return false;
        }
      }

      // For iOS, use Firebase Messaging permission request
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ iOS notification permission granted');
        return true;
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('✅ iOS provisional notification permission granted');
        return true;
      } else {
        debugPrint('❌ iOS notification permission denied');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  // Handle pending notification after app is ready
  void handlePendingNotification() {
    if (_pendingNotification != null) {
      debugPrint('🔔 Processing pending notification');
      final message = _pendingNotification!;
      _pendingNotification = null; // Clear it

      // Wait longer for app to be fully ready and stable
      Future.delayed(Duration(milliseconds: 1500), () {
        try {
          debugPrint('🔔 App should be ready now, handling notification');
          _handleNotificationTap(message);
        } catch (e) {
          debugPrint('❌ Error processing pending notification: $e');
        }
      });
    } else {
      debugPrint('ℹ️ No pending notification to handle');
    }
  }

  // Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    debugPrint('🔔 Handling notification tap');
    debugPrint('📦 Notification data: $data');

    if (!data.containsKey('type')) {
      debugPrint('⚠️ No type in notification data');
      return;
    }

    final type = data['type'];
    debugPrint('🎯 Notification type: $type');

    // Ensure we're on main navigation first, then navigate to specific screen
    try {
      switch (type) {
        case 'order_confirmed':
        case 'order_shipped':
        case 'order_delivered':
        case 'order_cancelled':
          // Navigate to orders screen
          debugPrint('📍 Navigating to my-orders');
          _navigateToScreen(() {
            Get.toNamed('/my-orders');
          });
          break;

        case 'support_ticket_reply':
        case 'support_ticket_status':
        case 'support_ticket_user_reply':
          // Navigate to ticket detail
          final ticketId = data['ticketId'] ?? '';
          final isAdminNotification =
              type == 'support_ticket_user_reply' ||
              type == 'new_support_ticket';

          debugPrint(
            '📍 Navigating to ticket detail: $ticketId (admin: $isAdminNotification)',
          );
          if (ticketId.isNotEmpty) {
            _navigateToScreen(() {
              Get.to(
                () => TicketDetailScreen(
                  ticketId: ticketId,
                  isAdmin: isAdminNotification,
                ),
              );
            });
          } else {
            debugPrint('⚠️ Empty ticketId, cannot navigate');
          }
          break;

        case 'new_support_ticket':
          // Navigate to admin tickets (admin only)
          debugPrint('📍 Navigating to admin tickets');
          _navigateToScreen(() {
            Get.toNamed('/admin-tickets');
          });
          break;

        case 'new_order':
          // Navigate to inventory orders tab (admin only)
          debugPrint('📍 Navigating to inventory');
          _navigateToScreen(() {
            Get.toNamed('/inventory');
          });
          break;

        default:
          debugPrint('⚠️ Unknown notification type: $type');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  // Helper method to safely navigate to screen
  void _navigateToScreen(Function() navigateAction) {
    debugPrint('🔍 Current route: ${Get.currentRoute}');

    // Check if GetX is ready by checking if AuthController is registered
    if (!Get.isRegistered<AuthController>()) {
      debugPrint('⚠️ GetX services not ready, waiting...');
      Future.delayed(Duration(milliseconds: 1000), () {
        _navigateToScreen(navigateAction);
      });
      return;
    }

    // If we're not on main navigation, go there first
    if (Get.currentRoute != '/main-navigation' &&
        !Get.currentRoute.startsWith('/main-navigation')) {
      debugPrint(
        '📍 Not on main navigation (${Get.currentRoute}), navigating there first',
      );
      try {
        Get.offAllNamed('/main-navigation');
        // Wait for main navigation to load
        Future.delayed(Duration(milliseconds: 800), () {
          _performNavigation(navigateAction);
        });
      } catch (e) {
        debugPrint('❌ Error navigating to main: $e');
      }
    } else {
      // Already on main navigation, proceed
      debugPrint('✅ Already on main navigation');
      Future.delayed(Duration(milliseconds: 300), () {
        _performNavigation(navigateAction);
      });
    }
  }

  // Perform the actual navigation with error handling
  void _performNavigation(Function() navigateAction) {
    try {
      debugPrint('🎯 Performing navigation action');
      navigateAction();
      debugPrint('✅ Navigation completed');
    } catch (e) {
      debugPrint('❌ Navigation error: $e');
      // Try one more time
      Future.delayed(Duration(milliseconds: 500), () {
        try {
          navigateAction();
        } catch (e2) {
          debugPrint('❌ Second navigation attempt failed: $e2');
        }
      });
    }
  }

  // Save FCM token to Firestore
  Future<void> saveFCMTokenForUser(String userId) async {
    try {
      _currentUserId = userId;

      // Request notification permission first
      bool permissionGranted = await requestNotificationPermission();

      if (!permissionGranted) {
        debugPrint(
          '⚠️ Notification permission not granted, skipping FCM token save',
        );
        return;
      }

      // Get FCM token
      String? token = await _fcm.getToken();

      if (token != null) {
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('✅ FCM token saved for user: $userId');
        debugPrint('🔑 Token: $token');
      } else {
        debugPrint('⚠️ FCM token is null');
      }

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM token refreshed');
        if (_currentUserId != null) {
          _firestore.collection('users').doc(_currentUserId!).update({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  // Delete FCM token on logout
  Future<void> deleteFCMToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _fcm.deleteToken();
      debugPrint('✅ FCM token deleted for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  // Send notification to specific user (requires Cloud Function or Admin SDK)
  // This creates a notification request that Cloud Function will process
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        debugPrint('❌ No FCM token found for user: $userId');
        return;
      }

      // Create notification request in Firestore
      // A Cloud Function will process this and send via FCM
      await _firestore.collection('fcmNotificationQueue').add({
        'userId': userId,
        'fcmToken': fcmToken,
        'title': title,
        'message': message,
        'data': data ?? {},
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ FCM notification queued for user: $userId');
      debugPrint('🔑 Token: $fcmToken');
      debugPrint('📝 Title: $title');
      debugPrint('💬 Message: $message');
    } catch (e) {
      debugPrint('❌ Error queuing FCM notification: $e');
    }
  }

  // Order notification methods
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
}
