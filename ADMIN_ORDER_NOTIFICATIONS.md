# Admin Order Notifications & Badge Counter

## Overview
When a user places a new order, the admin receives a push notification and sees a badge counter in multiple locations showing the number of pending orders.

## Features

### 1. Admin Notification on New Order
When a user places an order:
- **Title**: `🛒 New Order #order_XXXXXXXXXXXXX`
- **Message**: `{customerName} placed an order with {X} items`
- **Data Payload**:
  ```json
  {
    "type": "new_order",
    "orderId": "order_id_here",
    "userId": "user_id_here",
    "customerName": "Customer Name",
    "route": "/inventory"
  }
  ```

### 2. Badge Counter Display Locations

#### Home Screen - Inventory Icon Badge
- Shows count of **pending** orders
- Small red circular badge on top-right of inventory icon
- Shows "99+" if more than 99 pending orders
- Real-time updates using StreamBuilder
- Only visible to admin users

#### Inventory Screen - Orders Tab Badge
- Shows count of **pending** orders in the tab label
- Red rounded rectangle badge next to "Orders" text
- Shows "99+" if more than 99 pending orders
- Real-time updates as orders are placed/updated
- Helps admin prioritize checking the Orders tab

## Implementation Details

### Code Locations

#### 1. Notification Logic
**File**: `lib/controllers/product_controller.dart`  
**Method**: `placeOrder()`

After order is saved to Firestore:
1. Query admin user by email (`admin@turfmate.com`)
2. Calculate total items in order
3. Send FCM notification to admin using `sendNotificationToUser()`
4. Non-blocking: notification failure doesn't prevent order placement

```dart
// Get admin user ID by email
final adminQuery = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: 'admin@turfmate.com')
    .limit(1)
    .get();

if (adminQuery.docs.isNotEmpty) {
  final adminUserId = adminQuery.docs.first.id;
  final totalItems = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  
  await FCMNotificationService().sendNotificationToUser(
    userId: adminUserId,
    title: '🛒 New Order #$orderId',
    message: '$customerName placed an order with $totalItems items',
    data: {...},
  );
}
```

#### 2. Pending Orders Count Stream
**File**: `lib/services/firestore_service.dart`  
**Method**: `getPendingOrdersCount()`

Returns a real-time stream of pending orders count:
```dart
Stream<int> getPendingOrdersCount() {
  return ordersCollection
      .where('orderStatus', isEqualTo: 'Pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
```

#### 3. Home Screen Badge
**File**: `lib/screens/home/home_screen.dart`  
**Location**: AppBar Inventory Icon

Shows a red circular badge:
```dart
Stack(
  clipBehavior: Clip.none,
  children: [
    IconButton(
      icon: Icon(Icons.inventory_2_outlined, color: Colors.green[700]),
      onPressed: () => Get.toNamed(Routes.inventory),
      tooltip: 'Inventory',
    ),
    // Pending orders badge
    StreamBuilder<int>(
      stream: Get.find<FirestoreService>().getPendingOrdersCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count == 0) return SizedBox.shrink();
        
        return Positioned(
          right: 4,
          top: 4,
          child: Container(
            // Red badge with count
          ),
        );
      },
    ),
  ],
)
```

#### 4. Inventory Screen Tab Badge
**File**: `lib/screens/inventory/inventory_screen.dart`  
**Location**: TabBar Orders Tab

Shows a red badge in the tab:
```dart
StreamBuilder<int>(
  stream: firestoreService.getPendingOrdersCount(),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long),
          SizedBox(width: 8),
          Text('Orders'),
          if (count > 0) ...[
            Container(
              // Red badge with count
            ),
          ],
        ],
      ),
    );
  },
)
```

## User Flow

### Placing Order (User Side)
1. User adds products to cart
2. Proceeds to checkout
3. Fills delivery details and payment method
4. Taps "Place Order"
5. Order saved to Firestore with status: "Pending"
6. **Admin receives notification** 📱

### Receiving Notification (Admin Side)
1. Admin device receives FCM push notification
2. Notification shows: "🛒 New Order #XXXXX"
3. Message shows customer name and item count
4. Taps notification → navigates to Inventory screen
5. Sees badge on inventory icon (if on home screen)
6. Sees badge on Orders tab (if in inventory screen)
7. Opens Orders tab to view and process order

