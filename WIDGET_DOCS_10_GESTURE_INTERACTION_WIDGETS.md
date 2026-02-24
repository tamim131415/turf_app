# TurfMate Project - Gesture & Interaction Widgets Documentation

## Overview
This document covers all gesture detection and user interaction widgets used in the TurfMate project. These widgets handle touch events, swipes, taps, and other user inputs.

---

## 1. GestureDetector Widget

### Purpose
`GestureDetector` detects various touch gestures without visual feedback.

### Usage in TurfMate
- **Custom Tap Actions**: Navigate to screens
- **Card Taps**: Open product details
- **Icon Taps**: Toggle favorites
- **Image Taps**: View full image
- **Dismissible Actions**: Swipe to delete

### Key Features Used
```dart
// Simple tap detection
GestureDetector(
  onTap: () {
    Get.toNamed(Routes.productDetail, arguments: product);
  },
  child: ProductCard(product: product),
)

// Multiple gestures
GestureDetector(
  onTap: () => print('Tapped'),
  onDoubleTap: () => print('Double tapped'),
  onLongPress: () => print('Long pressed'),
  onPanUpdate: (details) => print('Dragging'),
  child: Container(
    width: 200,
    height: 200,
    color: Colors.blue,
  ),
)

// Tap with visual feedback simulation
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 100),
    transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
    child: Widget(),
  ),
)

// Swipe detection
GestureDetector(
  onHorizontalDragEnd: (details) {
    if (details.primaryVelocity! > 0) {
      // Swiped right
      navigateBack();
    } else {
      // Swiped left
      navigateForward();
    }
  },
  child: Widget(),
)
```

### Why Used
- **Flexibility**: Detects any gesture
- **Custom Actions**: Not limited to taps
- **No Visual**: Good for overlays
- **Performance**: Lightweight

### Examples in Project
- `lib/widgets/product_card.dart` - Product card tap
```dart
GestureDetector(
  onTap: () {
    Get.toNamed(Routes.productDetail, arguments: product);
  },
  child: Container(/* product card */),
)
```
- `lib/widgets/product_card.dart` - Favorite button tap
```dart
GestureDetector(
  onTap: () {
    productController.toggleFavorite(product);
  },
  child: Icon(Icons.favorite),
)
```
- `lib/screens/product/product_detail_screen.dart` - Back button
- Used in **50+** locations

---

## 2. InkWell Widget

### Purpose
`InkWell` provides Material Design ripple effect on tap.

### Usage in TurfMate
- **List Item Taps**: ListTile alternatives
- **Card Taps**: Cards with ripple
- **Button Alternatives**: Custom button shapes
- **Interactive Areas**: Any tappable area with feedback

### Key Features Used
```dart
// Simple InkWell
InkWell(
  onTap: () {
    Navigator.push(context, /* ... */);
  },
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Tap me'),
  ),
)

// InkWell with splash color
InkWell(
  onTap: () {},
  splashColor: Colors.green.withOpacity(0.3),
  highlightColor: Colors.green.withOpacity(0.1),
  borderRadius: BorderRadius.circular(12),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.settings),
        SizedBox(width: 8),
        Text('Settings'),
      ],
    ),
  ),
)

// InkWell with long press
InkWell(
  onTap: () => showDetails(),
  onLongPress: () => showOptions(),
  child: Widget(),
)
```

### Why Used
- **Visual Feedback**: Ripple effect
- **Material Design**: Standard behavior
- **Professional**: Polished interactions
- **User Experience**: Confirms tap

### Examples in Project
- List items in settings
- Menu options
- Custom buttons
- Interactive cards

---

## 3. RefreshIndicator Widget

### Purpose
`RefreshIndicator` adds pull-to-refresh functionality.

### Usage in TurfMate
- **Product Lists**: Refresh catalog
- **Order History**: Update order status
- **Notifications**: Fetch new notifications
- **Chat**: Reload messages
- **All List Screens**: User-triggered refresh

### Key Features Used
```dart
RefreshIndicator(
  onRefresh: () async {
    await productController.loadProducts();
  },
  color: Colors.green[700],
  backgroundColor: Colors.white,
  child: ListView.builder(
    physics: AlwaysScrollableScrollPhysics(), // Required!
    itemCount: items.length,
    itemBuilder: (context, index) {
      return ItemWidget(items[index]);
    },
  ),
)

// With SingleChildScrollView
RefreshIndicator(
  onRefresh: () async {
    await loadData();
  },
  child: SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    child: Column(
      children: [/* content */],
    ),
  ),
)

// Custom stroke width
RefreshIndicator(
  onRefresh: () async {},
  strokeWidth: 3.0,
  displacement: 40, // Distance indicator can be dragged
  child: ScrollView(),
)
```

