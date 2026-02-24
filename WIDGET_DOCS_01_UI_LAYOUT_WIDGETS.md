# TurfMate Project - UI Layout Widgets Documentation

## Overview
This document covers all the layout widgets used throughout the TurfMate project. Layout widgets are the foundation of Flutter UI, providing structure and positioning for other widgets.

---

## 1. Container Widget

### Purpose
`Container` is the most versatile widget for creating visual elements with decoration, constraints, and positioning.

### Usage in TurfMate
- **Product Cards**: Creating styled boxes with shadows and borders
- **Category Sections**: Building decorated containers for different sections
- **Status Indicators**: Displaying order status with colored backgrounds

### Key Features Used
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: // child widget
)
```

### Why Used
- Provides visual styling with colors, borders, and shadows
- Controls spacing with padding and margin
- Enables sizing constraints
- Essential for creating modern UI designs

### Examples in Project
- `lib/widgets/product_card.dart` - Product display containers
- `lib/screens/cart/cart_screen.dart` - Cart item containers
- `lib/screens/inventory/admin_orders_screen.dart` - Order cards
- `lib/screens/home/home_screen.dart` - Category containers

---

## 2. Column Widget

### Purpose
`Column` arranges child widgets vertically in a linear fashion.

### Usage in TurfMate
- **Form Layouts**: Stacking input fields vertically
- **Product Details**: Arranging product information top to bottom
- **List Sections**: Organizing content in vertical sequences

### Key Features Used
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.center,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text('Title'),
    SizedBox(height: 8),
    Text('Description'),
    // more widgets
  ],
)
```

### Why Used
- Natural way to stack content vertically
- Flexible alignment options
- Easy to add spacing between items
- Perfect for forms and detail screens

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Login form layout
- `lib/screens/product/product_detail_screen.dart` - Product information
- `lib/screens/orders/user_order_detail_screen.dart` - Order details
- `lib/screens/support/help_support_screen.dart` - Support sections

---

## 3. Row Widget

### Purpose
`Row` arranges child widgets horizontally in a linear layout.

### Usage in TurfMate
- **Icon-Text Combinations**: Displaying icons with labels
- **Action Buttons**: Placing multiple buttons side by side
- **Info Displays**: Showing label-value pairs horizontally
- **Quantity Controls**: Increment/decrement buttons with counter

### Key Features Used
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Icon(Icons.info),
    SizedBox(width: 8),
    Text('Information'),
    Spacer(),
    Icon(Icons.arrow_forward),
  ],
)
```

### Why Used
- Horizontal arrangement of elements
- Flexible spacing distribution
- Easy alignment control
- Essential for navigation and action bars

### Examples in Project
- `lib/widgets/cart_item.dart` - Quantity controls
- `lib/screens/inventory/admin_orders_screen.dart` - Order info rows
- `lib/screens/orders/user_order_detail_screen.dart` - Detail rows
- `lib/screens/home/home_screen.dart` - Action buttons

---

## 4. Stack Widget

### Purpose
`Stack` allows overlapping of widgets, positioning them on top of each other.

### Usage in TurfMate
- **Product Images**: Overlaying favorite buttons on product images
- **Badges**: Adding notification badges on icons
- **Image Overlays**: Displaying text or icons over images
- **Floating Actions**: Positioning buttons over content

### Key Features Used
```dart
Stack(
  children: [
    // Base layer (image)
    Container(/* image */),
    
    // Overlay layer
    Positioned(
      top: 8,
      right: 8,
      child: IconButton(/* favorite button */),
    ),
  ],
)
```

### Why Used
- Creates layered UI elements
- Enables floating/overlay effects
- Perfect for badges and overlays
- Provides precise positioning control

### Examples in Project
- `lib/widgets/product_card.dart` - Favorite button overlay on product image
- `lib/screens/onboarding/onboarding_screen.dart` - Skip button overlay
- `lib/screens/product/product_detail_screen.dart` - Image overlays
- `lib/screens/home/home_screen.dart` - Badge overlays on cart icon

---

## 5. Positioned Widget

### Purpose
`Positioned` controls the exact position of a child within a Stack.

### Usage in TurfMate
- **Badge Positioning**: Placing notification counts on icons
- **Button Overlays**: Positioning action buttons on images
- **Corner Elements**: Adding elements to specific corners

### Key Features Used
```dart
Positioned(
  top: 10,
  right: 10,
  child: Container(/* badge */),
)

