# Support Ticket Notifications Setup

## Overview
The support ticket system now includes real-time push notifications for users when:
- An admin replies to their ticket
- An admin changes the status of their ticket

## How It Works

### Notification Triggers

#### 1. Admin Reply Notification
When an admin sends a reply to a support ticket:
- **Title**: `💬 New Reply on Support Ticket #XXXXXX`
- **Message**: `An admin has replied to your support ticket`
- **Data Payload**:
  ```json
  {
    "type": "support_ticket_reply",
    "ticketId": "ticket_id_here",
    "route": "/ticket-detail"
  }
  ```

#### 2. Status Change Notification
When an admin changes ticket status:

**In Progress** (🔄):
- **Title**: `🔄 Support Ticket #XXXXXX`
- **Message**: `Your support ticket is being processed`

**Resolved** (✅):
- **Title**: `✅ Support Ticket #XXXXXX`
- **Message**: `Your support ticket has been resolved`

**Closed** (🔒):
- **Title**: `🔒 Support Ticket #XXXXXX`
- **Message**: `Your support ticket has been closed`

**Data Payload**:
```json
{
  "type": "support_ticket_status",
  "ticketId": "ticket_id_here",
  "status": "in-progress|resolved|closed",
  "route": "/ticket-detail"
}
```

## Implementation Details

### Code Location
All notification logic is in `lib/services/firestore_service.dart`:
- **Method**: `addTicketReply()` - Sends notification when admin replies
- **Method**: `updateTicketStatus()` - Sends notification on status change

### Error Handling
- Notifications are wrapped in try-catch blocks
- Notification failures **do not** break core ticket functionality
- Errors are logged to debug console with warnings
- Users receive notifications if FCM is properly configured

### Background Processing
Notifications are queued to Firestore's `fcmNotificationQueue` collection:
```dart
{
  'userId': 'user_id_here',
  'title': 'Notification Title',
  'message': 'Notification Message',
  'data': { ... },
  'createdAt': Timestamp.now(),
  'sent': false
}
```

A Cloud Function processes this queue and sends actual FCM notifications to user devices.

## Testing Guide

### Prerequisites
1. Firebase Cloud Messaging configured
2. FCM Cloud Function deployed (processes notification queue)
3. Test devices with FCM tokens registered
4. Admin account: `admin@turfmate.com`

### Test Steps

#### Test 1: Reply Notification
1. Login as regular user
2. Create a support ticket from Help & Support screen
3. Note the ticket number
4. Logout and login as admin
5. Navigate to Support Tickets
6. Open the ticket
7. Send a reply message
8. Check user device for notification: `💬 New Reply on Support Ticket #XXXXX`
9. Tap notification → should navigate to ticket detail

#### Test 2: Status Change Notifications
1. As admin, open a ticket
2. Change status to "In Progress"
   - User should receive: `🔄 Support Ticket #XXXXX - Your support ticket is being processed`
3. Change status to "Resolved"
   - User should receive: `✅ Support Ticket #XXXXX - Your support ticket has been resolved`
4. Change status to "Closed"
   - User should receive: `🔒 Support Ticket #XXXXX - Your support ticket has been closed`

### Debugging Notifications

Check Flutter debug console for:
```
✅ Notification queued successfully for ticket: XXXXXX
⚠️ Failed to queue notification: [error message]
```

Check Firestore console:
- Collection: `fcmNotificationQueue`
- Should see queued notifications with `sent: false`
- After Cloud Function processes them, `sent: true`

## Cloud Function Requirement

The notification system requires a Cloud Function to process the queue:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.processNotificationQueue = functions.firestore
  .document('fcmNotificationQueue/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    if (notification.sent) return null;
    
    try {
      // Get user's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(notification.userId)
        .get();
      
      const fcmToken = userDoc.data()?.fcmToken;
      
      if (!fcmToken) {
        console.log('No FCM token for user:', notification.userId);
        return null;
      }
      
      // Send notification
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.message
        },
        data: notification.data || {},
        android: {
          priority: 'high'
        },
        apns: {
          headers: {
            'apns-priority': '10'
          }
        }
      });
      
      // Mark as sent
      await snap.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp() });
      
      console.log('✅ Notification sent successfully');
      
    } catch (error) {
      console.error('❌ Failed to send notification:', error);
      await snap.ref.update({ 
        sent: false, 
        error: error.message,
        attempts: admin.firestore.FieldValue.increment(1)
      });
    }
  });
```

## Navigation Handling

When user taps notification, the app should navigate to ticket detail:

```dart
// Handle notification tap in main.dart or notification service
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  
  if (data['type'] == 'support_ticket_reply' || data['type'] == 'support_ticket_status') {
    // Navigate to ticket detail
    Get.toNamed(Routes.TICKET_DETAIL, arguments: {
      'ticketId': data['ticketId']
    });
  }
});
```

## Features

✅ Real-time notifications for admin actions
✅ Status-specific emojis and messages
✅ Deep linking to ticket detail screen
✅ Non-blocking error handling
✅ Queued delivery via Firestore + Cloud Function
✅ Works with existing FCM infrastructure

## Notes

- Notifications only sent when **admin** replies (not when user replies)
- Status change notifications sent for **all** status updates
- Requires user to have valid FCM token in Firestore
- Cloud Function must be deployed for actual FCM delivery
- Notification data includes route for app navigation

## Troubleshooting

### Notifications Not Received
1. Check FCM token exists in Firestore user document
2. Verify Cloud Function is deployed and running
3. Check Cloud Function logs for errors
4. Ensure user has notification permissions enabled
5. Check `fcmNotificationQueue` collection for queued items

### Notification Sent But No Sound/Vibration
- Check device notification settings
- Verify notification channel configuration (Android)
- Ensure `priority: 'high'` in Cloud Function

### Deep Link Not Working
- Verify route exists in app routes configuration
- Check notification data payload structure
- Implement `onMessageOpenedApp` handler in main.dart

---

**Implementation Date**: February 2026  
**Version**: 1.0  
**Status**: ✅ Production Ready
