# TurfMate Project - State Management Widgets Documentation

## Overview
This document covers state management approaches and widgets used in the TurfMate project. The app primarily uses GetX for state management, combined with Flutter's built-in StatefulWidget.

---

## 1. StatefulWidget

### Purpose
`StatefulWidget` creates widgets that maintain mutable state that can change over time.

### Usage in TurfMate
- **Form Screens**: Managing form inputs and validation
- **Local UI State**: Tab selection, expansion states
- **Animation Controllers**: Animation state management
- **Local Interactions**: Checkbox states, text input

### Key Features Used
```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // State variables
  int _counter = 0;
  bool _isExpanded = false;
  String _selectedOption = 'Option 1';

  @override
  void initState() {
    super.initState();
    // Initialize state, controllers, listeners
  }

  @override
  void dispose() {
    // Clean up controllers, subscriptions
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // UI that uses/updates state
      child: Text('Counter: $_counter'),
    );
  }
}
```

### Why Used
- **Local State**: Perfect for widget-specific state
- **Built-in**: No external dependencies
- **Lifecycle Methods**: initState, dispose for setup/cleanup
- **State Isolation**: Each widget has its own state

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Form state
```dart
class LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  // ...
}
```
- `lib/screens/onboarding/onboarding_screen.dart` - Page state
```dart
class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // ...
}
```
- `lib/screens/inventory/inventory_screen.dart` - Tab controller
- `lib/screens/home/home_screen.dart` - Search state
- Used in **30+** screens

---

## 2. StatelessWidget

### Purpose
`StatelessWidget` creates immutable widgets that don't maintain state.

### Usage in TurfMate
- **Static Content**: Display-only screens
- **Reusable Components**: Cards, list items
- **Presentation Widgets**: Pure UI components
- **GetX-powered Screens**: State managed by controllers

### Key Features Used
```dart
class MyStatelessWidget extends StatelessWidget {
  final String title;
  final int count;

  const MyStatelessWidget({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Text('$title: $count');
  }
}
```

### Why Used
- **Performance**: More efficient than StatefulWidget
- **Simplicity**: Easier to understand and test
- **Immutability**: Predictable behavior
- **GetX Compatible**: State managed externally

### Examples in Project
- `lib/widgets/product_card.dart` - Stateless with GetX
```dart
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  
  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    // Uses GetX for state management
  }
}
```
- `lib/widgets/cart_item.dart` - Cart item display
- `lib/screens/wishlist/wishlist_screen.dart` - Wishlist with Obx
- Used in **most** widgets (60%+ of widgets)

---

## 3. GetX Controllers

### Purpose
GetX Controllers manage business logic and reactive state outside of widgets.

### Usage in TurfMate
- **Global State**: App-wide state (auth, cart, products)
- **Business Logic**: Data fetching, processing
- **Reactive Variables**: Auto-updating UI
- **Dependency Injection**: Service management

### Key Features Used
```dart
class ProductController extends GetxController {
  // Reactive state variables
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // Services
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Business logic methods
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final fetchedProducts = await _firestoreService.getProducts();
      products.value = fetchedProducts;
    } catch (e) {
      error.value = 'Failed to load products';
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(Product product) {
    // Cart logic
  }
}
```

### Why Used
- **Separation of Concerns**: Logic separate from UI
- **Testability**: Easy to unit test
- **Reusability**: Multiple widgets use same controller
- **Reactive**: Auto-updates UI when state changes

### Examples in Project
- `lib/controllers/auth_controller.dart` - Authentication state
```dart
class AuthController extends GetxController {
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;
  // Auth methods
}
```
- `lib/controllers/product_controller.dart` - Product and cart management
- `lib/controllers/order_controller.dart` - Order management
- `lib/controllers/chat_controller.dart` - Chat state
- **Primary state management** in the app

---

## 4. Obx Widget (GetX)

### Purpose
`Obx` creates reactive widgets that automatically rebuild when observable variables change.

### Usage in TurfMate
- **Reactive UI**: Auto-update on state changes
- **Loading States**: Show/hide loading indicators
- **Cart Updates**: Real-time cart count
- **List Updates**: Dynamic list rendering

### Key Features Used
```dart
// Simple Obx
Obx(() => Text('Count: ${controller.count.value}'))

// Complex Obx with conditionals
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  
  if (controller.products.isEmpty) {
    return Text('No products found');
  }
  
  return ListView.builder(
    itemCount: controller.products.length,
    itemBuilder: (context, index) {
      return ProductCard(product: controller.products[index]);
    },
  );
})

// Obx with multiple observables
Obx(() => Text(
  '${controller.cartItems.length} items - \$${controller.totalPrice.value}',
))
```

### Why Used
- **Automatic Updates**: No manual setState needed
- **Clean Code**: Less boilerplate
- **Performance**: Only rebuilds necessary widgets
- **Simple Syntax**: Easy to understand

