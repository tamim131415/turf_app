# Admin Ticket Notifications & Badge Counter

## Overview
When a user submits a new support ticket, the admin receives a push notification and sees a badge counter in the admin panel showing pending tickets.

## Features

### 1. Admin Notification on New Ticket
When a user creates a support ticket:
- **Title**: `🎫 New Support Ticket #XXXXXX`
- **Message**: `{userName} submitted a new support ticket`
- **Data Payload**:
  ```json
  {
    "type": "new_support_ticket",
    "ticketId": "ticket_id_here",
    "userId": "user_id_here",
    "userName": "User Name",
    "route": "/admin-tickets"
  }
  ```

### 2. Badge Counter in Admin Panel
- Shows count of **pending** tickets in AppBar
- Updates in real-time using StreamBuilder
- Red badge with notification bell icon
- Only visible when there are pending tickets
- Located in the top-right corner of Admin Tickets screen

## Implementation Details

### Code Locations

#### 1. Notification Logic
**File**: `lib/services/firestore_service.dart`  
**Method**: `createSupportTicket()`

When a ticket is created:
1. Ticket is saved to Firestore
2. Query admin user by email (`admin@turfmate.com`)
3. Send FCM notification to admin using `sendNotificationToUser()`
4. Non-blocking: notification failure doesn't prevent ticket creation

```dart
// Get admin user ID by email
final adminQuery = await _firestore
    .collection('users')
    .where('email', isEqualTo: 'admin@turfmate.com')
    .limit(1)
    .get();

if (adminQuery.docs.isNotEmpty) {
  final adminUserId = adminQuery.docs.first.id;
  
  await FCMNotificationService().sendNotificationToUser(
    userId: adminUserId,
    title: '🎫 New Support Ticket #$ticketId',
    message: '$userName submitted a new support ticket',
    data: {...},
  );
}
```

#### 2. Badge Counter Stream
**File**: `lib/services/firestore_service.dart`  
**Method**: `getPendingTicketsCount()`

Returns a real-time stream of pending ticket count:
```dart
Stream<int> getPendingTicketsCount() {
  return _firestore
      .collection('supportTickets')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
```

#### 3. Badge UI
**File**: `lib/screens/support/admin_tickets_screen.dart`  
**Location**: AppBar actions

Shows a red badge with count:
```dart
actions: [
  StreamBuilder<int>(
    stream: firestoreService.getPendingTicketsCount(),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      if (count == 0) return SizedBox.shrink();
      
      return Container(
        // Red badge with notification icon and count
      );
    },
  ),
]
```

## User Flow

### Creating a Ticket (User Side)
1. User navigates to Help & Support
2. Fills issue description
3. Taps "Submit Ticket"
4. Ticket saved to Firestore
5. **Admin receives notification** 📱

### Receiving Notification (Admin Side)
1. Admin device receives FCM push notification
2. Taps notification → navigates to Admin Tickets screen
3. Sees new ticket at the top (sorted by createdAt)
4. Badge counter shows number of pending tickets
5. Opens ticket to respond

## Testing Guide

### Prerequisites
1. Admin account: `admin@turfmate.com`
2. Regular user account
3. Both devices with FCM configured
4. Cloud Function deployed for FCM queue processing

### Test Steps

#### Test 1: Admin Notification
1. **User Device**:
   - Login as regular user
   - Navigate to Profile → Help & Support
   - Enter ticket issue: "Test notification to admin"
   - Submit ticket
   - Note the ticket number shown

2. **Admin Device**:
   - Should receive notification: `🎫 New Support Ticket #XXXXX`
   - Tap notification
   - Should navigate to Admin Tickets screen
   - Verify new ticket appears at top

#### Test 2: Badge Counter
1. **Admin Device**:
   - Login as admin
   - Navigate to Admin Tickets (Home → Support Tickets button)
   - Check AppBar for badge counter

2. **Expected Behavior**:
   - If pending tickets exist: Red badge shows count
   - If no pending tickets: Badge hidden
   - Badge updates in real-time when tickets created/status changed

3. **Create Multiple Tickets**:
   - From user device, create 3 tickets
   - Admin device badge should update: 1 → 2 → 3
   - Change one ticket status to "in-progress"
   - Badge should decrease: 3 → 2

