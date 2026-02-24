# TurfMate Project - List & Grid Widgets Documentation

## Overview
This document covers all list and grid-related widgets used in the TurfMate project. These widgets efficiently display scrollable collections of data and are crucial for performance.

---

## 1. ListView Widget

### Purpose
`ListView` displays a scrollable list of widgets arranged linearly.

### Usage in TurfMate
- **Product Lists**: Displaying filtered products
- **Order History**: Showing user's orders
- **Ticket List**: Support tickets
- **Settings Menus**: List of settings options

### Key Features Used
```dart
// Simple ListView
ListView(
  padding: EdgeInsets.all(16),
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)

// ListView.builder for dynamic lists
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    final product = products[index];
    return ProductCard(product: product);
  },
  padding: EdgeInsets.symmetric(horizontal: 16),
)

// ListView.separated with dividers
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index]));
  },
)
```

### Why Used
- Efficient for scrollable content
- Lazy loading with builder
- Built-in scroll physics
- Memory efficient for long lists

### Examples in Project
- `lib/screens/wishlist/wishlist_screen.dart` - Wishlist items
- `lib/screens/orders/my_orders_screen.dart` - Order history
- `lib/screens/support/user_tickets_screen.dart` - Support tickets
- `lib/screens/explore/explore_screen.dart` - Categories and sections
- `lib/screens/support/help_support_screen.dart` - Help options
- Used in **20+** screens

---

## 2. ListView.builder

### Purpose
`ListView.builder` creates list items on-demand as they scroll into view (lazy loading).

### Usage in TurfMate
- **Large Product Lists**: Thousands of products
- **Order History**: Many orders over time
- **Chat Messages**: Long conversation histories
- **Notifications**: Multiple notifications

### Key Features Used
```dart
ListView.builder(
  itemCount: controller.products.length,
  itemBuilder: (BuildContext context, int index) {
    final product = controller.products[index];
    return ProductCard(product: product);
  },
  // Performance optimizations
  physics: AlwaysScrollableScrollPhysics(),
  shrinkWrap: false, // Better performance
  // Add more items per scroll
  cacheExtent: 100,
)
```

### Why Used
- **Performance**: Only builds visible items
- **Memory Efficient**: Doesn't load all items at once
- **Scalability**: Handles thousands of items
- **Smooth Scrolling**: Better frame rates

### Examples in Project
- `lib/screens/inventory/admin_orders_screen.dart` - Order cards
```dart
ListView.builder(
  itemCount: filteredOrders.length,
  itemBuilder: (context, index) {
    final order = filteredOrders[index];
    return _buildOrderCard(order);
  },
)
```
- `lib/screens/chat/chat_screen.dart` - Chat messages
- `lib/screens/support/user_tickets_screen.dart` - Ticket list
- Primary list widget (**most used** for dynamic lists)

---

## 3. GridView Widget

### Purpose
`GridView` displays widgets in a 2D scrollable grid.

### Usage in TurfMate
- **Product Catalog**: Grid of product cards
- **Category Grid**: Visual category selection
- **Image Gallery**: Product images
- **Dashboard Tiles**: Admin summary cards

### Key Features Used
```dart
// GridView with fixed cross-axis count
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 15,
    mainAxisSpacing: 15,
    childAspectRatio: 0.7, // Width/Height ratio
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(), // When inside another scroll view
)

// Responsive grid
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridColumns(context),
    // Mobile: 2, Tablet: 3, Desktop: 4
  ),
  // ...
)
```

### Why Used
- **Visual Display**: Better product showcase
- **Space Efficient**: More items visible
- **Modern Design**: Grid layouts are trendy
- **Responsive**: Adapts to screen sizes