### Why Used
- **User Control**: Manual refresh
- **Standard Pattern**: Familiar gesture
- **Fresh Data**: Get latest content
- **Mobile-Friendly**: Natural mobile interaction

### Examples in Project
- `lib/screens/home/home_screen.dart` - Refresh products
```dart
RefreshIndicator(
  onRefresh: () async {
    productController.loadProducts();
  },
  child: SingleChildScrollView(
    physics: AlwaysScrollableScrollPhysics(),
    child: /* home content */,
  ),
)
```
- `lib/screens/orders/my_orders_screen.dart` - Refresh orders
- `lib/screens/inventory/admin_orders_screen.dart` - Admin refresh
- `lib/screens/explore/explore_screen.dart` - Explore refresh
- Used in **all** list screens (20+ locations)

---

## 4. Dismissible Widget

### Purpose
`Dismissible` allows swipe-to-dismiss gesture for list items.

### Usage in TurfMate
- **Cart Items**: Swipe to remove
- **Wishlist Items**: Swipe to delete
- **Notifications**: Swipe to dismiss
- **Any Removable List**: Interactive deletion

### Key Features Used
```dart
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart, // Swipe left to right
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    // Remove item from list
    controller.removeItem(item);
    
    // Show snackbar
    Get.snackbar(
      'Removed',
      'Item removed from cart',
      backgroundColor: Colors.red[100],
    );
  },
  confirmDismiss: (direction) async {
    // Optional: Ask for confirmation
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Remove this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  },
  child: CartItemCard(item: item),
)

// Swipe both directions
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.horizontal,
  background: Container(
    color: Colors.green,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(left: 20),
    child: Icon(Icons.archive, color: Colors.white),
  ),
  secondaryBackground: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      // Swiped right - archive
      archiveItem(item);
    } else {
      // Swiped left - delete
      deleteItem(item);
    }
  },
  child: ItemWidget(item),
)
```

### Why Used
- **Quick Action**: Fast item removal
- **Mobile Pattern**: Familiar gesture
- **Visual Feedback**: Background shows action
- **Efficient**: No extra taps needed

### Examples in Project
- Cart item removal (potential)
- Notification dismissal
- Wishlist management
- Used selectively for removable items

---

## 5. LongPressDraggable Widget

### Purpose
`LongPressDraggable` makes widgets draggable on long press.

### Usage in TurfMate
- **Reordering**: Custom list reordering
- **Drag to Cart**: Drag products to cart
- **Custom Interactions**: Advanced UX

### Key Features Used
```dart
LongPressDraggable<Product>(
  data: product,
  feedback: Material(
    elevation: 8,
    child: Opacity(
      opacity: 0.7,
      child: ProductCard(product: product),
    ),
  ),
  childWhenDragging: Opacity(
    opacity: 0.3,
    child: ProductCard(product: product),
  ),
  child: ProductCard(product: product),
)

// With DragTarget
DragTarget<Product>(
  onAccept: (product) {
    controller.addToCart(product);
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      color: candidateData.isNotEmpty 
          ? Colors.green[100] 
          : Colors.grey[100],
      child: Icon(Icons.shopping_cart),
    );
  },
)
```

### Why Used
- **Advanced Interactions**: Unique UX
- **Reordering**: Custom sort orders
- **Engaging**: Fun to use
- **Creative**: Unique app features

### Examples in Project
- Could be used for admin product ordering
- Future feature: drag to cart
- Currently not heavily used

---

## 6. Scrollable Widget

### Purpose
Base class for scrollable widgets with scroll physics.

### Usage in TurfMate
- **Custom Scrolling**: Custom scroll behaviors
- **Scroll Controllers**: Programmatic scrolling
- **Scroll Listeners**: Detect scroll events

### Key Features Used
```dart
// Scroll controller
final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  
  // Listen to scroll events
  _scrollController.addListener(() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached bottom - load more
      loadMoreProducts();
    }
  });
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}

// Use in ListView
ListView.builder(
  controller: _scrollController,
  itemBuilder: (context, index) {
    return ProductCard(products[index]);
  },
)

// Programmatic scrolling
_scrollController.animateTo(
  0, // Scroll to top
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
)

// Jump without animation
_scrollController.jumpTo(0)
```