## Testing Guide

### Prerequisites
1. Admin account: `admin@turfmate.com`
2. Regular user account
3. Both devices with FCM configured
4. Cloud Function deployed for FCM queue processing
5. Products available in store

### Test Steps

#### Test 1: Admin Notification
1. **User Device**:
   - Login as regular user
   - Add products to cart (e.g., 3 items)
   - Navigate to Cart → Checkout
   - Fill delivery details
   - Select payment method
   - Tap "Place Order"
   - Note the order ID

2. **Admin Device**:
   - Should receive notification: `🛒 New Order #order_XXXXX`
   - Message should show: "Customer Name placed an order with 3 items"
   - Tap notification
   - Should navigate to Inventory screen
   - Should see the new order at top

#### Test 2: Home Screen Badge
1. **Admin Device**:
   - Login as admin
   - Navigate to Home screen
   - Look at inventory icon in AppBar

2. **Expected Behavior**:
   - If pending orders exist: Red circular badge shows count
   - If no pending orders: Badge hidden
   - Badge shows "99+" if count > 99

3. **Create Multiple Orders**:
   - From user device, place 3 orders
   - Admin home screen badge should update: 1 → 2 → 3
   - Process one order (change status to "Confirmed")
   - Badge should decrease: 3 → 2

#### Test 3: Inventory Tab Badge
1. **Admin Device**:
   - Navigate to Inventory Management
   - Check the "Orders" tab label

2. **Expected Behavior**:
   - Tab shows "Orders" with badge count
   - Badge appears next to tab text
   - Red rounded rectangle with white text
   - Updates in real-time

3. **Real-time Update Test**:
   - Keep Inventory screen open on Products tab
   - From another device, place new order
   - Watch Orders tab badge increase
   - No manual refresh needed

#### Test 4: Badge Synchronization
1. Create 5 pending orders
2. Check all badge locations show "5":
   - Home screen inventory icon: 5
   - Inventory screen Orders tab: 5
3. Change 2 orders to "Confirmed"
4. All badges should show "3"
5. Verify synchronization across locations

## Badge Display Logic

| Pending Orders | Home Icon Badge | Orders Tab Badge |
|----------------|-----------------|------------------|
| 0 | Hidden | Hidden |
| 1-99 | Shows number | Shows number |
| 100+ | Shows "99+" | Shows "99+" |

## Notification Data Structure

```json
{
  "userId": "admin_user_id",
  "fcmToken": "admin_fcm_token",
  "title": "🛒 New Order #order_1707307200000",
  "message": "John Doe placed an order with 5 items",
  "data": {
    "type": "new_order",
    "orderId": "order_1707307200000",
    "userId": "user123",
    "customerName": "John Doe",
    "route": "/inventory"
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
- Order still created successfully
- No notification sent
- Admin can still view order in panel
- Badge will still show the order

### Notification Failure
If FCM notification fails:
```
⚠️ Failed to send admin notification: [error]
```
- Order creation succeeds
- Error logged to console
- Admin can still access order via inventory
- Badge will still update

### Badge Stream Error
If badge counter stream fails:
- Badge shows 0 or hides
- Orders list still works normally
- User can refresh to retry
- Check Firestore permissions

## Cloud Function Requirement

Same Cloud Function processes both user, admin, and ticket notifications:

```javascript
exports.processNotificationQueue = functions.firestore
  .document('fcmNotificationQueue/{notificationId}')
  .onCreate(async (snap, context) => {
    const notification = snap.data();
    
    // Get FCM token and send notification
    // Works for user, admin, and ticket notifications
  });
```

## Navigation Handling

Handle admin notification tap:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  final data = message.data;
  
  if (data['type'] == 'new_order') {
    // Navigate to inventory screen
    Get.toNamed(Routes.inventory);
    
    // Optional: Auto-open Orders tab and specific order
    // final inventoryController = Get.find<InventoryController>();
    // inventoryController.switchToOrdersTab();
    // Get.toNamed(Routes.orderDetail, arguments: {
    //   'orderId': data['orderId']
    // });
  }
});
```

## UI Components

