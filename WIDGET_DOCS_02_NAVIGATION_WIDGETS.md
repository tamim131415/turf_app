# TurfMate Project - Navigation Widgets Documentation

## Overview
This document covers all navigation-related widgets used in the TurfMate project. These widgets handle routing, screen structure, and user navigation throughout the app.

---

## 1. Scaffold Widget

### Purpose
`Scaffold` provides the basic material design visual layout structure for screens.

### Usage in TurfMate
- **Main Structure**: Base widget for all major screens
- **AppBar Integration**: Hosts the top app bar
- **Body Content**: Contains main screen content
- **Bottom Navigation**: Supports bottom navigation bar
- **Floating Actions**: Provides floating action button support

### Key Features Used
```dart
Scaffold(
  appBar: AppBar(
    title: Text('Screen Title'),
    backgroundColor: Colors.green[700],
    actions: [/* action buttons */],
  ),
  body: /* main content */,
  bottomNavigationBar: /* bottom nav */,
  floatingActionButton: /* FAB */,
  backgroundColor: Colors.grey[50],
)
```

### Why Used
- Standard Material Design structure
- Handles system UI overlays automatically
- Provides consistent screen structure
- Easy integration with app bars and navigation

### Examples in Project
- `lib/screens/home/home_screen.dart` - Home screen with AppBar
- `lib/screens/cart/cart_screen.dart` - Cart with consistent structure
- `lib/screens/inventory/inventory_screen.dart` - Admin inventory screen
- `lib/screens/auth/login_screen.dart` - Login screen
- Used in **ALL** major screens (40+ instances)

---

## 2. AppBar Widget

### Purpose
`AppBar` displays a material design app bar at the top of the screen.

### Usage in TurfMate
- **Screen Titles**: Displaying current screen name
- **Navigation**: Back buttons and menu icons
- **Actions**: Search, cart, notifications, profile buttons
- **Branding**: App identity and context

### Key Features Used
```dart
AppBar(
  title: Text(
    'TurfMate',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.green[700],
  foregroundColor: Colors.white,
  elevation: 0,
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Get.back(),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.shopping_cart),
      onPressed: () => Get.toNamed(Routes.cart),
    ),
  ],
)
```

### Why Used
- Provides consistent navigation
- Shows screen context to users
- Hosts important action buttons
- Material Design standard

### Examples in Project
- `lib/screens/home/home_screen.dart` - Title with cart icon
- `lib/screens/cart/cart_screen.dart` - Simple title with back button
- `lib/screens/inventory/inventory_screen.dart` - Admin view with actions
- `lib/screens/orders/my_orders_screen.dart` - Orders with back navigation
- Present in **every** screen

---

## 3. BottomNavigationBar Widget

### Purpose
`BottomNavigationBar` provides tab navigation at the bottom of the screen.

### Usage in TurfMate
- **Main Navigation**: Primary app navigation between major sections
- **Tab Switching**: Home, Explore, Wishlist, Profile
- **Visual Feedback**: Shows current selected tab

### Key Features Used
```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Colors.green[700],
  unselectedItemColor: Colors.grey[400],
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: AppStrings.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.explore),
      label: AppStrings.explore,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_border),
      label: AppStrings.wishlist,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: AppStrings.profile,
    ),
  ],
)
```

### Why Used
- Standard mobile app navigation pattern
- Easy access to main features
- Clear visual indication of current screen
- Familiar user experience

### Examples in Project
- `lib/screens/main_navigation_screen.dart` - Main app navigation
- Provides access to 4 main sections
- Includes cart badge overlay

---

## 4. TabBar & TabBarView Widgets

### Purpose
`TabBar` provides tab navigation, while `TabBarView` displays the corresponding content.

### Usage in TurfMate
- **Admin Screens**: Switch between Products and Orders
- **Category Filtering**: Different product categories
- **Content Organization**: Organized multi-view screens

### Key Features Used
```dart
// TabBar
DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
      bottom: TabBar(
        tabs: [
          Tab(
            child: Row(
              children: [
                Icon(Icons.inventory),
                SizedBox(width: 6),
                Text('Products'),
              ],
            ),
          ),
          Tab(
            child: Row(
              children: [
                Icon(Icons.shopping_bag),
                Text('Orders'),
              ],
            ),
          ),
        ],
      ),
    ),
    body: TabBarView(
      children: [
        ProductsInventoryTab(),
        AdminOrdersScreen(),
      ],
    ),
  ),
)
```

### Why Used
- Organize related content
- Swipeable navigation
- Clean interface for multiple views
- Efficient space usage

### Examples in Project
- `lib/screens/inventory/inventory_screen.dart` - Products & Orders tabs
- Admin dashboard with order count badges in tabs
- Clear visual separation of admin functions

---

## 5. Drawer Widget

### Purpose
`Drawer` provides a sliding panel from the side of the screen for navigation.

### Usage in TurfMate
- **Secondary Navigation**: Less frequently used options
- **User Profile**: Quick access to profile settings
- **Menu Options**: App settings and information

### Key Features Used
```dart
Scaffold(
  drawer: Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.green[900]!],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TurfMate'),
              Text('user@email.com'),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () => Get.toNamed(Routes.home),
        ),
        // more items...
      ],
    ),
  ),
)
```

### Why Used
- Space-efficient navigation
- Organized secondary options
- Standard mobile pattern
- Clean main screen

### Examples in Project
- Available through hamburger menu icon
- Contains profile, settings, help links
- Quick access to important features

---

## 6. PopScope Widget (Formerly WillPopScope)

