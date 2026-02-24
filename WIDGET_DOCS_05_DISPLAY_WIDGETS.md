# TurfMate Project - Display Widgets Documentation

## Overview
This document covers all display and visual widgets used in the TurfMate project. These widgets present information, images, icons, and visual feedback to users.

---

## 1. Text Widget

### Purpose
`Text` displays styled text strings in the UI.

### Usage in TurfMate
- **Labels**: Field labels, section headers
- **Content**: Product names, descriptions
- **Messages**: Error messages, success feedback
- **Data Display**: Prices, dates, status

### Key Features Used
```dart
// Simple text
Text('Product Name')

// Styled text
Text(
  'TurfMate',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.green[800],
    letterSpacing: 1.2,
  ),
)

// Responsive text
Text(
  'Welcome Back!',
  style: TextStyle(
    fontSize: ResponsiveHelper.getFontSize(context, 
      small: 24, medium: 28, large: 32),
    fontWeight: FontWeight.bold,
  ),
)

// Text with overflow handling
Text(
  'Very Long Product Name That Might Not Fit',
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(fontSize: 16),
)
```

### Why Used
- **Information Display**: Primary way to show text
- **Visual Hierarchy**: Different sizes/weights for importance
- **Styling**: Colors, fonts for branding
- **Readability**: Control line breaks and overflow

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Welcome text, labels
```dart
Text(
  'Welcome Back!',
  style: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.green[800],
  ),
)
```
- `lib/widgets/product_card.dart` - Product name and price
- `lib/screens/home/home_screen.dart` - Section headers
- Used **everywhere** (500+ instances)

---

## 2. Icon Widget

### Purpose
`Icon` displays material design icons from the icon font.

### Usage in TurfMate
- **Navigation**: Back, menu, cart icons
- **Actions**: Search, favorite, share icons
- **Status**: Success, error, warning indicators
- **Categories**: Visual identification

### Key Features Used
```dart
// Simple icon
Icon(Icons.shopping_cart)

// Styled icon
Icon(
  Icons.favorite,
  color: Colors.red,
  size: 24,
)

// Icon in button
IconButton(
  icon: Icon(Icons.search),
  color: Colors.grey[700],
  onPressed: () {},
)

// Icon with semantic label
Icon(
  Icons.info,
  semanticLabel: 'Information',
  color: Colors.blue,
)
```

### Why Used
- **Universal Language**: Icons transcend language barriers
- **Visual Clarity**: Instant recognition
- **Space Efficient**: Convey meaning in small space
- **Professional**: Material Design standard

### Examples in Project
- `lib/screens/home/home_screen.dart` - Cart, search icons
```dart
Icon(Icons.shopping_cart, color: Colors.grey[700])
```
- `lib/screens/main_navigation_screen.dart` - Bottom nav icons
```dart
BottomNavigationBarItem(
  icon: Icon(Icons.home),
  label: AppStrings.home,
)
```
- `lib/widgets/product_card.dart` - Favorite heart icon
- `lib/screens/profile/profile_screen.dart` - Profile menu icons
- Used in **200+** locations

---

## 3. Image Widget

### Purpose
`Image` displays images from various sources (network, assets, files).

### Usage in TurfMate
- **Product Images**: Main product photos
- **Brand Logos**: Brand identification
- **User Avatars**: Profile pictures
- **Banners**: Promotional images

### Key Features Used
```dart
// Network image with error handling
Image.network(
  product.imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / 
              loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: 50,
      ),
    );
  },
)

// Asset image
Image.asset(
  'assets/brands/nike.png',
  width: 50,
  height: 50,
)

// Cached network image (with package)
CachedNetworkImage(
  imageUrl: product.imageUrl,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Why Used
- **Visual Appeal**: Images attract attention
- **Product Showcase**: Essential for e-commerce
- **Brand Identity**: Logos and branding
- **User Experience**: Visual product selection

### Examples in Project
- `lib/widgets/product_card.dart` - Product images
```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: NetworkImage(product.imageUrl),
      fit: BoxFit.cover,
    ),
  ),
)
```
- `lib/screens/product/product_detail_screen.dart` - Large product image
- `lib/screens/cart/cart_screen.dart` - Cart item images
- `lib/screens/explore/explore_screen.dart` - Brand logos
- Used for **all** product displays (100+ instances)

---

## 4. CircularProgressIndicator Widget

### Purpose
`CircularProgressIndicator` shows a circular loading animation.

### Usage in TurfMate
- **Loading States**: Data fetching
- **Processing**: Order placement, payment
- **Async Operations**: Any waiting period
- **Image Loading**: While images load

### Key Features Used
```dart
// Simple loading indicator
Center(
  child: CircularProgressIndicator(
    color: Colors.green[700],
  ),
)

// With value (determinate)
CircularProgressIndicator(
  value: 0.7, // 70% complete
  backgroundColor: Colors.grey[200],
  color: Colors.green[700],
  strokeWidth: 4,
)