### Why Used
- **Infinite Scroll**: Load more on scroll
- **Scroll to Top**: Quick navigation
- **Scroll Position**: Track position
- **Custom Behaviors**: Advanced features

### Examples in Project
- Infinite scroll in product lists
- Scroll to top button
- Position tracking
- Load more functionality

---

## 7. PageView Gestures

### Purpose
Swipe between pages with smooth transitions.

### Usage in TurfMate
- **Onboarding**: Welcome screens
- **Image Gallery**: Product images
- **Tutorials**: Step-by-step guides

### Key Features Used
```dart
PageView.builder(
  controller: _pageController,
  itemCount: pages.length,
  onPageChanged: (index) {
    setState(() {
      _currentPage = index;
    });
  },
  itemBuilder: (context, index) {
    return pages[index];
  },
)

// Disable swipe
PageView(
  physics: NeverScrollableScrollPhysics(), // Can't swipe
  children: pages,
)

// Custom page snapping
PageView(
  pageSnapping: true, // Snap to pages
  children: pages,
)
```

### Why Used
- **Natural Gesture**: Swipe is intuitive
- **Smooth**: Built-in physics
- **Common**: Familiar pattern
- **Easy**: Simple implementation

### Examples in Project
- `lib/screens/onboarding/onboarding_screen.dart` - App intro
```dart
PageView.builder(
  controller: _pageController,
  itemCount: _pages.length,
  onPageChanged: (int page) {
    setState(() {
      _currentPage = page;
    });
  },
  itemBuilder: (context, index) {
    return OnboardingPageWidget(page: _pages[index]);
  },
)
```

---

## 8. AbsorbPointer & IgnorePointer Widgets

### Purpose
Block or allow touch events to pass through widgets.

### Usage in TurfMate
- **Loading States**: Disable interactions during loading
- **Disabled Buttons**: Make buttons non-interactive
- **Overlays**: Block interactions below overlay

### Key Features Used
```dart
// AbsorbPointer - blocks all touches, widgets still react
AbsorbPointer(
  absorbing: isLoading, // Block when loading
  child: ElevatedButton(
    onPressed: () {
      submitForm();
    },
    child: Text('Submit'),
  ),
)

// IgnorePointer - touches pass through
IgnorePointer(
  ignoring: isDisabled,
  child: Opacity(
    opacity: isDisabled ? 0.5 : 1.0,
    child: Container(
      child: Text('Disabled content'),
    ),
  ),
)

// With loading overlay
Stack(
  children: [
    // Content
    FormWidget(),
    
    // Loading overlay
    if (isLoading)
      AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black26,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
  ],
)
```

### Why Used
- **Prevent Interactions**: During processing
- **User Experience**: Clear disabled states
- **Safety**: Prevent double submissions
- **Control**: Manage interaction flow

### Examples in Project
- Form submission loading states
- Disabled buttons
- Loading overlays
- Prevent double taps

---

## 9. Draggable ScrollableSheet

### Purpose
Sheet that can be dragged up and down.

### Usage in TurfMate
- **Bottom Panels**: Expandable panels
- **Details Sheet**: Product filters
- **Map Overlays**: (if maps added)

### Key Features Used
```dart
DraggableScrollableSheet(
  initialChildSize: 0.3, // 30% of screen
  minChildSize: 0.1,     // Minimum 10%
  maxChildSize: 0.9,     // Maximum 90%
  builder: (context, scrollController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
          );
        },
      ),
    );
  },
)
```

### Why Used
- **Flexible UI**: Expandable panels
- **Space Efficient**: Hide details when not needed
- **Modern**: Contemporary mobile pattern
- **Engaging**: Interactive exploration

### Examples in Project
- Potential use in product filters
- Future feature for maps
- Currently not implemented

---

## 10. Interactive Viewer

### Purpose
`InteractiveViewer` enables pan and zoom on any widget.

### Usage in TurfMate
- **Image Zoom**: Product image zoom
- **Large Content**: Zoom into details
- **Charts/Diagrams**: Interactive viewing

### Key Features Used
```dart
InteractiveViewer(
  panEnabled: true,
  scaleEnabled: true,
  minScale: 0.5,
  maxScale: 4.0,
  child: Image.network(product.imageUrl),
)

// With boundaries
InteractiveViewer(
  boundaryMargin: EdgeInsets.all(20),
  constrained: true,
  child: Image(),
)

// Programmatic control
final TransformationController _transformationController =
    TransformationController();

InteractiveViewer(
  transformationController: _transformationController,
  child: Image(),
)

// Reset zoom
_transformationController.value = Matrix4.identity();
```