### Examples in Project
- `lib/screens/home/home_screen.dart` - Product grid
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridColumns(context),
    crossAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
    mainAxisSpacing: ResponsiveHelper.isMobile(context) ? 12 : 16,
    childAspectRatio: 0.7,
  ),
  // ...
)
```
- `lib/screens/explore/explore_screen.dart` - Category grid
- `lib/screens/product/all_products_screen.dart` - All products
- Used for **product displays** primarily

---

## 4. ListTile Widget

### Purpose
`ListTile` is a single fixed-height row with leading/trailing widgets and text.

### Usage in TurfMate
- **Settings Options**: Menu items with icons
- **Profile Options**: User menu items
- **Drawer Menu**: Navigation drawer items
- **Selection Lists**: Selectable options

### Key Features Used
```dart
ListTile(
  leading: CircleAvatar(
    backgroundColor: Colors.green[700],
    child: Icon(Icons.person, color: Colors.white),
  ),
  title: Text(
    'User Name',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Text('user@email.com'),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Get.toNamed(Routes.profile);
  },
)
```

### Why Used
- **Standard Pattern**: Familiar to users
- **Consistent Design**: Built-in styling
- **Easy to Use**: Less code needed
- **Accessible**: Good for screen readers

### Examples in Project
- `lib/screens/profile/profile_screen.dart` - Profile options
```dart
ListTile(
  leading: Icon(Icons.shopping_bag, color: Colors.green[700]),
  title: Text(AppStrings.myOrders),
  trailing: Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => Get.toNamed(Routes.orders),
)
```
- `lib/screens/support/help_support_screen.dart` - Help options
- Drawer menus
- Settings screens
- Used in **30+** locations

---

## 5. Card Widget

### Purpose
`Card` creates a material design card with rounded corners and elevation.

### Usage in TurfMate
- **Product Cards**: Individual product displays
- **Order Cards**: Order summary displays
- **Info Cards**: Grouped information
- **List Items**: Elevated list items

### Key Features Used
```dart
Card(
  elevation: 3,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title'),
        SizedBox(height: 8),
        Text('Content'),
      ],
    ),
  ),
)
```

### Why Used
- **Visual Hierarchy**: Elevated content stands out
- **Material Design**: Standard component
- **Grouping**: Contains related information
- **Professional Look**: Clean, modern appearance

### Examples in Project
- `lib/widgets/cart_item.dart` - Cart item cards
```dart
Card(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Row(/* cart item content */),
  ),
)
```
- `lib/screens/inventory/admin_orders_screen.dart` - Order cards
- `lib/widgets/wishlist_item.dart` - Wishlist cards
- `lib/screens/support/user_tickets_screen.dart` - Ticket cards
- Used extensively (**50+** instances)

---

## 6. SingleChildScrollView Widget

### Purpose
`SingleChildScrollView` makes any widget scrollable.

### Usage in TurfMate
- **Forms**: Long forms that may not fit on screen
- **Detail Screens**: Product/order details
- **Content Pages**: Terms, privacy policy
- **Nested Scrolling**: When ListView is inside

### Key Features Used
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(16),
  physics: AlwaysScrollableScrollPhysics(),
  child: Column(
    children: [
      // Many widgets that may overflow
      Widget1(),
      Widget2(),
      // ...
    ],
  ),
)
```

### Why Used
- **Overflow Prevention**: Avoids layout errors
- **Flexibility**: Works with any widget
- **Pull-to-Refresh**: Can wrap RefreshIndicator
- **Simple Solution**: Quick scrolling fix

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Login form
```dart
SingleChildScrollView(
  padding: EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [/* login form */],
  ),
)
```
- `lib/screens/product/product_detail_screen.dart` - Product details
- `lib/screens/home/home_screen.dart` - Home content
- All forms to prevent keyboard overflow
- Used in **30+** screens

---

## 7. RefreshIndicator Widget

### Purpose
`RefreshIndicator` adds pull-to-refresh functionality to scrollable widgets.

### Usage in TurfMate
- **Product Lists**: Refresh product catalog
- **Order History**: Update order status
- **Notifications**: Fetch new notifications
- **Any Dynamic Content**: User-triggered refresh

### Key Features Used
```dart
RefreshIndicator(
  onRefresh: () async {
    await productController.loadProducts();
  },
  color: Colors.green[700],
  child: ListView.builder(
    physics: AlwaysScrollableScrollPhysics(), // Required!
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ItemWidget(items[index]);
    },
  ),
)
```

### Why Used
- **User Control**: Manual data refresh
- **Updated Content**: Fetch latest data
- **Standard Pattern**: Familiar interaction
- **Feedback**: Visual loading indicator

### Examples in Project
- `lib/screens/home/home_screen.dart` - Refresh products
```dart
RefreshIndicator(
  onRefresh: () async {
    productController.loadProducts();
  },
  child: SingleChildScrollView(/* content */),
)
```
- `lib/screens/orders/my_orders_screen.dart` - Refresh orders
- `lib/screens/inventory/admin_orders_screen.dart` - Admin refresh
- `lib/screens/explore/explore_screen.dart` - Explore refresh
- Used on **all** main list screens

---

## 8. Wrap Widget

### Purpose
`Wrap` flows children horizontally and vertically, wrapping to next line when needed.

### Usage in TurfMate
- **Filter Chips**: Wrapping filter options
- **Tag Display**: Product tags that wrap
- **Size Options**: Product size chips
- **Category Pills**: Wrapping category labels

### Key Features Used
```dart
Wrap(
  spacing: 8, // Horizontal spacing
  runSpacing: 8, // Vertical spacing
  children: filters.map((filter) {
    return FilterChip(
      label: Text(filter),
      selected: selectedFilter == filter,
      onSelected: (selected) {
        setState(() => selectedFilter = filter);
      },
    );
  }).toList(),
)
```

### Why Used
- **Responsive Layout**: Auto wraps on small screens
- **Flexible**: Adapts to content
- **Clean Code**: Simple implementation
- **Visual Appeal**: Natural flow

### Examples in Project
- `lib/screens/inventory/admin_orders_screen.dart` - Status filters
```dart
Wrap(
  spacing: 8,
  children: statusFilters.map((filter) {
    return FilterChip(/* filter chip */);
  }).toList(),
)
```
- `lib/screens/product/product_detail_screen.dart` - Size options
- Filter sections throughout the app

