# FCM Order Notification System - Setup Guide

## 🎉 What Changed from OneSignal to FCM

### ✅ Migrated from OneSignal to Firebase Cloud Messaging (FCM)
**Why?**
- **100% FREE** - No costs for unlimited notifications
- **No Backend Required** for sending (uses Cloud Functions)
- **Native Firebase Integration** - Already using Firebase
- **Better Android Support** - Direct FCM implementation

### Updated Files:
- ✅ `pubspec.yaml` - Added `firebase_messaging` package
- ✅ `fcm_notification_service.dart` - New FCM service (replaces OneSignal)
- ✅ `order_controller.dart` - Uses FCM instead of OneSignal
- ✅ `auth_controller.dart` - Saves/deletes FCM tokens
- ✅ `main.dart` - Initializes FCM on app start
- ✅ `AndroidManifest.xml` - FCM-compatible permissions

---

## ✅ What's Been Implemented

### 1. Android Configuration (Android 10+ Support)
- ✅ Minimum SDK set to 29 (Android 10)
- ✅ Notification permissions added to AndroidManifest
- ✅ POST_NOTIFICATIONS permission for Android 13+
- ✅ Wake lock, vibrate, and foreground service permissions

### 2. Firebase Cloud Messaging (FCM) - **COMPLETELY FREE**
- ✅ No backend required for basic notifications
- ✅ Direct device-to-device notifications
- ✅ Real-time delivery
- ✅ Foreground and background message handling

### 3. Notification Types
All order status change notifications are now implemented:

#### ✅ Order Confirmed
- Sent when admin confirms a pending order
- Title: "✅ Order Confirmed!"
- Message: "Your order #{orderId} has been confirmed. We are preparing your items."

#### 📦 Order Shipped
- Sent when admin marks order as shipped
- Title: "📦 Order Shipped!"
- Message: "Your order #{orderId} has been shipped and is on the way!"
- Includes tracking number if provided

#### 🎉 Order Delivered
- Sent when admin marks order as delivered
- Title: "🎉 Order Delivered!"
- Message: "Your order #{orderId} has been delivered successfully. Thank you for shopping with us!"

#### ❌ Order Cancelled
- Sent when admin cancels an order
- Title: "❌ Order Cancelled"
- Message: "Your order #{orderId} has been cancelled."
- Includes cancellation reason if provided

### 4. Code Updates
- ✅ FCMNotificationService: Complete FCM integration
- ✅ OrderController: Integrated FCM notification calls on status updates
- ✅ AuthController: Save/delete FCM tokens on login/logout
- ✅ Main.dart: FCM service initialization
- ✅ Notifications are sent automatically when admin changes order status

## 🔧 Current Setup (Firestore Queue Method)

### How it works now:
1. When order status changes, notification data is saved to `fcmNotificationQueue` collection
2. Contains: userId, fcmToken, title, message, data
3. **Requires Cloud Function to process and send**

### Firestore Structure:

### Firestore Structure:
```
fcmNotificationQueue/
├── {notificationId}
│   ├── userId: "customer_user_id"
│   ├── fcmToken: "device_fcm_token"
│   ├── title: "✅ Order Confirmed!"
│   ├── message: "Your order #xyz..."
│   ├── data: { type, orderId, orderNumber }
│   ├── status: "pending"
│   └── createdAt: timestamp
```

## 🚀 Firebase Cloud Function Setup (Required)

### Step 1: Initialize Firebase Functions
```bash
npm install -g firebase-tools
firebase login
cd d:/Apps/turf_app
firebase init functions
```

### Step 2: Install Dependencies
```bash
cd functions
npm install firebase-admin firebase-functions
```

### Step 3: Create FCM Notification Function
Create `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Process notification queue and send via FCM
exports.sendFCMNotifications = functions.firestore
  .document('fcmNotificationQueue/{notificationId}')
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();
    
    try {
      // Prepare FCM message
      const message = {
        token: notificationData.fcmToken,
        notification: {
          title: notificationData.title,
          body: notificationData.message,
        },
        data: notificationData.data || {},
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'order_updates',
          },
        },
      };

      // Send notification
      const response = await admin.messaging().send(message);
      console.log('✅ Notification sent successfully:', response);

      // Update status to sent
      await snap.ref.update({
        status: 'sent',
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: response,
      });

    } catch (error) {
      console.error('❌ Error sending notification:', error);
      
      // Update status to failed
      await snap.ref.update({
        status: 'failed',
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
```

### Step 4: Deploy Cloud Function
```bash
firebase deploy --only functions
```

## 💡 How It Works

### Full Flow:
1. **Customer places order** → Order saved in Firestore
2. **Admin changes order status** → OrderController triggered
3. **Notification queued** → Document created in `fcmNotificationQueue`
4. **Cloud Function triggered** → Automatically detects new document
5. **FCM sends notification** → Direct to customer's device via FCM token
6. **Customer receives** → Notification appears instantly