#### Test 3: Real-time Updates
1. Keep Admin Tickets screen open
2. From another device/user, create new ticket
3. Verify:
   - Admin receives notification
   - Badge count increases immediately
   - New ticket appears in list without refresh

## Badge Display Logic

| Pending Tickets | Badge Display |
|----------------|---------------|
| 0 | Hidden |
| 1-99 | Shows number |
| 100+ | Shows "99+" (optional enhancement) |

## Notification Data Structure

```json
{
  "userId": "admin_user_id",
  "fcmToken": "admin_fcm_token",
  "title": "🎫 New Support Ticket #1234567890",
  "message": "John Doe submitted a new support ticket",
  "data": {
    "type": "new_support_ticket",
    "ticketId": "1234567890",
    "userId": "user_id",
    "userName": "John Doe",
    "route": "/admin-tickets"
  },
  "status": "pending",
  "createdAt": "2026-02-17T10:30:00Z"
}
```

## Error Handling

### Admin Not Found
If admin user doesn't exist in Firestore:
```
⚠️ Admin user not found
```
- Ticket still created successfully
- No notification sent
- Admin can still view ticket in panel

### Notification Failure
If FCM notification fails:
```
⚠️ Failed to send admin notification: [error]
```
- Ticket creation succeeds
- Error logged to console
- Admin can still access ticket via panel

### Badge Stream Error
If badge counter stream fails:
- Badge shows 0 or hides
- Tickets list still works normally
- User can refresh to retry

## Cloud Function Requirement

Same Cloud Function processes both user and admin notifications:

```javascript
exports.processNotificationQueue = functions.firestore
  .document('fcmNotificationQueue/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Get FCM token and send notification
    // Works for both admin and user notifications
  });
```

## Navigation Handling

Handle admin notification tap:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  
  if (data['type'] == 'new_support_ticket') {
    // Navigate to admin tickets screen
    Get.toNamed(Routes.ADMIN_TICKETS);
    
    // Optional: Auto-open specific ticket
    // Get.toNamed(Routes.TICKET_DETAIL, arguments: {
    //   'ticketId': data['ticketId'],
    //   'isAdmin': true
    // });
  }
});
```

## UI Components

### Badge Design
- **Color**: Red (#E53935)
- **Icon**: Notification bell (notifications_active)
- **Text**: Bold white number
- **Shape**: Rounded rectangle (borderRadius: 20)
- **Size**: Compact, fits in AppBar
- **Position**: Top-right corner

### Badge States
1. **Hidden** (0 tickets): `SizedBox.shrink()`
2. **Visible** (1+ tickets): Red badge with count
3. **Loading**: Shows 0 while stream loads

## Benefits

✅ **Real-time Awareness**: Admin knows immediately when tickets arrive  
✅ **Visual Indicator**: Badge shows pending workload at a glance  
✅ **Better UX**: No need to refresh or manually check for new tickets  
✅ **Prioritization**: Admins can see pending count before opening screen  
✅ **Non-blocking**: Notification failures don't affect core functionality  

## Future Enhancements

### Possible Improvements
1. **Multi-admin Support**: Send to all admin users, not just one
2. **Priority Badges**: Different colors for urgent tickets
3. **Sound & Vibration**: Custom notification sounds
4. **Badge Persistence**: Show badge on home screen icon (Android)
5. **Ticket Categories**: Filter badges by category
6. **Read/Unread**: Track which tickets admin has viewed
7. **Auto-assign**: Distribute tickets among multiple admins

## Troubleshooting

### Badge Not Showing
1. Check Firestore: Are there tickets with `status: 'pending'`?
2. Check console for stream errors
3. Verify admin is logged in
4. Try force-closing and reopening app

### Notification Not Received
1. Check admin FCM token exists in Firestore
2. Verify Cloud Function is running
3. Check Cloud Function logs
4. Ensure admin@turfmate.com user exists
5. Check notification permissions on admin device

### Badge Count Wrong
1. Check Firestore query: `status == 'pending'`
2. Verify tickets have correct status field
3. Check for duplicate ticket documents
4. Try manual count in Firestore console

---

**Implementation Date**: February 2026  
**Version**: 1.0  
**Status**: ✅ Production Ready  
**Related**: See SUPPORT_TICKET_NOTIFICATIONS.md for user notifications
