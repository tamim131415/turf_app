# TurfMate Project - Dialog & Popup Widgets Documentation

## Overview
This document covers all dialog, snackbar, bottom sheet, and popup-related widgets used in the TurfMate project. These widgets provide user feedback, confirmations, and temporary information displays.

---

## 1. AlertDialog Widget

### Purpose
`AlertDialog` displays modal dialogs for confirmations, alerts, and user decisions.

### Usage in TurfMate
- **Exit Confirmation**: Confirm before exiting app
- **Delete Confirmation**: Confirm before removing items
- **Logout Confirmation**: Confirm logout action
- **Error Alerts**: Display error messages
- **Success Messages**: Show operation success

### Key Features Used
```dart
// Simple Alert
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // Perform action
          Navigator.pop(context);
        },
        child: Text('Confirm'),
      ),
    ],
  ),
)

// With custom styling
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    title: Row(
      children: [
        Icon(Icons.warning, color: Colors.orange),
        SizedBox(width: 8),
        Text('Warning'),
      ],
    ),
    content: Text('This action cannot be undone'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(AppStrings.no),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
        ),
        child: Text(AppStrings.yes),
      ),
    ],
  ),
)

// With result
final result = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(/* ... */),
);

if (result == true) {
  // User confirmed
}
```

### Why Used
- **User Confirmation**: Prevents accidental actions
- **Error Display**: Shows error details
- **Important Messages**: Gets user attention
- **Decision Making**: Two or more options

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Exit confirmation
```dart
final shouldExit = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(AppStrings.exitApp),
    content: Text(AppStrings.doYouWantToExit),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(AppStrings.no),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: Text(AppStrings.yes),
      ),
    ],
  ),
);
if (shouldExit ?? false) {
  SystemNavigator.pop();
}
```
- Cart item removal confirmation
- Order cancellation confirmation
- Logout confirmation in profile

---

## 2. Get.snackbar() (GetX Snackbar)

### Purpose
GetX snackbar provides toast-like notifications without context.

### Usage in TurfMate
- **Success Messages**: "Added to cart", "Order placed"
- **Error Messages**: "Failed to load", "No internet"
- **Info Messages**: "Out of stock", "New feature"
- **Warnings**: "Low stock", "Session expiring"

### Key Features Used
```dart
// Simple snackbar
Get.snackbar(
  'Success',
  'Product added to cart',
  backgroundColor: Colors.green[100],
  colorText: Colors.green[800],
);

// Custom styled snackbar
Get.snackbar(
  'Error',
  'Failed to load products',
  backgroundColor: Colors.red[100],
  colorText: Colors.red[800],
  icon: Icon(Icons.error, color: Colors.red),
  snackPosition: SnackPosition.BOTTOM,
  duration: Duration(seconds: 3),
  margin: EdgeInsets.all(16),
  borderRadius: 12,
  isDismissible: true,
  dismissDirection: DismissDirection.horizontal,
);

// With action button
Get.snackbar(
  'Item Removed',
  'Product removed from cart',
  backgroundColor: Colors.orange[100],
  colorText: Colors.orange[800],
  mainButton: TextButton(
    onPressed: () {
      // Undo action
      Get.back();
    },
    child: Text('UNDO', style: TextStyle(color: Colors.orange[800])),
  ),
);

// Different positions
snackPosition: SnackPosition.TOP    // Top of screen
snackPosition: SnackPosition.BOTTOM // Bottom of screen
```

### Why Used
- **No Context**: Can be called from anywhere
- **Clean Code**: Simple one-liner
- **Customizable**: Colors, icons, actions
- **User Feedback**: Non-intrusive notifications

### Examples in Project
- `lib/controllers/product_controller.dart` - Add to cart
```dart
void addToCart(Product product) {
  cartItems.add(CartItem.fromProduct(product));
  Get.snackbar(
    'Success',
    'Added to cart',
    backgroundColor: Colors.green[100],
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: 2),
  );
}
```
- Order placement success
- Error notifications
- Login/logout messages
- Used in **40+** locations

---

## 3. Get.dialog() (GetX Dialog)

### Purpose
GetX dialog for showing dialogs without context.

### Usage in TurfMate
- **Loading Dialogs**: Show processing state
- **Custom Dialogs**: Complex dialog layouts
- **Confirmation Dialogs**: User decisions
- **Info Dialogs**: Display information