### Automatic Token Management:
- ✅ **Login**: FCM token saved to user document
- ✅ **Logout**: FCM token deleted
- ✅ **Token Refresh**: Automatically updated when changed

## 📱 Testing Notifications

### Test Flow:
1. **Install app** on device/emulator
2. **Login** as customer → FCM token saved
3. **Admin changes order status** → Notification queued
4. **Cloud Function processes** → Sends via FCM
5. **Customer receives** → Notification appears

### Check Firestore:
### Check Firestore:
```
Collection: fcmNotificationQueue
Document fields:
- userId: "customer_user_id"
- fcmToken: "device_fcm_token_here"
- title: "✅ Order Confirmed!"
- message: "Your order #xyz..."
- data: { type, orderId, orderNumber }
- status: "sent" (or "pending"/"failed")
- createdAt: timestamp
- sentAt: timestamp (when sent)
```

### Check FCM Token Saved:
```
Collection: users
Document: {userId}
Fields:
- fcmToken: "device_fcm_token_here"
- fcmTokenUpdatedAt: timestamp
```

## 🆓 Cost Analysis - Why FCM is Free

### Firebase Cloud Messaging:
- ✅ **Unlimited notifications**: No per-message cost
- ✅ **Cloud Functions**: Free tier includes 2M invocations/month
- ✅ **Firestore**: Free tier includes:
  - 50K reads/day
  - 20K writes/day
  - 20K deletes/day
  - 1 GB storage
- ✅ **No credit card required** for free tier

### Expected Usage (100 orders/day):
- Notification queue writes: 100/day (well within 20K limit)
- Cloud Function invocations: 100/day (well within 2M limit)
- FCM notifications: Unlimited ✅

**Total Monthly Cost: $0.00** 🎉

## 🛠️ Advanced Setup (Optional)

### Notification Channels (Android 8+)
For better control, create notification channels in your Android app:

```dart
// In fcm_notification_service.dart, add:
Future<void> createNotificationChannel() async {
  if (Platform.isAndroid) {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_updates', // id
      'Order Updates', // name
      description: 'Notifications for order status changes',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
```

### Custom Notification Sounds
1. Add sound file to `android/app/src/main/res/raw/notification.mp3`
2. Update Cloud Function to use custom sound:

```javascript
android: {
  notification: {
    sound: 'notification', // filename without extension
    channelId: 'order_updates',
  },
},
```

## 📊 Monitoring & Debugging

### Check Cloud Function Logs:
```bash
firebase functions:log --only sendFCMNotifications
```

### Check if notifications are being sent:
1. Firebase Console → Firestore → `fcmNotificationQueue`
2. Check document status: `pending` → `sent` or `failed`
3. If `failed`, check `error` field for details

### Common Issues:

#### FCM Token is null:
- User didn't grant notification permission
- Check permission request in app
- Re-install app and grant permission

#### Function not triggering:
- Check Firebase Console → Functions
- Verify function is deployed
- Check function logs for errors

#### Notification not received:
- Check device is online
- Check FCM token is valid (not expired)
- Check notification permission is granted
- Check app is not in battery optimization

## 🔔 User Permission Handling

### Android 13+ Permission Request:
The app automatically requests permission on first launch via FCM initialization.

### If User Denies:
User can manually enable in device settings:
- Settings → Apps → Turf Mate → Notifications → Enable

### Check Permission Status:
```dart
NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
if (settings.authorizationStatus == AuthorizationStatus.denied) {
  // Show dialog asking user to enable in settings
}
```

## ✅ Checklist

### Before Testing:
- [ ] Firebase project set up
- [ ] Cloud Functions enabled
- [ ] `firebase-admin` and `firebase-functions` installed
- [ ] Cloud Function deployed
- [ ] App installed on device
- [ ] User logged in
- [ ] Notification permission granted

### Testing Steps:
1. [ ] Place an order as customer
2. [ ] Login as admin
3. [ ] Change order status to "Confirmed"
4. [ ] Check Firestore for notification queue document
5. [ ] Wait 2-3 seconds for Cloud Function
6. [ ] Check if status changed to "sent"
7. [ ] Verify customer received notification

## 💡 Important Notes

### Foreground vs Background:
- **Foreground** (app open): Notification shows as GetX snackbar
- **Background** (app closed/minimized): System notification
- **Terminated** (app killed): System notification (requires background handler)

### Notification Tap Handling:
- Tapping notification navigates to My Orders screen
- Implemented in `fcm_notification_service.dart`
- Works in all app states (foreground/background/terminated)

### Token Management:
- FCM tokens can expire/change
- Token refresh is handled automatically
- New token is saved to Firestore when refreshed

## 🎯 Next Steps

### Immediate Actions:
1. ✅ **Deploy the app** - FCM is ready
2. ⚠️ **Set up Cloud Function** - Follow steps above
3. ✅ **Test with real orders** - Place order → Change status → Receive notification

### Optional Enhancements:
- Add notification history screen in app
- Add notification preferences (enable/disable types)
- Add notification scheduling (don't send at night)
- Add admin notifications (new orders)