### Examples in Project
- `lib/screens/home/home_screen.dart` - Product list
```dart
Obx(() {
  if (productController.isLoading.value) {
    return Center(child: CircularProgressIndicator());
  }
  return GridView.builder(/* products */);
})
```
- `lib/screens/cart/cart_screen.dart` - Cart items and total
```dart
Obx(() {
  if (controller.cartItems.isEmpty) {
    return EmptyCartWidget();
  }
  return ListView.builder(/* cart items */);
})
```
- `lib/widgets/product_card.dart` - Favorite state
- Used in **100+** locations

---

## 5. GetBuilder Widget (GetX)

### Purpose
`GetBuilder` updates UI manually when update() is called in controller.

### Usage in TurfMate
- **Non-reactive Updates**: When Obx is overkill
- **Complex State**: Multiple related updates
- **Performance**: Controlled rebuild timing

### Key Features Used
```dart
// In Controller
class MyController extends GetxController {
  int counter = 0;
  
  void increment() {
    counter++;
    update(); // Triggers GetBuilder rebuild
  }
  
  void incrementSpecific() {
    counter++;
    update(['counter_display']); // Only rebuild specific ID
  }
}

// In Widget
GetBuilder<MyController>(
  init: MyController(),
  builder: (controller) {
    return Text('Count: ${controller.counter}');
  },
)

// With ID for targeted updates
GetBuilder<MyController>(
  id: 'counter_display',
  builder: (controller) {
    return Text('${controller.counter}');
  },
)
```

### Why Used
- **Manual Control**: Update when YOU want
- **Performance**: Less reactive overhead
- **Grouped Updates**: Multiple state changes, one rebuild
- **Legacy Compatibility**: Works with non-observable variables

### Examples in Project
- Used selectively when Obx is not suitable
- Complex state updates
- Performance-critical sections

---

## 6. Rx Variables (GetX Observables)

### Purpose
Reactive variables that automatically notify listeners when changed.

### Usage in TurfMate
- **Simple Values**: RxInt, RxString, RxBool
- **Lists**: RxList for dynamic arrays
- **Objects**: Rx<Model> for custom classes
- **Maps**: RxMap for key-value pairs

### Key Features Used
```dart
// In Controller
class MyController extends GetxController {
  // Simple reactive variables
  final RxInt count = 0.obs;
  final RxString userName = ''.obs;
  final RxBool isLoggedIn = false.obs;
  
  // Lists
  final RxList<Product> products = <Product>[].obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  
  // Custom objects
  final Rx<User?> currentUser = Rx<User?>(null);
  
  // Computed properties
  double get totalPrice => cartItems.fold(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );
  
  // Methods
  void addToCart(Product product) {
    cartItems.add(CartItem.fromProduct(product));
    // Automatically notifies Obx widgets
  }
}

// In Widget - Using .value
Text('Count: ${controller.count.value}')

// Without .value inside Obx
Obx(() => Text('Count: ${controller.count}'))
```

### Why Used
- **Reactive**: Auto-update UI
- **Type-safe**: Specific types (RxInt, RxString)
- **List Support**: Dynamic collections
- **Simple Syntax**: .obs extension

### Examples in Project
- `lib/controllers/product_controller.dart`
```dart
final RxList<Product> products = <Product>[].obs;
final RxList<CartItem> cartItems = <CartItem>[].obs;
final RxBool isLoading = false.obs;
```
- `lib/controllers/auth_controller.dart`
```dart
final Rx<User?> user = Rx<User?>(null);
final RxBool isLoggedIn = false.obs;
```
- Used in **all** GetX controllers

---

## 7. Get.put() & Get.find() (Dependency Injection)

### Purpose
GetX dependency injection for managing controller lifecycle and access.

### Usage in TurfMate
- **Global Controllers**: Auth, Product, Order controllers
- **Service Access**: Firestore, Storage, Auth services
- **Singleton Pattern**: One instance across app
- **Lazy Loading**: Create only when needed

### Key Features Used
```dart
// Register controller (in main.dart or init)
Get.put(AuthController());
Get.put(ProductController());
Get.lazyPut(() => OrderController()); // Creates when first used

// Access controller anywhere
final authController = Get.find<AuthController>();

// Use in widgets
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    
    return Obx(() => Text('${controller.products.length}'));
  }
}

// Conditional access
if (Get.isRegistered<OrderController>()) {
  final controller = Get.find<OrderController>();
}
```

### Why Used
- **No BuildContext**: Access controllers anywhere
- **Lifecycle Management**: Auto disposal
- **Singleton**: One instance per type
- **Clean Code**: No prop drilling

### Examples in Project
- `lib/main.dart` - Initial registration
```dart
void main() {
  // Register services
  Get.put(LocalStorageService());
  Get.put(FirestoreService());
  Get.put(AuthService());
  
  // Register controllers
  Get.put(AuthController());
  Get.put(ProductController());
  
  runApp(TurfMateApp());
}
```
- Used in **every** screen to access controllers