---

## 9. Expanded & Flexible in Lists

### Purpose
Control how list items take up available space within rows/columns.

### Usage in TurfMate
- **Cart Items**: Balance image, text, and buttons
- **Order Rows**: Distribute order information
- **List Tiles**: Proper text wrapping
- **Responsive Layouts**: Adapt to screen width

### Key Features Used
```dart
Row(
  children: [
    // Fixed size image
    Container(
      width: 80,
      height: 80,
      child: /* product image */,
    ),
    SizedBox(width: 12),
    
    // Flexible text that takes remaining space
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Name That Might Be Very Long',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text('Price: \$99'),
        ],
      ),
    ),
    
    // Fixed size button
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {},
    ),
  ],
)
```

### Why Used
- **Prevents Overflow**: Text doesn't break layout
- **Responsive**: Adapts to screen sizes
- **Professional**: Clean, working layouts
- **Flexible Distribution**: Smart space allocation

### Examples in Project
- `lib/widgets/cart_item.dart` - Cart item layout
- `lib/screens/inventory/admin_orders_screen.dart` - Order card layout
- `lib/screens/orders/user_order_detail_screen.dart` - Order item layout
- Used in **most** list item widgets

---

## 10. Divider Widget

### Purpose
`Divider` creates a horizontal line to separate content.

### Usage in TurfMate
- **List Separation**: Between list items
- **Section Breaks**: Separate content sections
- **Visual Grouping**: Group related items
- **Menu Separation**: Between menu options

### Key Features Used
```dart
// Simple divider
Divider()

// Customized divider
Divider(
  height: 1,
  thickness: 1,
  indent: 16,
  endIndent: 16,
  color: Colors.grey[300],
)

// In ListView.separated
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => Divider(),
  itemBuilder: (context, index) => ListTile(/* ... */),
)
```

### Why Used
- **Visual Clarity**: Separates content
- **Clean Design**: Subtle separation
- **Standard Pattern**: Familiar to users
- **Easy to Use**: One-line widget

### Examples in Project
- `lib/screens/profile/profile_screen.dart` - Between options
- `lib/screens/support/help_support_screen.dart` - Section separation
- Menu screens
- Settings screens

---

## Performance Optimizations

### 1. ListView.builder vs ListView
```dart
// ❌ Bad - Creates all widgets at once
ListView(
  children: products.map((p) => ProductCard(p)).toList(),
)

// ✅ Good - Lazy loading
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) => ProductCard(products[index]),
)
```

### 2. shrinkWrap Usage
```dart
// ❌ Bad - Inside another scroll view with shrinkWrap: true
SingleChildScrollView(
  child: Column(
    children: [
      ListView.builder(
        shrinkWrap: true, // Performance issue
        physics: NeverScrollableScrollPhysics(),
        // ...
      ),
    ],
  ),
)

// ✅ Good - Use SliverList instead
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => /* item */,
        childCount: items.length,
      ),
    ),
  ],
)
```

### 3. Const Constructors
```dart
// ✅ Good - Reuses widgets
ListView.separated(
  separatorBuilder: (context, index) => const Divider(),
  // ...
)
```

---

## Summary

### List Widget Hierarchy in TurfMate
```
Scrollable Widgets:
├── ListView
│   ├── ListView (static children)
│   ├── ListView.builder (dynamic, lazy)
│   └── ListView.separated (with dividers)
├── GridView
│   ├── GridView.builder (dynamic products)
│   └── GridView.count (fixed count)
├── SingleChildScrollView (any widget scrollable)
└── CustomScrollView (advanced, slivers)
```

### Most Used List Widgets
1. **ListView.builder** - 25+ instances (dynamic lists)
2. **GridView.builder** - 10+ instances (product grids)
3. **Card** - 50+ instances (list items)
4. **ListTile** - 30+ instances (menu items)
5. **SingleChildScrollView** - 30+ instances (forms, details)

### Common Patterns

#### Product Grid Pattern
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.7,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

#### Order List Pattern
```dart
ListView.builder(
  itemCount: orders.length,
  itemBuilder: (context, index) {
    return Card(
      child: ListTile(
        title: Text(orders[index].id),
        subtitle: Text(orders[index].status),
        onTap: () => navigateToDetail(orders[index]),
      ),
    );
  },
)
```

#### Refreshable List Pattern
```dart
RefreshIndicator(
  onRefresh: () async {
    await controller.loadData();
  },
  child: ListView.builder(/* ... */),
)
```

### Best Practices Applied
- ✅ Use `.builder` for lists > 10 items
- ✅ Avoid `shrinkWrap: true` when possible
- ✅ Use `const` for static separators
- ✅ Add `RefreshIndicator` for user control
- ✅ Proper `physics` for nested scrolling
- ✅ Responsive grid columns
- ✅ Consistent card styling
- ✅ Efficient item builders

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