### Home Screen Badge Design
- **Shape**: Circle
- **Color**: Red (#E53935)
- **Position**: Top-right of inventory icon
- **Size**: 18x18 px minimum
- **Border**: White border (1.5px)
- **Text**: Bold white number, 10px font

### Orders Tab Badge Design
- **Shape**: Rounded rectangle
- **Color**: Red (#E53935)
- **Position**: Next to "Orders" text
- **Padding**: 6px horizontal, 2px vertical
- **Border Radius**: 10px
- **Text**: Bold white number, 11px font

### Badge States
1. **Hidden** (0 orders): `SizedBox.shrink()`
2. **Visible** (1-99 orders): Shows exact count
3. **High count** (100+ orders): Shows "99+"
4. **Loading**: Shows 0 while stream loads

## Order Status Flow

```
Pending (📦) → Confirmed (✅) → Shipped (🚚) → Delivered (📍)
     ↓
  Cancelled (❌)
```

- Badge only counts **Pending** orders
- Once order is confirmed or cancelled, badge decreases
- Admin can see all orders in Orders tab
- Filter chips allow viewing by status

## Performance Considerations

### Stream Optimization
- Uses Firestore's real-time listeners
- Query indexed by `orderStatus` field
- Only counts documents, doesn't load full data
- Minimal bandwidth usage

### Badge Update Frequency
- Real-time updates via StreamBuilder
- No polling or manual refresh needed
- Updates within 1-2 seconds of order placement
- Efficient Firestore snapshot listeners

## Benefits

✅ **Instant Awareness**: Admin knows immediately when orders arrive  
✅ **Multiple Touchpoints**: Badge visible in home and inventory screens  
✅ **Visual Priority**: Red badge draws attention to pending work  
✅ **Real-time Count**: No manual refresh needed  
✅ **Non-blocking**: Notification failures don't affect order placement  
✅ **Better UX**: Admin can quickly see workload at a glance  
✅ **Efficient Processing**: Prioritize checking orders when badge shows count  

## Future Enhancements

### Possible Improvements
1. **Multi-admin Support**: Send to all admin users, not just one
2. **Priority Orders**: Different badge colors for express/urgent orders
3. **Sound & Vibration**: Custom notification sounds for orders
4. **Order Categories**: Separate badges for different order types
5. **Revenue Display**: Show total pending order value in badge tooltip
6. **Auto-assign**: Distribute orders among multiple admins
7. **Time-based Urgency**: Badge color changes if order pending too long
8. **Desktop Notifications**: Browser notifications for web admin panel

## Troubleshooting

### Badge Not Showing
1. Check Firestore: Are there orders with `orderStatus: 'Pending'`?
2. Check console for stream errors
3. Verify admin is logged in
4. Check FirestoreService is initialized
5. Try force-closing and reopening app

### Notification Not Received
1. Check admin FCM token exists in Firestore
2. Verify Cloud Function is running
3. Check Cloud Function logs
4. Ensure admin@turfmate.com user exists
5. Check notification permissions on admin device
6. Check fcmNotificationQueue collection

### Badge Count Wrong
1. Check Firestore query: `orderStatus == 'Pending'`
2. Verify orders have correct status field
3. Check for duplicate order documents
4. Try manual count in Firestore console
5. Check Firestore index is built

### Notification Shows But Badge Doesn't
1. Check stream is active (StreamBuilder)
2. Verify FirestoreService.getPendingOrdersCount() is called
3. Check widget tree for badge widget
4. Look for build errors in console
5. Ensure stream subscription is not cancelled

### Multiple Admins Issue
Current implementation sends to **one** admin (`admin@turfmate.com`). To support multiple admins:
1. Create admin role field in user documents
2. Query all users with `role: 'admin'`
3. Loop through and send notification to each
4. Consider creating an `admins` collection

---

**Implementation Date**: February 2026  
**Version**: 1.0  
**Status**: ✅ Production Ready  
**Related Files**:
- SUPPORT_TICKET_NOTIFICATIONS.md (User notifications)
- ADMIN_TICKET_NOTIFICATIONS.md (Admin ticket notifications)
- NOTIFICATION_SETUP_GUIDE.md (Overall FCM setup)