### Key Features Used
```dart
// Simple dialog
Get.dialog(
  AlertDialog(
    title: Text('Confirm'),
    content: Text('Delete this item?'),
    actions: [
      TextButton(
        onPressed: () => Get.back(),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // Delete action
          Get.back();
        },
        child: Text('Delete'),
      ),
    ],
  ),
);

// Custom loading dialog
Get.dialog(
  Center(
    child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Processing...'),
        ],
      ),
    ),
  ),
  barrierDismissible: false, // Can't dismiss by tapping outside
);

// With custom widget
Get.dialog(
  Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 60, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Success!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Your order has been placed'),
        ],
      ),
    ),
  ),
);
```

### Why Used
- **No Context**: Can be called from controllers
- **Flexibility**: Any widget can be shown
- **Barrier Control**: Dismissible or not
- **Clean Code**: Simple syntax

### Examples in Project
- Loading dialogs during API calls
- Order placement confirmation
- Payment processing
- Image upload progress

---

## 4. Get.bottomSheet() (GetX Bottom Sheet)

### Purpose
GetX bottom sheet for showing content from bottom of screen.

### Usage in TurfMate
- **Filter Options**: Product filters
- **Sort Options**: Sorting selections
- **Actions Menu**: More options
- **Details Panel**: Additional information

### Key Features Used
```dart
// Simple bottom sheet
Get.bottomSheet(
  Container(
    color: Colors.white,
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Share'),
          onTap: () {
            Get.back();
            // Share action
          },
        ),
        ListTile(
          leading: Icon(Icons.link),
          title: Text('Copy Link'),
          onTap: () {
            Get.back();
            // Copy link action
          },
        ),
      ],
    ),
  ),
);

// With custom styling
Get.bottomSheet(
  Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 40,
          height: 4,
          margin: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Content
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Sort options...
            ],
          ),
        ),
      ],
    ),
  ),
  isDismissible: true,
  enableDrag: true,
);
```

### Why Used
- **Mobile Pattern**: Familiar interaction
- **Space Efficient**: Uses less screen space
- **Easy Dismiss**: Swipe or tap to close
- **Flexible**: Any content

### Examples in Project
- Sort/filter product options
- Share product options
- Language selection
- More actions menu

---

## 5. showModalBottomSheet (Flutter Built-in)

### Purpose
Flutter's built-in modal bottom sheet for displaying content.

### Usage in TurfMate
- **Size Selection**: Product size picker
- **Address Selection**: Choose address
- **Payment Method**: Select payment
- **Custom Forms**: Quick data entry

### Key Features Used
```dart
showModalBottomSheet(
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  isScrollControlled: true, // For tall content
  builder: (context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Size',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...product.sizes.map((size) {
            return ListTile(
              title: Text(size),
              onTap: () {
                Navigator.pop(context, size);
              },
            );
          }).toList(),
        ],
      ),
    );
  },
);

// With padding for keyboard
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: /* Form content */,
    );
  },
);
```

### Why Used
- **Material Design**: Standard component
- **Keyboard Handling**: Adjusts for keyboard
- **Scrollable**: Works with ScrollView
- **Modal**: Blocks other interactions

### Examples in Project
- Size selection in product detail
- Address picker in checkout
- Payment method selection

---

## 6. SnackBar (Flutter Built-in)

### Purpose
Flutter's material design snackbar for brief messages.

### Usage in TurfMate
- **Quick Feedback**: Simple notifications
- **Action Responses**: Operation results
- **Undo Actions**: With action button

### Key Features Used
```dart
// Simple snackbar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Item added to cart'),
    duration: Duration(seconds: 2),
  ),
);

// With action
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Item removed'),
    action: SnackBarAction(
      label: 'UNDO',
      onPressed: () {
        // Undo action
      },
    ),
    duration: Duration(seconds: 3),
  ),
);

// Custom styled
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Success!'),
      ],
    ),
    backgroundColor: Colors.green[700],
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
```

### Why Used
- **Material Design**: Standard component
- **Brief Messages**: Auto-dismiss
- **Action Support**: Undo functionality
- **Non-intrusive**: Doesn't block UI

### Examples in Project
- Success messages
- Error notifications
- Undo actions
- Brief confirmations

---

## 7. Tooltip Widget

### Purpose
Shows helpful text on long press or hover.

### Usage in TurfMate
- **Icon Explanations**: What buttons do
- **Feature Help**: Explain new features
- **Abbreviations**: Full text of acronyms