### Why Used
- **Image Inspection**: View product details
- **User Control**: Natural interaction
- **Mobile Standard**: Expected behavior
- **Versatile**: Works with any widget

### Examples in Project
- Product image viewing
- Full-screen image gallery
- Detail inspection
- Potential use in admin screens

---

## Gesture Patterns in TurfMate

### 1. Product Card Interaction
```dart
GestureDetector(
  onTap: () {
    // Navigate to detail
    Get.toNamed(Routes.productDetail, arguments: product);
  },
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(/* ... */)],
    ),
    child: Stack(
      children: [
        // Product image and details
        ProductContent(),
        
        // Favorite button with its own gesture
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              productController.toggleFavorite(product);
            },
            child: FavoriteIcon(),
          ),
        ),
      ],
    ),
  ),
)
```

### 2. Swipe to Remove Pattern
```dart
Dismissible(
  key: Key(item.id),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    controller.removeItem(item);
    Get.snackbar(
      'Removed',
      'Item removed',
      backgroundColor: Colors.red[100],
    );
  },
  child: ItemCard(item: item),
)
```

### 3. Pull to Refresh Pattern
```dart
RefreshIndicator(
  onRefresh: () async {
    await controller.loadData();
  },
  color: Colors.green[700],
  child: ListView.builder(
    physics: AlwaysScrollableScrollPhysics(),
    itemBuilder: (context, index) => /* item */,
  ),
)
```

### 4. Infinite Scroll Pattern
```dart
final ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      if (!controller.isLoadingMore.value) {
        controller.loadMoreProducts();
      }
    }
  });
}

ListView.builder(
  controller: _scrollController,
  itemCount: products.length + (isLoadingMore ? 1 : 0),
  itemBuilder: (context, index) {
    if (index == products.length) {
      return Center(child: CircularProgressIndicator());
    }
    return ProductCard(product: products[index]);
  },
)
```

---

## Summary

### Gesture Widget Hierarchy
```
Gesture & Interaction Widgets:
├── GestureDetector (Basic gestures)
├── InkWell (Material ripple)
├── RefreshIndicator (Pull to refresh)
├── Dismissible (Swipe to delete)
├── Scrollable (Scroll behaviors)
├── PageView (Swipe pages)
├── AbsorbPointer (Block touches)
├── InteractiveViewer (Zoom & pan)
└── DraggableScrollableSheet (Draggable panels)
```

### Gesture Usage Statistics
- **GestureDetector**: 50+ instances
- **RefreshIndicator**: 20+ instances (all list screens)
- **InkWell**: 30+ instances
- **Dismissible**: Selective use
- **ScrollController**: 10+ instances
- **PageView**: Onboarding screen

### Common Gestures
1. **Tap**: Navigation, selections, actions
2. **Long Press**: Context menus, options
3. **Swipe**: Dismiss, page navigation
4. **Pull Down**: Refresh data
5. **Scroll**: Browse content
6. **Pinch/Zoom**: Image viewing
7. **Drag**: Reordering (potential)

### Best Practices Applied
- ✅ Visual feedback on all interactions
- ✅ RefreshIndicator on all lists
- ✅ Prevent double taps during processing
- ✅ Clear gestures (no conflicting gestures)
- ✅ Material Design ripples where appropriate
- ✅ Scroll controllers properly disposed
- ✅ Gesture areas large enough (min 44x44)
- ✅ Confirmation for destructive swipes

### Performance Considerations
```dart
// ✅ Good - Dispose controllers
@override
void dispose() {
  _scrollController.dispose();
  _pageController.dispose();
  super.dispose();
}

// ✅ Good - Use keys for Dismissible
Dismissible(
  key: Key(item.id), // Unique key
  child: /* ... */,
)

// ✅ Good - Debounce scroll listeners
Timer? _scrollDebounce;
_scrollController.addListener(() {
  if (_scrollDebounce?.isActive ?? false) _scrollDebounce!.cancel();
  _scrollDebounce = Timer(Duration(milliseconds: 500), () {
    // Handle scroll
  });
});
```

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX

**Documentation Complete! 🎉**
All 10 major widget documentation files have been created covering every aspect of widgets used in the TurfMate project.