### Purpose
`PopScope` controls back button behavior and navigation pop actions.

### Usage in TurfMate
- **Exit Confirmation**: Confirm before exiting app
- **Unsaved Changes**: Warn about unsaved data
- **Navigation Control**: Custom back button handling

### Key Features Used
```dart
PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) async {
    if (didPop) return;
    
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
  },
  child: Scaffold(/* screen content */),
)
```

### Why Used
- Prevents accidental app exits
- Protects unsaved user data
- Better user experience
- Professional app behavior

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Exit app confirmation
- Prevents data loss on back press
- Custom navigation flows

---

## 7. IconButton Widget (Navigation Context)

### Purpose
`IconButton` creates clickable icon buttons for navigation actions.

### Usage in TurfMate
- **Back Navigation**: Return to previous screen
- **Action Triggers**: Open cart, profile, search
- **Quick Actions**: Favorite, share, delete

### Key Features Used
```dart
IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => Get.back(),
  color: Colors.white,
  tooltip: 'Go Back',
)

// In AppBar
actions: [
  IconButton(
    icon: Stack(
      children: [
        Icon(Icons.shopping_cart),
        if (cartItemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(/* badge */),
          ),
      ],
    ),
    onPressed: () => Get.toNamed(Routes.cart),
  ),
]
```

### Why Used
- Space-efficient navigation
- Clear visual indicators
- Standard mobile pattern
- Easy to understand icons

### Examples in Project
- `lib/screens/home/home_screen.dart` - Cart and notification buttons
- `lib/screens/cart/cart_screen.dart` - Back button
- `lib/screens/product/product_detail_screen.dart` - Back and share
- Used in **every** screen AppBar

---

## 8. GetX Navigation (Get.toNamed, Get.back)

### Purpose
GetX provides simplified navigation management without context.

### Usage in TurfMate
- **Route Navigation**: Navigate between screens
- **Named Routes**: Type-safe navigation
- **Back Navigation**: Return to previous screens
- **Arguments Passing**: Send data between screens

### Key Features Used
```dart
// Navigate to named route
Get.toNamed(Routes.productDetail, arguments: product);

// Navigate and remove previous route
Get.offNamed(Routes.home);

// Navigate and remove all previous routes
Get.offAllNamed(Routes.login);

// Go back
Get.back();

// Go back with result
Get.back(result: selectedValue);
```

### Why Used
- No BuildContext required
- Cleaner code
- Type-safe routes
- Easy argument passing
- Simplified navigation logic

### Examples in Project
- `lib/app/routes/app_routes.dart` - All route definitions
- `lib/app/routes/app_pages.dart` - Route mappings
- Used throughout all navigation actions
- `lib/screens/splash/splash_screen.dart` - Initial navigation
- **Primary navigation method** in entire app

---

## 9. IndexedStack Widget

### Purpose
`IndexedStack` shows only one child from a list, keeping all children in the widget tree.

### Usage in TurfMate
- **Bottom Navigation**: Preserve state when switching tabs
- **Tab Persistence**: Keep scroll positions and data
- **Performance**: Avoid rebuilding screens

### Key Features Used
```dart
Scaffold(
  body: IndexedStack(
    index: _currentIndex,
    children: _screens,
  ),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },
    items: [/* nav items */],
  ),
)
```

### Why Used
- Maintains screen state across tab switches
- Better user experience
- Preserves scroll positions
- Efficient memory usage for frequently accessed screens

### Examples in Project
- `lib/screens/main_navigation_screen.dart` - Main navigation
- Keeps Home, Explore, Wishlist, Profile states intact
- User doesn't lose scroll position when switching tabs

---

## 10. PageView Widget

### Purpose
`PageView` creates swipeable pages for onboarding or multi-step flows.

### Usage in TurfMate
- **Onboarding**: Welcome screen with swipeable pages
- **Image Galleries**: Swipe through product images
- **Tutorials**: Step-by-step guides

### Key Features Used
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

### Why Used
- Natural swipe gesture
- Smooth page transitions
- Perfect for onboarding
- Good for image carousels

### Examples in Project
- `lib/screens/onboarding/onboarding_screen.dart` - App introduction
- Three-page welcome experience
- Page indicators showing current position

---

## Summary

### Navigation Architecture
```
TurfMate Navigation Flow:
├── Splash Screen
│   └── Checks authentication
│       ├── Not Logged In → Onboarding → Login/Register
│       └── Logged In → Main Navigation Screen
│           ├── Home (Tab 1)
│           ├── Explore (Tab 2)
│           ├── Wishlist (Tab 3)
│           └── Profile (Tab 4)
```

### Route Structure
```dart
// lib/app/routes/app_routes.dart
class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String inventory = '/inventory';
  static const String chat = '/chat';
  // ... more routes
}
```

### Most Used Navigation Widgets
1. **Scaffold** - 40+ instances (every screen)
2. **AppBar** - 40+ instances (every screen)
3. **IconButton** - 80+ instances (navigation actions)
4. **Get.toNamed()** - 100+ instances (primary navigation)
5. **BottomNavigationBar** - 1 instance (main navigation)

### Navigation Patterns Applied
- **Tab Navigation**: Main 4 sections via BottomNavigationBar
- **Stack Navigation**: Drill-down into details
- **Modal Navigation**: Pop-ups for confirmations
- **Replacement Navigation**: Login/Logout flows

### Best Practices
- Named routes for type safety
- GetX for simplified navigation
- State preservation with IndexedStack
- Proper back button handling
- Clear navigation hierarchy

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