### Key Features Used
```dart
Tooltip(
  message: 'Add to favorites',
  child: IconButton(
    icon: Icon(Icons.favorite_border),
    onPressed: () {},
  ),
)

// Custom styled
Tooltip(
  message: 'This is a premium feature',
  decoration: BoxDecoration(
    color: Colors.green[700],
    borderRadius: BorderRadius.circular(8),
  ),
  textStyle: TextStyle(color: Colors.white, fontSize: 14),
  padding: EdgeInsets.all(12),
  preferBelow: false, // Show above widget
  child: Icon(Icons.help_outline),
)
```

### Why Used
- **Accessibility**: Helps all users
- **Guidance**: Explains features
- **Clean UI**: No permanent labels
- **Standard Pattern**: Expected behavior

---

## 8. PopupMenuButton Widget

### Purpose
Shows a menu with multiple options on tap.

### Usage in TurfMate
- **More Options**: Three-dot menu
- **Sort Options**: Sorting choices
- **Filter Options**: Quick filters
- **Item Actions**: Edit, delete, share

### Key Features Used
```dart
PopupMenuButton<String>(
  icon: Icon(Icons.more_vert),
  onSelected: (value) {
    switch (value) {
      case 'edit':
        // Edit action
        break;
      case 'delete':
        // Delete action
        break;
      case 'share':
        // Share action
        break;
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit, size: 20),
          SizedBox(width: 8),
          Text('Edit'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete, size: 20, color: Colors.red),
          SizedBox(width: 8),
          Text('Delete', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'share',
      child: Row(
        children: [
          Icon(Icons.share, size: 20),
          SizedBox(width: 8),
          Text('Share'),
        ],
      ),
    ),
  ],
)
```

### Why Used
- **Space Saving**: Hide options until needed
- **Clean UI**: Reduces clutter
- **Standard Pattern**: Familiar three-dot menu
- **Multiple Actions**: Group related actions

### Examples in Project
- Product card options
- Order actions
- Admin options
- Profile menu

---

## 9. Dialog Loading Pattern

### Purpose
Custom loading dialog to show processing state.

### Usage in TurfMate
- **API Calls**: During data fetching
- **Payment Processing**: Transaction processing
- **Order Placement**: Creating order
- **File Upload**: Image upload

### Implementation Pattern
```dart
class LoadingDialog {
  static void show() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.green[700],
                ),
                SizedBox(height: 16),
                Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

// Usage
LoadingDialog.show();
try {
  await performOperation();
} finally {
  LoadingDialog.hide();
}
```

### Why Used
- **User Feedback**: Shows app is working
- **Prevents Interaction**: During processing
- **Professional**: Better than disabled buttons
- **Consistent**: Same loading across app

---

## 10. Success/Error Dialog Pattern

### Purpose
Show operation result with appropriate visuals.

### Implementation Pattern
```dart
class ResultDialog {
  static void showSuccess({
    required String title,
    required String message,
    VoidCallback? onClose,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green[700],
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showError({
    required String title,
    required String message,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                size: 60,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Summary

### Dialog/Popup Hierarchy in TurfMate
```
Dialogs & Popups:
├── AlertDialog (Confirmations, alerts)
├── Get.snackbar() (Toast notifications)
├── Get.dialog() (Custom dialogs)
├── Get.bottomSheet() (Bottom panels)
├── showModalBottomSheet() (Selections)
├── SnackBar (Brief messages)
├── Tooltip (Help text)
└── PopupMenuButton (Options menu)
```

### Usage Statistics
- **Get.snackbar()**: 40+ instances (most used)
- **AlertDialog**: 20+ instances
- **Get.dialog()**: 15+ instances
- **Bottom Sheets**: 10+ instances
- **PopupMenuButton**: 5+ instances

### Common Patterns

#### Confirmation Pattern
```dart
final confirm = await Get.dialog<bool>(
  AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Get.back(result: false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Get.back(result: true),
        child: Text('Confirm'),
      ),
    ],
  ),
);

if (confirm == true) {
  // Proceed
}
```

#### Success Notification Pattern
```dart
Get.snackbar(
  'Success',
  message,
  backgroundColor: Colors.green[100],
  colorText: Colors.green[800],
  icon: Icon(Icons.check_circle, color: Colors.green[700]),
  snackPosition: SnackPosition.BOTTOM,
  duration: Duration(seconds: 2),
);
```

### Best Practices
- ✅ Use Get.snackbar() for notifications
- ✅ Use AlertDialog for confirmations
- ✅ Show loading during async operations
- ✅ Provide action buttons where appropriate
- ✅ Make dialogs dismissible when appropriate
- ✅ Use consistent colors (green=success, red=error)
- ✅ Keep messages concise and clear
- ✅ Always hide loading dialogs in finally block

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
