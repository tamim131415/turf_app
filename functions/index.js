// Firebase Cloud Function for sending FCM notifications
// Copy this code to Firebase Console -> Functions

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Function triggers when new document is added to fcmNotificationQueue
exports.sendFCMNotifications = functions.firestore
  .document('fcmNotificationQueue/{notificationId}')
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();
    
    console.log('📱 New notification request:', notificationData);

    try {
      // Prepare FCM message with Android-specific config
      const message = {
        notification: {
          title: notificationData.title,
          body: notificationData.message,
        },
        data: notificationData.data || {},
        token: notificationData.fcmToken,
        android: {
          priority: 'high',
          notification: {
            channelId: 'turf_app_notifications',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
            icon: 'ic_launcher',
          },
        },
        apns: {
          payload: {
            aps: {
              contentAvailable: true,
              sound: 'default',
            },
          },
        },
      };

      // Send notification via FCM
      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);

      // Update document status to 'sent'
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        response: response,
      });

    } catch (error) {
      console.error('❌ Error sending notification:', error);
      
      // Update document status to 'failed'
      await snap.ref.update({
        status: 'failed',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        error: error.message,
      });
    }
  });