// or with multiple constraints
Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  child: Widget(),
)
```

### Why Used
- Precise positioning within Stack
- Control over element placement
- Essential for overlays and badges
- Creates professional UI layouts

### Examples in Project
- `lib/widgets/product_card.dart` - Heart icon positioning
- `lib/screens/onboarding/onboarding_screen.dart` - Skip button
- `lib/screens/home/home_screen.dart` - Cart badge positioning

---

## 6. SafeArea Widget

### Purpose
`SafeArea` ensures content is displayed within safe boundaries, avoiding system UI overlaps.

### Usage in TurfMate
- **Screen Layouts**: Wrapping main content in all screens
- **Preventing Notch Overlap**: Avoiding content under device notches
- **System UI Avoidance**: Keeping content away from status bars

### Key Features Used
```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [/* content */],
    ),
  ),
)
```

### Why Used
- Cross-device compatibility
- Prevents content being hidden by system UI
- Professional appearance on all devices
- Essential for modern device support (notches, rounded corners)

### Examples in Project
- `lib/screens/splash/splash_screen.dart`
- `lib/screens/product/product_detail_screen.dart`
- `lib/screens/inventory/inventory_detail_screen.dart`
- `lib/screens/onboarding/onboarding_screen.dart`

---

## 7. Padding Widget

### Purpose
`Padding` adds spacing around a widget.

### Usage in TurfMate
- **Content Spacing**: Adding margins to text and elements
- **Button Spacing**: Creating breathing room around buttons
- **Section Separation**: Separating different UI sections

### Key Features Used
```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Content'),
)

// Symmetric padding
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  ),
  child: Widget(),
)
```

### Why Used
- Cleaner code than Container for simple spacing
- Better readability
- Consistent spacing throughout app
- Responsive design support

### Examples in Project
- `lib/screens/cart/cart_screen.dart` - Screen padding
- `lib/widgets/cart_item.dart` - Item padding
- `lib/screens/explore/explore_screen.dart` - Section padding

---

## 8. SizedBox Widget

### Purpose
`SizedBox` creates fixed-size boxes or spacing between widgets.

### Usage in TurfMate
- **Vertical Spacing**: Adding space between stacked elements
- **Horizontal Spacing**: Creating gaps in rows
- **Fixed Sizing**: Setting explicit width/height for widgets
- **Empty Space**: Creating visual breathing room

### Key Features Used
```dart
// Vertical spacing
SizedBox(height: 20),

// Horizontal spacing
SizedBox(width: 10),

// Fixed size container
SizedBox(
  width: 100,
  height: 50,
  child: Widget(),
)
```

### Why Used
- Lightweight and efficient
- Simple spacing solution
- Fixed dimensions when needed
- Better performance than Empty Container

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Form field spacing
- `lib/screens/home/home_screen.dart` - Section spacing
- `lib/screens/product/product_detail_screen.dart` - Content spacing
- Used extensively throughout all screens

---

## 9. Expanded Widget

### Purpose
`Expanded` makes a child fill available space in Row, Column, or Flex.

### Usage in TurfMate
- **Flexible Layouts**: Distributing space among children
- **Responsive Design**: Adapting to different screen sizes
- **List Views**: Taking remaining screen space
- **Text Overflow**: Allowing text to take available space

### Key Features Used
```dart
Row(
  children: [
    Icon(Icons.info),
    SizedBox(width: 8),
    Expanded(
      child: Text('Long text that can wrap'),
    ),
    Icon(Icons.arrow_forward),
  ],
)
```

### Why Used
- Responsive layouts without fixed sizes
- Prevents overflow errors
- Creates flexible, adaptive designs
- Essential for multi-screen-size support

### Examples in Project
- `lib/widgets/cart_item.dart` - Product name and price
- `lib/screens/inventory/admin_orders_screen.dart` - Order list
- `lib/screens/home/home_screen.dart` - Product grid
- `lib/screens/orders/user_order_detail_screen.dart` - Detail sections

---

## 10. Flexible Widget

### Purpose
`Flexible` gives a child the flexibility to expand based on flex factor.

### Usage in TurfMate
- **Proportional Sizing**: Distributing space with specific ratios
- **Optional Expansion**: Unlike Expanded, it doesn't force expansion
- **Responsive Grids**: Creating adaptive layouts

### Key Features Used
```dart
Row(
  children: [
    Flexible(
      flex: 2,
      child: Widget1(),
    ),
    Flexible(
      flex: 1,
      child: Widget2(),
    ),
  ],
)
```

### Why Used
- More control than Expanded
- Proportional space distribution
- Flexible responsive designs
- Works well with varying content sizes

### Examples in Project
- Used in various responsive layouts throughout the app
- Product grids with varying item sizes
- Form layouts with proportional fields

---

## Summary

### Most Used Layout Widgets
1. **Container** - 150+ instances
2. **Column** - 120+ instances  
3. **Row** - 100+ instances
4. **SizedBox** - 90+ instances
5. **Stack** - 20+ instances

### Best Practices Applied
- Consistent spacing using SizedBox
- SafeArea for all main screens
- Container for styled elements
- Expanded for responsive layouts
- Proper nesting to avoid deep widget trees

### Performance Considerations
- SizedBox preferred over Empty Container for spacing
- Const constructors used where possible
- Minimal nesting depth maintained
- Efficient use of Expanded vs Flexible

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x