---

## 8. Worker (GetX Reactions)

### Purpose
React to changes in observable variables with side effects.

### Usage in TurfMate
- **Listeners**: Watch for state changes
- **Side Effects**: Navigation, logging, analytics
- **Debouncing**: Search input delays
- **Sync**: Keep related states in sync

### Key Features Used
```dart
class MyController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    
    // ever - Called every time variable changes
    ever(products, (_) {
      print('Products updated');
      filterProducts();
    });
    
    // once - Called only first time
    once(user, (_) {
      print('User logged in');
    });
    
    // debounce - Called after delay when changes stop
    _searchWorker = debounce(
      searchQuery,
      (_) => performSearch(),
      time: Duration(milliseconds: 500),
    );
    
    // interval - Called periodically while changing
    interval(
      connectionStatus,
      (_) => checkConnection(),
      time: Duration(seconds: 1),
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }
}
```

### Why Used
- **Reactive Side Effects**: Execute code on changes
- **Debouncing**: Optimize search performance
- **Auto Filtering**: Keep derived state synced
- **Event Handling**: Respond to state changes

### Examples in Project
- `lib/screens/home/home_screen.dart` - Search debouncing
```dart
_productsWorker = ever(productController.products, (_) {
  _filterProducts();
});
```
- Used for search functionality
- Product filtering
- State synchronization

---

## 9. setState() Method

### Purpose
Manually trigger widget rebuild in StatefulWidget.

### Usage in TurfMate
- **Local State Updates**: Simple UI changes
- **Form Updates**: Checkbox, switch changes
- **Tab Selection**: Current tab index
- **Expansion States**: Collapsible sections

### Key Features Used
```dart
class _MyWidgetState extends State<MyWidget> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _toggleExpansion,
          child: Text('Toggle'),
        ),
        if (_isExpanded)
          Text('Expanded content'),
      ],
    );
  }
}
```

### Why Used
- **Simple State**: For widget-local state
- **Built-in**: No dependencies
- **Explicit**: Clear when updates happen
- **Traditional**: Standard Flutter approach

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Password visibility
```dart
setState(() {
  _obscureText = !_obscureText;
});
```
- `lib/screens/onboarding/onboarding_screen.dart` - Page changes
```dart
setState(() {
  _currentPage = page;
});
```
- Used in all StatefulWidgets

---

## 10. FutureBuilder & StreamBuilder

### Purpose
Build widgets based on asynchronous data streams.

### Usage in TurfMate
- **Async Data**: Loading from Firebase
- **Real-time Updates**: Firestore streams
- **Network Calls**: API responses
- **File Operations**: Reading files

### Key Features Used
```dart
// FutureBuilder - One-time async operation
FutureBuilder<List<Product>>(
  future: firestoreService.getProducts(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No products found');
    }
    
    final products = snapshot.data!;
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  },
)

// StreamBuilder - Continuous updates
StreamBuilder<List<Order>>(
  stream: firestoreService.getOrdersStream(userId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (!snapshot.hasData) {
      return Text('No orders');
    }
    
    final orders = snapshot.data!;
    return ListView(
      children: orders.map((order) => OrderCard(order)).toList(),
    );
  },
)
```

### Why Used
- **Async Handling**: Clean async UI code
- **Built-in Loading**: Automatic state management
- **Real-time**: StreamBuilder for live updates
- **Error Handling**: Built-in error states

### Examples in Project
- Firebase real-time data
- Used sparingly (GetX controllers preferred)
- Legacy code sections

---

## State Management Architecture

### TurfMate State Flow
```
User Action
    ↓
Widget (Obx/GetBuilder)
    ↓
Controller Method
    ↓
Business Logic + API Calls
    ↓
Update Rx Variables
    ↓
Auto Rebuild Obx Widgets
    ↓
Updated UI
```

### Controller Organization
```
lib/controllers/
├── auth_controller.dart          (Authentication state)
├── product_controller.dart       (Products + Cart)
├── order_controller.dart         (Order management)
├── chat_controller.dart          (Chatbot state)
├── address_controller.dart       (User addresses)
├── payment_method_controller.dart (Payment methods)
└── product_detail_controller.dart (Product detail state)
```

### State Scope
```
Global State (GetX Controllers):
- Authentication (user, logged in status)
- Products (catalog, filters)
- Cart (items, total)
- Orders (history, current)

Local State (StatefulWidget):
- Form inputs
- Page controllers
- Tab selection
- UI toggles (expand/collapse)
- Animation controllers
```

### Best Practices Applied
- ✅ GetX for global state
- ✅ StatefulWidget for local UI state
- ✅ Controllers for business logic
- ✅ Obx for reactive UI
- ✅ Proper controller disposal
- ✅ Separation of concerns
- ✅ Minimal setState usage
- ✅ Reactive variables with .obs

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