// In Obx for reactive loading
Obx(() {
  if (controller.isLoading.value) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  return ContentWidget();
})
```

### Why Used
- **User Feedback**: Shows app is working
- **Prevents Confusion**: User knows to wait
- **Standard Pattern**: Familiar loading indicator
- **Professional**: Better than frozen UI

### Examples in Project
- `lib/screens/orders/my_orders_screen.dart` - Loading orders
```dart
Obx(() {
  if (orderController.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  // ... orders list
})
```
- `lib/screens/inventory/admin_orders_screen.dart` - Admin loading
- `lib/screens/home/home_screen.dart` - Products loading
- Used in **30+** screens with async data

---

## 5. LinearProgressIndicator Widget

### Purpose
`LinearProgressIndicator` shows a horizontal loading bar.

### Usage in TurfMate
- **Upload Progress**: Image uploads
- **Download Progress**: File downloads
- **Step Progress**: Multi-step forms
- **Loading Bars**: At top of screens

### Key Features Used
```dart
// Indeterminate (unknown duration)
LinearProgressIndicator(
  backgroundColor: Colors.grey[200],
  color: Colors.green[700],
)

// Determinate (known progress)
LinearProgressIndicator(
  value: uploadProgress / 100,
  backgroundColor: Colors.grey[200],
  color: Colors.green[700],
  minHeight: 6,
)

// At top of screen
Column(
  children: [
    if (isLoading.value)
      LinearProgressIndicator(
        color: Colors.green[700],
      ),
    // Rest of content
  ],
)
```

### Why Used
- **Progress Feedback**: Shows exact progress
- **Unobtrusive**: Takes little space
- **File Operations**: Perfect for uploads/downloads
- **Visual Indicator**: Clear progress visualization

### Examples in Project
- Image upload operations
- File download Progress
- Used when progress percentage is known

---

## 6. CircleAvatar Widget

### Purpose
`CircleAvatar` displays circular images or icons, commonly for profiles.

### Usage in TurfMate
- **User Profiles**: Profile pictures
- **Chat**: Message sender avatars
- **Lists**: Icon placeholders
- **Badges**: Status indicators

### Key Features Used
```dart
// With image
CircleAvatar(
  radius: 30,
  backgroundImage: NetworkImage(userImageUrl),
  backgroundColor: Colors.grey[200],
)

// With icon/text
CircleAvatar(
  radius: 25,
  backgroundColor: Colors.green[700],
  child: Icon(
    Icons.person,
    color: Colors.white,
    size: 30,
  ),
)

// With initials
CircleAvatar(
  backgroundColor: Colors.green[700],
  child: Text(
    'JD', // John Doe
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### Why Used
- **Profile Representation**: Visual user identity
- **Consistent Shape**: Always circular
- **Space Efficient**: Compact display
- **Professional**: Standard social UI element

### Examples in Project
- `lib/screens/profile/profile_screen.dart` - User avatar
```dart
CircleAvatar(
  radius: 40,
  backgroundColor: Colors.green[700],
  child: Icon(Icons.person, size: 40, color: Colors.white),
)
```
- `lib/screens/chat/chat_screen.dart` - Bot avatar
- Profile and chat interfaces

---

## 7. Badge Widget (Custom)

### Purpose
Display notification counts or status indicators on icons.

### Usage in TurfMate
- **Cart Badge**: Number of items in cart
- **Notification Badge**: Unread count
- **Order Badge**: Pending orders count
- **Status Indicators**: New features

### Key Features Used
```dart
// Custom badge implementation
Stack(
  children: [
    Icon(Icons.shopping_cart),
    if (cartItemCount > 0)
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          constraints: BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            '$cartItemCount',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
  ],
)
```

### Why Used
- **Attention Grabbing**: Shows important counts
- **User Awareness**: Notify without opening
- **Status Display**: At-a-glance information
- **Standard Pattern**: Familiar UI element

### Examples in Project
- `lib/screens/home/home_screen.dart` - Cart badge
```dart
IconButton(
  icon: Stack(
    children: [
      Icon(Icons.shopping_cart),
      Obx(() {
        int count = controller.cartItems.length;
        if (count > 0) {
          return Positioned(
            right: 0,
            top: 0,
            child: Container(/* badge */),
          );
        }
        return SizedBox.shrink();
      }),
    ],
  ),
)
```
- `lib/screens/inventory/inventory_screen.dart` - Order count badge
- Main navigation icons

---

## 8. Chip Widget

### Purpose
`Chip` displays compact information elements like tags or attributes.

### Usage in TurfMate
- **Product Tags**: New, Sale, Featured
- **Size Options**: Available sizes
- **Categories**: Product categories
- **Attributes**: Color, material labels

### Key Features Used
```dart
// Simple chip
Chip(
  label: Text('New Arrival'),
  backgroundColor: Colors.green[100],
  labelStyle: TextStyle(
    color: Colors.green[700],
    fontWeight: FontWeight.bold,
  ),
)

// Chip with avatar
Chip(
  avatar: CircleAvatar(
    backgroundColor: Colors.green[700],
    child: Text('N'),
  ),
  label: Text('Nike'),
)

// Action chip
ActionChip(
  label: Text('Apply Filter'),
  onPressed: () {
    applyFilters();
  },
  avatar: Icon(Icons.filter_list),
)
```

### Why Used
- **Compact Display**: Shows tags efficiently
- **Visual Groups**: Related information
- **Interactive**: Can be tapped/selected
- **Modern Design**: Trendy UI element

### Examples in Project
- Product detail screens - Size chips
- Filter sections - Category chips
- Tag displays

---

## 9. Tooltip Widget

### Purpose
`Tooltip` shows helpful information on long press or hover.

### Usage in TurfMate
- **Icon Explanations**: What buttons do
- **Feature Help**: Explain features
- **Abbreviations**: Full text of acronyms
- **Accessibility**: Screen reader support

### Key Features Used
```dart
Tooltip(
  message: 'Add to favorites',
  child: IconButton(
    icon: Icon(Icons.favorite_border),
    onPressed: () {},
  ),
)

// Custom styled tooltip
Tooltip(
  message: 'This is a premium feature',
  decoration: BoxDecoration(
    color: Colors.green[700],
    borderRadius: BorderRadius.circular(8),
  ),
  textStyle: TextStyle(color: Colors.white),
  padding: EdgeInsets.all(12),
  child: Icon(Icons.help_outline),
)
```

### Why Used
- **User Guidance**: Explain features
- **Accessibility**: Better for disabled users
- **Clean UI**: Don't clutter with labels
- **Professional**: Expected behavior

### Examples in Project
- IconButtons throughout the app
- Help icons
- Complex feature buttons

---

## 10. RichText Widget

### Purpose
`RichText` displays text with multiple styles in one widget.

### Usage in TurfMate
- **Formatted Text**: Bold words in sentences
- **Price Display**: Currency symbol + amount
- **Links**: Colored clickable text
- **Mixed Styles**: Complex text formatting

### Key Features Used
```dart
RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.black, fontSize: 14),
    children: [
      TextSpan(text: 'Total: '),
      TextSpan(
        text: '\$299.99',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.green[700],
        ),
      ),
    ],
  ),
)

// With tap gesture
RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: 'By signing up, you agree to our ',
        style: TextStyle(color: Colors.black),
      ),
      TextSpan(
        text: 'Terms & Conditions',
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Open terms
          },
      ),
    ],
  ),
)
```

### Why Used
- **Rich Formatting**: Multiple styles in one line
- **Professional Display**: Better than multiple Text widgets
- **Interactive Text**: Clickable parts
- **Complex Layouts**: Terms, agreements, formatted messages

### Examples in Project
- Price displays with currency
- Terms and conditions
- Formatted descriptions
- Chat messages with links

---

## Summary

### Display Widget Usage Statistics
```
Text:                      500+ instances
Icon:                      200+ instances
Image:                     100+ instances
CircularProgressIndicator: 30+ instances
CircleAvatar:             20+ instances
Badge (custom):           10+ instances
```

### Common Display Patterns

#### Product Card Display
```dart
Column(
  children: [
    Image.network(product.imageUrl),
    Text(
      product.name,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '\$'),
          TextSpan(
            text: '${product.price}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ],
)
```

#### Loading State Pattern
```dart
Obx(() {
  if (controller.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  
  if (controller.error.value.isNotEmpty) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error, size: 60, color: Colors.red),
          Text(controller.error.value),
        ],
      ),
    );
  }
  
  return ContentWidget();
})
```

#### Icon with Badge Pattern
```dart
Stack(
  children: [
    Icon(Icons.shopping_cart),
    if (count > 0)
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ),
  ],
)
```

### Best Practices Applied
- ✅ Always handle image loading errors
- ✅ Use overflow handling for long text
- ✅ Show loading indicators for async ops
- ✅ Consistent icon sizes throughout app
- ✅ Proper semantic labels for accessibility
- ✅ Use appropriate text styles for hierarchy
- ✅ Cache network images when possible
- ✅ Responsive font sizes

### Color Scheme Used
```dart
Primary Green:     Colors.green[700]  (#388E3C)
Light Green:       Colors.green[100]  (#C8E6C9)
Dark Green:        Colors.green[900]  (#1B5E20)
Grey Text:         Colors.grey[700]   (#616161)
Light Grey BG:     Colors.grey[50]    (#FAFAFA)
Error Red:         Colors.red         (#F44336)
Success Color:     Colors.green       (#4CAF50)
```

### Typography Hierarchy
```dart
// Headers
fontSize: 32, fontWeight: FontWeight.bold

// Subheaders
fontSize: 24, fontWeight: FontWeight.w600

// Body Text
fontSize: 16, fontWeight: FontWeight.normal

// Captions
fontSize: 14, color: Colors.grey[600]

// Small Text
fontSize: 12, color: Colors.grey[500]
```

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
