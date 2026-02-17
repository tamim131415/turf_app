# TurfMate - Project Analysis & Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technical Stack](#technical-stack)
3. [Architecture Analysis](#architecture-analysis)
4. [Feature Breakdown](#feature-breakdown)
5. [Data Models](#data-models)
6. [Workflow Logic](#workflow-logic)
7. [Key Services](#key-services)
8. [Security & Authentication](#security--authentication)
9. [Deployment Configuration](#deployment-configuration)

---

## 1. Project Overview

**TurfMate** is a comprehensive e-commerce mobile application built with Flutter, specializing in sports products and merchandise. The app provides a full-featured marketplace for football/sports equipment, including jerseys, shoes, accessories, balls, and training gear.

### Key Highlights:
- **Platform**: Cross-platform mobile app (Android, iOS, Web, Windows, Linux, macOS)
- **Primary Domain**: E-commerce / Sports Merchandise
- **Target Users**: Sports enthusiasts, football fans, and athletes
- **Admin Features**: Complete inventory management, order tracking, and customer support system
- **Version**: 1.0.0+1

**Note**: Despite the name suggesting sports facility booking, TurfMate is primarily an e-commerce platform for purchasing sports products rather than booking sports facilities or turfs.

---

## 2. Technical Stack

### Core Framework
- **Flutter SDK**: ^3.10.0
- **Dart Language**: Latest version compatible with Flutter 3.10.0
- **State Management**: GetX (^4.6.6)

### Backend & Cloud Services
| Service | Package | Version | Purpose |
|---------|---------|---------|---------|
| **Firebase Core** | firebase_core | ^3.15.2 | Firebase initialization |
| **Firebase Auth** | firebase_auth | ^5.3.3 | User authentication |
| **Cloud Firestore** | cloud_firestore | ^5.6.12 | NoSQL database |
| **Firebase Storage** | firebase_storage | ^12.3.6 | Image/file storage |
| **Firebase Messaging** | firebase_messaging | ^15.1.5 | Push notifications |

### Authentication
- **Google Sign-In**: google_sign_in ^6.2.1
- **OneSignal**: onesignal_flutter ^5.1.0 (Alternative notification service)

### Key Dependencies
| Category | Package | Version | Purpose |
|----------|---------|---------|---------|
| **Storage** | shared_preferences | ^2.2.2 | Local data persistence |
| **HTTP** | http | ^1.2.0 | REST API calls |
| **HTTP** | dio | ^5.4.0 | Advanced HTTP client |
| **Image Handling** | image_picker | ^1.0.7 | Camera/gallery access |
| **Image Processing** | image | ^4.1.7 | Image manipulation |
| **File System** | path_provider | ^2.1.2 | File path access |
| **Permissions** | permission_handler | ^11.3.1 | Runtime permissions |
| **Notifications** | flutter_local_notifications | ^17.0.0 | Local notifications |
| **AI/ML** | google_generative_ai | ^0.4.6 | Gemini AI chatbot |
| **Utilities** | intl | ^0.19.0 | Internationalization |
| **Utilities** | crypto | ^3.0.3 | Encryption/hashing |
| **Utilities** | url_launcher | ^6.2.5 | External URL handling |

### Development Tools
- **Linting**: flutter_lints ^6.0.0
- **Icons**: flutter_launcher_icons ^0.13.1
- **Navigation**: GetX routing system

---

## 3. Architecture Analysis

### Design Pattern
TurfMate follows a **Layered/Service-Based Architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│      (Screens, Widgets, UI Logic)       │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Controller Layer              │
│     (GetX Controllers, State Mgmt)      │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│            Service Layer                │
│  (Business Logic, API, Firebase calls)  │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│             Model Layer                 │
│         (Data Models, Entities)         │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           Data Sources                  │
│   (Firebase, Local Storage, APIs)       │
└─────────────────────────────────────────┘
```

### Folder Structure

```
lib/
├── app/                          # App-wide configuration
│   ├── routes/                   # Navigation routes
│   │   ├── app_routes.dart       # Route constants
│   │   └── app_pages.dart        # GetPage definitions
│   └── theme/                    # App theming
│       └── app_theme.dart        # Theme configuration
│
├── controllers/                  # GetX Controllers (State Management)
│   ├── auth_controller.dart      # Authentication state
│   ├── product_controller.dart   # Product & cart management
│   ├── order_controller.dart     # Order processing
│   ├── address_controller.dart   # Address management
│   ├── payment_method_controller.dart  # Payment methods
│   └── chat_controller.dart      # AI chatbot state
│
├── models/                       # Data Models
│   ├── product.dart              # Product entity
│   ├── cart_item.dart            # Shopping cart item
│   ├── order.dart                # Order entity
│   ├── order_status_history.dart # Order tracking
│   ├── address.dart              # Delivery address
│   ├── payment_method.dart       # Payment info
│   ├── review.dart               # Product reviews
│   ├── support_ticket.dart       # Customer support
│   └── chat_message.dart         # Chat messages
│
├── services/                     # Business Logic & API Services
│   ├── auth_service.dart         # Authentication logic
│   ├── firestore_service.dart    # Firebase database operations
│   ├── local_storage_service.dart # SharedPreferences wrapper
│   ├── fcm_notification_service.dart  # Push notifications
│   ├── image_upload_service.dart # Image handling
│   ├── cloudinary_service.dart   # Cloudinary integration
│   ├── gemini_chat_service.dart  # AI chatbot
│   └── onesignal_service.dart    # OneSignal notifications
│
├── screens/                      # UI Screens (Feature-based)
│   ├── splash/                   # App splash screen
│   ├── onboarding/               # User onboarding
│   ├── auth/                     # Login, Register, Forgot Password
│   ├── home/                     # Main home screen
│   ├── explore/                  # Browse products
│   ├── product/                  # Product details, add/edit
│   ├── cart/                     # Shopping cart, checkout
│   ├── wishlist/                 # Favorite products
│   ├── orders/                   # Order history
│   ├── inventory/                # Admin inventory management
│   ├── address/                  # Address management
│   ├── payment/                  # Payment methods
│   ├── profile/                  # User profile
│   ├── notifications/            # Notification center
│   ├── chat/                     # AI chatbot interface
│   ├── support/                  # Customer support tickets
│   └── main_navigation_screen.dart  # Bottom navigation
│
├── widgets/                      # Reusable UI Components
│   ├── product_card.dart         # Product display card
│   ├── cart_item.dart            # Cart item widget
│   ├── wishlist_item.dart        # Wishlist item widget
│   └── social_login_button.dart  # Social auth button
│
├── utils/                        # Utility Classes
│   └── app_strings.dart          # String constants
│
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # App entry point
```

### Architecture Characteristics

1. **Separation of Concerns**: Clear division between UI, business logic, and data layers
2. **Dependency Injection**: GetX's dependency injection for service management
3. **Reactive State Management**: GetX observables (Rx) for reactive UI updates
4. **Service Layer Pattern**: Encapsulates all business logic and external API calls
5. **Repository Pattern**: FirestoreService acts as a repository for data access
6. **Offline-First Approach**: Local storage fallback for offline functionality

---

## 4. Feature Breakdown

### 4.1 User Authentication & Authorization

#### UI Files:
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/register_screen.dart`
- `lib/screens/auth/forgot_password_screen.dart`
- `lib/screens/auth/email_verification_screen.dart`
- `lib/screens/splash/splash_screen.dart`

#### Controller:
- `lib/controllers/auth_controller.dart`
  - Manages authentication state (`isLoggedIn`, `userName`, `userEmail`)
  - Handles Google Sign-In and Email/Password authentication
  - Monitors Firebase user state changes
  - Manages FCM token registration for logged-in users

#### Service Layer:
- `lib/services/auth_service.dart`
  - **Methods**:
    - `signInWithGoogle()`: Google authentication flow
    - `signInWithEmailPassword()`: Email/password login
    - `registerWithEmailPassword()`: User registration
    - `sendPasswordResetEmail()`: Password recovery
    - `sendEmailVerification()`: Email verification
    - `signOut()`: User logout
    - `_saveUserToFirestore()`: Store user profile in Firestore

#### Backend Integration:
- **Firebase Authentication**: Manages user accounts and sessions
- **Firestore Collection**: `users` - stores user profiles with fields:
  ```
  {
    uid: String,
    email: String,
    displayName: String,
    photoURL: String,
    profileImageUrl: String?,
    coverImageUrl: String?,
    createdAt: Timestamp,
    lastLogin: Timestamp
  }
  ```

#### Authentication Flow:
1. User enters credentials in LoginScreen
2. AuthController validates input
3. AuthService calls Firebase Auth API
4. On success:
   - User document created/updated in Firestore
   - FCM token saved for push notifications
   - User redirected to home screen
5. Email verification required (except for admin user)

#### Special Features:
- **Admin Access**: Hardcoded admin email `admin@turfmate.com` bypasses email verification
- **Google OAuth**: One-tap Google Sign-In integration
- **Session Persistence**: Firebase handles session management
- **Profile Photos**: Support for custom profile and cover images

---

### 4.2 Product Catalog & Browsing

#### UI Files:
- `lib/screens/home/home_screen.dart` - Main product listing
- `lib/screens/explore/explore_screen.dart` - Advanced browsing
- `lib/screens/product/product_detail_screen.dart` - Product details
- `lib/screens/product/all_products_screen.dart` - Full catalog view
- `lib/widgets/product_card.dart` - Product display widget

#### Controller:
- `lib/controllers/product_controller.dart`
  - **Observable State**:
    - `products` - Full product list
    - `favoriteProducts` - User's favorite products
    - `selectedCategory`, `selectedTeam`, `selectedBrand` - Active filters
    - `isOnline` - Firebase connection status
    - `isLoading` - Loading indicator state
  
  - **Key Methods**:
    - `loadProducts()`: Fetch products from Firestore with local fallback
    - `toggleFavorite()`: Add/remove products from wishlist
    - `filterByCategory()`, `filterByTeam()`, `filterByBrand()`: Apply filters
    - `searchProducts()`: Text-based product search

#### Service Layer:
- `lib/services/firestore_service.dart`
  - **Product Operations**:
    - `getProducts()`: Fetch all products
    - `getProductsByCategory()`: Filter by category
    - `getFavoriteProducts()`: Get user's favorites
    - `getProductsStream()`: Real-time product updates
    - `toggleFavorite()`: Update favorite status

- `lib/services/local_storage_service.dart`
  - `saveProducts()`: Cache products locally
  - `getProducts()`: Retrieve cached products
  - `toggleFavorite()`: Update local favorite status

#### Backend:
- **Firestore Collection**: `products`
  ```json
  {
    "id": "product_123",
    "name": "Manchester United Home Jersey",
    "price": 89.99,
    "originalPrice": 119.99,
    "team": "Manchester United",
    "category": "Jerseys",
    "brand": "Adidas",
    "imageUrl": "https://cloudinary.com/...",
    "rating": 4.5,
    "reviewCount": 128,
    "isFavorite": false,
    "sizes": ["S", "M", "L", "XL"],
    "colors": [4294198070, 4278190080],
    "description": "Official 2024 home jersey...",
    "quantity": 45,
    "soldCount": 234,
    "created_at": Timestamp,
    "updated_at": Timestamp
  }
  ```

#### Product Browsing Flow:
1. HomeScreen displays categorized products
2. User can search using search bar (filters by name, team, category)
3. Category chips allow quick filtering
4. ProductCard shows product image, name, price, rating
5. Tap on product → Navigate to ProductDetailScreen
6. Online/Offline indicator shows connection status
7. Products cached locally for offline viewing

#### Features:
- **Real-time Search**: Instant filtering as user types
- **Multi-filter Support**: Filter by category, team, or brand
- **Offline Mode**: Falls back to cached products when Firebase unavailable
- **Favorites/Wishlist**: Quick toggle favorite status
- **Rating Display**: Shows average rating and review count
- **Discount Badges**: Shows original price with strikethrough for discounted items

---

### 4.3 Shopping Cart & Wishlist

#### UI Files:
- `lib/screens/cart/cart_screen.dart` - Shopping cart view
- `lib/screens/wishlist/wishlist_screen.dart` - Favorite products
- `lib/widgets/cart_item.dart` - Cart item widget
- `lib/widgets/wishlist_item.dart` - Wishlist item widget

#### Controller:
- `lib/controllers/product_controller.dart`
  - **Cart State**:
    - `cartItems` - List of items in cart
    - Methods: `addToCart()`, `removeFromCart()`, `updateCartItemQuantity()`, `clearCart()`
  
  - **Wishlist State**:
    - `favoriteProducts` - List of favorited products
    - Methods: `toggleFavorite()`, `updateFavoriteProducts()`

#### Service Layer:
- `lib/services/local_storage_service.dart`
  - `saveCartItems()`: Persist cart to SharedPreferences
  - `getCartItems()`: Load cart from local storage
  - Cart survives app restarts

#### Data Model:
- `lib/models/cart_item.dart`
  ```dart
  class CartItem {
    Product product;      // Full product details
    int quantity;         // Item quantity
    double get totalPrice;  // Computed: price * quantity
  }
  ```

#### Cart Workflow:
1. **Add to Cart**:
   - User clicks "Add to Cart" button on product detail page
   - ProductController checks if product already exists in cart
   - If exists: increment quantity; if new: add with quantity 1
   - Cart saved to SharedPreferences
   - Success snackbar displayed

2. **Update Quantity**:
   - User adjusts quantity using +/- buttons in CartScreen
   - ProductController updates CartItem quantity
   - Total price recalculated automatically
   - Changes saved to local storage

3. **Remove from Cart**:
   - User swipes to delete or taps remove button
   - Item removed from `cartItems` observable list
   - UI updates reactively
   - Local storage synced

4. **Cart Persistence**:
   - Cart items stored as JSON in SharedPreferences
   - Survives app restarts and reinstalls
   - No server-side cart storage (local-only)

#### Wishlist Workflow:
1. User taps heart icon on product card
2. `toggleFavorite()` updates both Firestore and local storage
3. Product's `isFavorite` flag toggled
4. WishlistScreen displays all favorited products
5. Can add favorited products directly to cart

---

### 4.4 Checkout & Order Placement

#### UI Files:
- `lib/screens/cart/checkout_screen.dart` - Order summary & payment
- `lib/screens/cart/order_success_screen.dart` - Order confirmation
- `lib/screens/address/addresses_screen.dart` - Saved addresses
- `lib/screens/address/add_address_screen.dart` - Add/edit address
- `lib/screens/payment/payment_methods_screen.dart` - Payment options
- `lib/screens/payment/add_payment_method_screen.dart` - Add payment method

#### Controllers:
- `lib/controllers/product_controller.dart`
  - `placeOrder()`: Main order placement method
  - Validates cart, address, payment info
  - Creates Order object and saves to Firestore
  - Clears cart on successful order

- `lib/controllers/address_controller.dart`
  - Manages user's saved addresses
  - `defaultAddress` - Primary delivery address
  - `addAddress()`, `updateAddress()`, `deleteAddress()`, `setDefaultAddress()`

- `lib/controllers/payment_method_controller.dart`
  - Manages saved payment methods
  - `defaultPaymentMethod` - Primary payment option
  - Similar CRUD operations for payment methods

#### Service Layer:
- `lib/services/firestore_service.dart`
  - `saveOrder()`: Creates order document in Firestore
  - `getUserOrders()`: Retrieves user's order history
  - `updateOrderStatus()`: Admin order status updates
  - Address & payment method CRUD operations

- `lib/services/fcm_notification_service.dart`
  - `sendOrderNotification()`: Notify user of order status changes
  - `sendOrderNotificationToAdmin()`: Alert admin of new orders

#### Data Models:
- `lib/models/order.dart`
  ```dart
  class Order {
    String id;                          // Unique order ID
    String userId;                      // Customer user ID
    List<CartItem> items;               // Ordered products
    double totalAmount;                 // Order total
    String customerName;                // Delivery name
    String phoneNumber;                 // Contact number
    String email;                       // Contact email
    String address;                     // Delivery address
    String paymentMethod;               // Payment type
    String orderStatus;                 // Order state
    DateTime orderDate;                 // Order timestamp
    List<OrderStatusHistory> statusHistory;  // Status changes
    DateTime? confirmedAt, shippedAt, deliveredAt;
    String? trackingNumber;
    String? deliveryNote;
  }
  ```

- `lib/models/address.dart`
  ```dart
  class Address {
    String id, userId, name, phoneNumber;
    String addressLine1, addressLine2;
    String city, state, zipCode;
    bool isDefault;
  }
  ```

- `lib/models/payment_method.dart`
  ```dart
  class PaymentMethod {
    String id, userId, type;  // type: Credit/Debit Card, UPI, Net Banking, COD
    String? cardNumber, cardHolderName;
    String? expiryDate, cvv;
    String? upiId, bankName;
    bool isDefault;
  }
  ```

#### Checkout Flow (Step-by-Step):

1. **Cart Review**:
   - User views cart items in CartScreen
   - Can adjust quantities or remove items
   - Sees subtotal calculation
   - Taps "Proceed to Checkout" button

2. **Checkout Screen**:
   - **Address Section**:
     - Displays default address or allows selection
     - Option to add new address
     - Address validation (name, phone, city, state, zip)
   
   - **Payment Section**:
     - Displays default payment method or allows selection
     - Supports: Credit/Debit Card, UPI, Net Banking, COD
     - Option to add new payment method
   
   - **Order Summary**:
     - Lists all cart items with quantities
     - Shows subtotal, taxes, delivery charges (if any)
     - Displays grand total

3. **Place Order**:
   - User taps "Place Order" button
   - Validation checks:
     - Cart not empty
     - Address selected
     - Payment method selected
     - All required fields filled
   
4. **Order Processing**:
   ```dart
   // ProductController.placeOrder() flow
   - Generate unique order ID: "order_{timestamp}"
   - Create Order object with all details
   - Set initial status: "Pending"
   - Save order to Firestore 'orders' collection
   - Send FCM notification to admin
   - Send order confirmation email (if configured)
   - Clear cart items
   - Navigate to OrderSuccessScreen
   ```

5. **Order Confirmation**:
   - Success message displayed
   - Order ID shown
   - Expected delivery timeline shown
   - Options to:
     - View order details
     - Continue shopping
     - Track order

#### Backend Collections:

- **`orders` Collection** (Firestore):
  ```json
  {
    "order_1234567890": {
      "userId": "user123",
      "items": [
        {
          "product": { /* product details */ },
          "quantity": 2
        }
      ],
      "totalAmount": 179.98,
      "customerName": "John Doe",
      "phoneNumber": "+1234567890",
      "email": "john@example.com",
      "address": "123 Main St, City, State - 12345",
      "paymentMethod": "Credit/Debit Card",
      "orderStatus": "Pending",
      "orderDate": "2026-02-17T10:30:00Z",
      "statusHistory": [
        {
          "status": "Pending",
          "timestamp": "2026-02-17T10:30:00Z",
          "updatedBy": "System",
          "note": "Order placed"
        }
      ]
    }
  }
  ```

- **`addresses` Collection** (Firestore):
  - Stores user addresses for quick reuse
  - Linked to user via `userId` field

- **`payment_methods` Collection** (Firestore):
  - Stores saved payment methods (securely)
  - Card details should be tokenized in production

#### Payment Processing:
**Current Implementation**: 
- Payment info collected but not processed (no payment gateway integration)
- All payments are recorded as successful immediately
- App is in "test mode" for payment flow

**Production Requirements**:
- Integrate Stripe, Razorpay, or similar payment gateway
- Implement secure payment token handling
- Add 3D Secure authentication
- Handle payment failures and retries

---

### 4.5 Order Management & Tracking

#### UI Files:
- `lib/screens/orders/my_orders_screen.dart` - User's order history
- `lib/screens/orders/user_order_detail_screen.dart` - Order details
- `lib/screens/inventory/inventory_screen.dart` - Admin order dashboard
- `lib/screens/inventory/inventory_detail_screen.dart` - Admin order management

#### Controller:
- `lib/controllers/order_controller.dart`
  - **User Methods**:
    - `loadOrders()`: Fetch user's orders
    - `getOrderById()`: Get specific order details
  
  - **Admin Methods**:
    - `loadAllOrders()`: Fetch all orders (admin only)
    - `updateOrderStatus()`: Change order state
    - Order status: Pending → Confirmed → Shipped → Delivered
  
  - **Observable State**:
    - `orders` - Current user's orders
    - `allOrders` - All orders (admin view)
    - `isLoading` - Loading state

#### Service Layer:
- `lib/services/firestore_service.dart`
  - `getUserOrders(userId)`: Query orders by user
  - `getAllOrders()`: Fetch all orders (admin)
  - `getOrderById(orderId)`: Single order retrieval
  - `updateOrderStatus()`: Update order state and history
  - `incrementProductSoldCount()`: Update product sales count

- `lib/services/fcm_notification_service.dart`
  - `sendOrderStatusUpdateNotification()`: Notify user of status changes
  - `sendOrderNotificationToAdmin()`: Alert admin of new orders

#### Order Status Workflow:

```
┌──────────┐    Admin      ┌───────────┐    Admin      ┌─────────┐    Admin      ┌───────────┐
│ Pending  │ ───confirms──>│ Confirmed │ ───ships────> │ Shipped │ ──delivers──> │ Delivered │
└──────────┘               └───────────┘               └─────────┘               └───────────┘
     │                                                        │
     │                                                        │
     └──────────────────────cancel───────────────────────────┘
                                │
                                ▼
                          ┌───────────┐
                          │ Cancelled │
                          └───────────┘
```

#### Order Status States:
1. **Pending**: Initial state when order is placed
   - Customer has placed the order
   - Awaiting admin confirmation
   - Admin receives push notification

2. **Confirmed**: Admin has acknowledged the order
   - Order verified and accepted
   - Payment confirmed
   - Preparing for shipment
   - `confirmedAt` timestamp recorded

3. **Shipped**: Order dispatched
   - Tracking number added
   - Estimated delivery date set
   - Customer notified with tracking info
   - `shippedAt` timestamp recorded

4. **Delivered**: Order successfully delivered
   - Customer receives the order
   - Transaction complete
   - Product `soldCount` incremented
   - Customer can now write a review
   - `deliveredAt` timestamp recorded

5. **Cancelled**: Order cancelled (by user or admin)
   - Can be cancelled if not yet shipped
   - Refund processed (if applicable)
   - Cancellation note added

#### Admin Order Management:

**Inventory Screen** (`inventory_screen.dart`):
- Dashboard showing all orders
- Filter by status (All, Pending, Confirmed, Shipped, Delivered)
- Order count badges
- Quick status update buttons
- Search orders by customer name or order ID

**Order Detail Screen** (Admin view):
1. **Order Information**:
   - Order ID, date, status
   - Customer details (name, email, phone)
   - Delivery address
   - Payment method

2. **Order Items**:
   - Product list with images
   - Quantities and individual prices
   - Total amount calculation

3. **Status History**:
   - Timeline of status changes
   - Timestamps for each update
   - Admin notes for each change

4. **Actions**:
   - Update status dropdown
   - Add tracking number
   - Add delivery notes
   - Save changes button
   - Push notification sent on update

#### User Order View:

**My Orders Screen** (`my_orders_screen.dart`):
- Lists all user's past orders
- Sorted by date (newest first)
- Shows order summary: ID, date, total, status
- Status badge color-coded:
  - Pending: Orange
  - Confirmed: Blue
  - Shipped: Purple
  - Delivered: Green
  - Cancelled: Red

**Order Detail Screen** (User view):
- Read-only view of order details
- Track order status
- View status history
- Contact support button
- Reorder functionality (future feature)

#### Notifications:
- **New Order**: Admin receives notification when order placed
- **Status Update**: User receives notification on each status change
- **Delivered**: Special notification when order delivered
- Uses both FCM (Firebase Cloud Messaging) and local notifications

---

### 4.6 Product Reviews & Ratings

#### UI Files:
- `lib/screens/product/product_detail_screen.dart` - Includes review section
- Reviews displayed in a list within product detail page

#### Controller:
- `lib/controllers/product_controller.dart`
  - `submitReview()`: Add new review for a product
  - `loadReviews(productId)`: Fetch reviews for a product
  - Reviews linked to delivered orders (verified purchase)

#### Service Layer:
- `lib/services/firestore_service.dart`
  - `addReview()`: Save review to Firestore
  - `getProductReviews(productId)`: Fetch product reviews
  - `updateProductRating()`: Recalculate average rating
  - `canUserReview()`: Check if user can review (must have delivered order)

#### Data Model:
- `lib/models/review.dart`
  ```dart
  class Review {
    String id, productId, userId, userName, orderId;
    double rating;              // 1-5 stars
    String comment;
    DateTime createdAt;
    bool isVerifiedPurchase;    // True if from delivered order
  }
  ```

#### Review Workflow:
1. User receives delivered order
2. Option to "Write a Review" appears in order detail
3. Review form shows:
   - Star rating selector (1-5)
   - Comment text field
   - Submit button
4. On submit:
   - Review saved to `reviews` collection
   - Product's `rating` and `reviewCount` updated
   - Aggregate rating recalculated
5. Review appears on product detail page
6. "Verified Purchase" badge shown for legitimate reviews

#### Rating Calculation:
```dart
// Aggregate rating calculation
avgRating = (sum of all ratings) / (number of reviews)
```

---

### 4.7 Admin Inventory Management

#### UI Files:
- `lib/screens/inventory/inventory_screen.dart` - Order management dashboard
- `lib/screens/product/add_product_screen.dart` - Add new products
- `lib/screens/product/edit_product_screen.dart` - Edit existing products
- `lib/screens/product/all_products_screen.dart` - Product catalog management

#### Controllers:
- `lib/controllers/product_controller.dart`
  - `addProduct()`: Create new product
  - `updateProduct()`: Edit product details
  - `deleteProduct()`: Remove product from catalog
  - `updateProductQuantity()`: Manage stock levels

- `lib/controllers/order_controller.dart`
  - `loadAllOrders()`: Admin order view
  - `updateOrderStatus()`: Process orders

#### Service Layer:
- `lib/services/firestore_service.dart`
  - **Product Management**:
    - `addProduct(product)`: Add to catalog
    - `updateProduct(productId, updates)`: Modify product
    - `deleteProduct(productId)`: Remove product
    - `incrementProductSoldCount()`: Auto-update on delivery
  
  - **Stock Management**:
    - Products have `quantity` field
    - Decremented on order placement (optional feature)
    - Low stock alerts (can be implemented)

#### Admin Features:

1. **Product CRUD**:
   - Add new products with images
   - Edit product details (name, price, description, etc.)
   - Delete products (with confirmation)
   - Manage product inventory levels

2. **Order Processing**:
   - View all customer orders
   - Filter by status
   - Update order status
   - Add tracking information
   - Send notifications to customers

3. **Dashboard Analytics** (partially implemented):
   - Total orders count
   - Pending orders count
   - Revenue tracking (can be calculated)
   - Best-selling products

4. **Image Management**:
   - Upload product images via Cloudinary
   - Support for multiple image formats
   - Automatic image optimization

#### Admin Access Control:
- Hardcoded admin email: `admin@turfmate.com`
- Admin-only UI elements shown conditionally:
  ```dart
  if (userEmail == 'admin@turfmate.com') {
    // Show admin controls
  }
  ```
- **Security Note**: Role-based access control should be implemented in Firestore Security Rules for production

---

### 4.8 Customer Support System

#### UI Files:
- `lib/screens/support/user_tickets_screen.dart` - User's support tickets
- `lib/screens/support/admin_tickets_screen.dart` - Admin ticket dashboard
- `lib/screens/support/ticket_detail_screen.dart` - Ticket conversation
- `lib/screens/support/help_support_screen.dart` - Help center & FAQ

#### Service Layer:
- `lib/services/firestore_service.dart`
  - `createSupportTicket()`: Create new ticket
  - `getUserTickets(userId)`: User's tickets
  - `getAllSupportTickets()`: Admin view of all tickets
  - `replyToTicket()`: Add reply to ticket
  - `updateTicketStatus()`: Change ticket state
  - `markTicketAsRead()`: Mark as read by user/admin

#### Data Model:
- `lib/models/support_ticket.dart`
  ```dart
  class SupportTicket {
    String id, userId, userName, userEmail;
    String issue;                   // Problem description
    String status;                  // pending, in-progress, resolved, closed
    DateTime createdAt, updatedAt;
    List<TicketReply> replies;      // Conversation thread
    bool hasUnreadReplies;          // Notification flag
  }

  class TicketReply {
    String id, message, senderName;
    bool isAdmin;                   // True if admin reply
    DateTime createdAt;
  }
  ```

#### Support Ticket Workflow:

1. **User Creates Ticket**:
   - User navigates to Help & Support
   - Taps "Create New Ticket"
   - Describes the issue
   - Ticket created with status "pending"
   - Admin receives notification

2. **Ticket Statuses**:
   - **pending**: Awaiting admin response
   - **in-progress**: Admin is working on it
   - **resolved**: Issue fixed, awaiting user confirmation
   - **closed**: Ticket completed

3. **Admin Response**:
   - Admin views ticket in admin dashboard
   - Changes status to "in-progress"
   - Writes reply to the user
   - User receives push notification

4. **Conversation Thread**:
   - User and admin can exchange multiple messages
   - Each reply timestamped
   - Replies marked as user or admin
   - Unread replies flagged

5. **Resolution**:
   - Admin marks ticket as "resolved"
   - User can reopen if issue persists
   - Or confirm resolution and close ticket

#### Backend:
- **Firestore Collection**: `support_tickets`
  ```json
  {
    "ticket_123": {
      "userId": "user123",
      "userName": "John Doe",
      "userEmail": "john@example.com",
      "issue": "Product not delivered",
      "status": "in-progress",
      "createdAt": Timestamp,
      "updatedAt": Timestamp,
      "replies": [
        {
          "id": "reply1",
          "message": "I haven't received my order yet",
          "isAdmin": false,
          "senderName": "John Doe",
          "createdAt": Timestamp
        },
        {
          "id": "reply2",
          "message": "We're checking with the courier",
          "isAdmin": true,
          "senderName": "Admin",
          "createdAt": Timestamp
        }
      ],
      "hasUnreadReplies": true
    }
  }
  ```

---

### 4.9 AI Chatbot (Gemini Integration)

#### UI Files:
- `lib/screens/chat/chat_screen.dart` - Chat interface

#### Controller:
- `lib/controllers/chat_controller.dart`
  - Manages chat messages
  - Handles user input
  - Triggers AI responses

#### Service Layer:
- `lib/services/gemini_chat_service.dart`
  - Uses Google Generative AI (Gemini) API
  - Sends user messages to Gemini
  - Receives and formats AI responses
  - Context-aware conversations

- `lib/services/gemini_chat_service_http.dart`
  - Alternative HTTP-based implementation

#### Data Model:
- `lib/models/chat_message.dart`
  ```dart
  class ChatMessage {
    String id, message;
    bool isUser;        // True for user, false for bot
    DateTime timestamp;
  }
  ```

#### Chatbot Features:

1. **Product Assistance**:
   - Answer product-related questions
   - Provide product recommendations
   - Explain product features and specifications

2. **Order Support**:
   - Help with order tracking
   - Explain order statuses
   - Guide through checkout process

3. **App Navigation**:
   - Guide users through app features
   - Explain how to use various functions

4. **Contextual Responses**:
   - Gemini model: gemini-1.5-flash
   - System prompt defines chatbot personality
   - Scoped to TurfMate app and products
   - Refuses off-topic questions

#### System Prompt:
```
You are Turf-Mate Assistant, a helpful chatbot for a football 
products e-commerce app called Turf-Mate.

Your role:
- Help users find football products (jerseys, shoes, accessories)
- Assist with orders and deliveries
- Guide users through app features
- Answer product-related questions

Be friendly, concise, and football-enthusiastic!
```

#### Implementation:
```dart
// Message flow
User sends message
  → ChatController captures input
    → GeminiChatService.sendMessage()
      → Gemini API processes request
        → AI response generated
          → Displayed in chat UI
```

---

### 4.10 Push Notifications

#### Service Layer:
- `lib/services/fcm_notification_service.dart`
  - Firebase Cloud Messaging integration
  - Local notification display
  - Notification handling and routing

- `lib/services/onesignal_service.dart`
  - Alternative notification service (OneSignal)

#### Notification Types:

1. **Order Notifications**:
   - New order placed (to admin)
   - Order confirmed (to user)
   - Order shipped (to user)
   - Order delivered (to user)

2. **Support Notifications**:
   - New ticket created (to admin)
   - Admin replied to ticket (to user)

3. **App Notifications**:
   - Welcome message
   - Promotional offers
   - App updates

#### FCM Implementation:

**Initialization**:
```dart
// In main.dart
final fcmService = FCMNotificationService();
await fcmService.initialize();
```

**Token Management**:
- FCM token generated on app install
- Token saved to Firestore under user document
- Admin receives notifications via `admin@turfmate.com` token

**Notification Channels** (Android):
- Channel ID: `turf_app_notifications`
- Channel Name: Order Notifications
- Importance: High
- Sound: Enabled
- Vibration: Enabled

**Notification Handling**:
1. **Foreground**: Display local notification banner
2. **Background**: System notification shown
3. **Terminated**: Notification stored, handled on app open
4. **Tap**: Navigate to relevant screen (order detail, ticket, etc.)

**Backend Setup**:
- Firebase Cloud Functions (optional) for server-side notifications
- Or direct FCM API calls from app

#### OneSignal Integration:
- Alternative push notification service
- Package: `onesignal_flutter ^5.1.0`
- Can be used for more advanced notification features
- Segmentation, A/B testing, rich media

---

## 5. Data Models

### Complete Model Specifications

#### 5.1 Product Model
```dart
class Product {
  String id;                    // Unique product ID
  String name;                  // Product name
  double price;                 // Current selling price
  double? originalPrice;        // Original price (for discounts)
  String team;                  // Sports team (e.g., "Manchester United")
  String category;              // Category: Jerseys, Shoes, Accessories, etc.
  String brand;                 // Brand name: Adidas, Nike, Puma, Others
  String imageUrl;              // Cloudinary or Firebase Storage URL
  double rating;                // Average rating (0-5)
  int reviewCount;              // Number of reviews
  bool isFavorite;              // User's favorite status
  List<String> sizes;           // Available sizes: S, M, L, XL, XXL
  List<Color> colors;           // Available colors
  String description;           // Detailed product description
  int quantity;                 // Stock quantity
  int soldCount;                // Total units sold
  DateTime? created_at;         // Creation timestamp
  DateTime? updated_at;         // Last update timestamp
}
```

**Collections**: `products`

**Indexing Recommendations**:
- Index on `category` for fast filtering
- Index on `team` for team-based searches
- Index on `brand` for brand filtering
- Composite index on `category + price` for sorted listings

---

#### 5.2 Order Model
```dart
class Order {
  String id;                            // order_{timestamp}
  String userId;                        // Customer's Firebase UID
  List<CartItem> items;                 // Ordered products
  double totalAmount;                   // Grand total
  String customerName;                  // Delivery recipient name
  String phoneNumber;                   // Contact number
  String email;                         // Contact email
  String address;                       // Full delivery address
  String paymentMethod;                 // Payment type
  String orderStatus;                   // Current status
  DateTime orderDate;                   // Order placement date
  List<OrderStatusHistory> statusHistory; // Status change log
  DateTime? confirmedAt;                // Confirmation timestamp
  DateTime? shippedAt;                  // Shipping timestamp
  DateTime? deliveredAt;                // Delivery timestamp
  String? trackingNumber;               // Courier tracking ID
  String? deliveryNote;                 // Delivery instructions
}

class OrderStatusHistory {
  String status;          // Status name
  DateTime timestamp;     // When changed
  String updatedBy;       // Admin name or "System"
  String? note;           // Optional note
}
```

**Collections**: `orders`

**Queries**:
- Orders by user: `where('userId', '==', userId)`
- Orders by status: `where('orderStatus', '==', status)`
- Recent orders: `orderBy('orderDate', 'desc')`

---

#### 5.3 CartItem Model
```dart
class CartItem {
  Product product;        // Full product object
  int quantity;           // Item quantity
  
  double get totalPrice => product.price * quantity;
}
```

**Storage**: Local only (SharedPreferences)

**JSON Format**:
```json
{
  "product": { /* Product object */ },
  "quantity": 2
}
```

---

#### 5.4 Address Model
```dart
class Address {
  String id;              // Unique address ID
  String userId;          // User's Firebase UID
  String name;            // Recipient name
  String phoneNumber;     // Contact number
  String addressLine1;    // Street address
  String addressLine2;    // Apartment, suite, floor (optional)
  String city;            // City
  String state;           // State/Province
  String zipCode;         // Postal code
  bool isDefault;         // Primary address flag
}
```

**Collections**: `addresses`

**Queries**:
- User addresses: `where('userId', '==', userId)`
- Default address: `where('userId', '==', userId).where('isDefault', '==', true)`

---

#### 5.5 Payment Method Model
```dart
class PaymentMethod {
  String id;              // Unique payment ID
  String userId;          // User's Firebase UID
  String type;            // Credit/Debit Card, UPI, Net Banking, COD
  
  // Card details
  String? cardNumber;     // Last 4 digits only
  String? cardHolderName;
  String? expiryDate;     // MM/YY
  String? cvv;            // Should NOT be stored in production
  
  // UPI details
  String? upiId;
  
  // Banking details
  String? bankName;
  
  bool isDefault;         // Primary payment method
}
```

**Collections**: `payment_methods`

**Security Notes**:
- **Never store full card numbers or CVVs**
- Use payment gateway tokens instead
- PCI DSS compliance required for card storage
- Current implementation is for testing only

---

#### 5.6 Review Model
```dart
class Review {
  String id;                  // Unique review ID
  String productId;           // Product being reviewed
  String userId;              // Reviewer's UID
  String userName;            // Reviewer's name
  String orderId;             // Associated order
  double rating;              // 1-5 stars
  String comment;             // Review text
  DateTime createdAt;         // Review date
  bool isVerifiedPurchase;    // True if from delivered order
}
```

**Collections**: `reviews`

**Queries**:
- Product reviews: `where('productId', '==', productId).orderBy('createdAt', 'desc')`
- User reviews: `where('userId', '==', userId)`

---

#### 5.7 Support Ticket Model
```dart
class SupportTicket {
  String id;                      // Unique ticket ID
  String userId;                  // User's UID
  String userName;                // User's display name
  String userEmail;               // Contact email
  String issue;                   // Problem description
  String status;                  // pending, in-progress, resolved, closed
  DateTime createdAt;             // Creation time
  DateTime? updatedAt;            // Last update time
  List<TicketReply> replies;      // Conversation
  bool hasUnreadReplies;          // Notification flag
}

class TicketReply {
  String id;                      // Reply ID
  String message;                 // Reply text
  bool isAdmin;                   // Admin reply flag
  String senderName;              // Sender's name
  DateTime createdAt;             // Reply time
}
```

**Collections**: `support_tickets`

**Queries**:
- User tickets: `where('userId', '==', userId).orderBy('createdAt', 'desc')`
- Admin dashboard: `orderBy('updatedAt', 'desc')`
- Pending tickets: `where('status', '==', 'pending')`

---

#### 5.8 Chat Message Model
```dart
class ChatMessage {
  String id;              // Message ID
  String message;         // Message text
  bool isUser;            // true = user, false = bot
  DateTime timestamp;     // Message time
}
```

**Storage**: Local only (not persisted to backend)

---

#### 5.9 User Profile Model
```dart
// Firestore 'users' collection
{
  uid: String;                  // Firebase UID
  email: String;                // User email
  displayName: String;          // Display name
  photoURL: String;             // Profile photo URL
  profileImageUrl: String?;     // Custom profile image
  coverImageUrl: String?;       // Profile cover image
  createdAt: Timestamp;         // Account creation
  lastLogin: Timestamp;         // Last login time
}
```

**Collections**: `users`

**Auto-created on**:
- Google Sign-In
- Email/Password Registration

---

## 6. Workflow Logic

### 6.1 Complete User Purchase Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   USER PURCHASE WORKFLOW                     │
└─────────────────────────────────────────────────────────────┘

1. AUTHENTICATION
   ├─> User opens app
   ├─> SplashScreen checks auth state
   │   ├─> If logged in → Navigate to HomeScreen
   │   └─> If not → Navigate to OnboardingScreen → LoginScreen
   ├─> User logs in (Email/Password or Google)
   ├─> AuthController updates isLoggedIn state
   ├─> FCM token registered for user
   └─> Navigate to HomeScreen

2. PRODUCT DISCOVERY
   ├─> HomeScreen displays product catalog
   ├─> User searches or filters products
   │   ├─> Search by name/team/category
   │   ├─> Filter by category (Jerseys, Shoes, etc.)
   │   ├─> Filter by team (Manchester United, Real Madrid, etc.)
   │   └─> Filter by brand (Adidas, Nike, etc.)
   ├─> User browses product cards
   │   ├─> Each card shows: image, name, price, rating
   │   └─> Discount badge if originalPrice exists
   └─> User taps on product card

3. PRODUCT DETAILS
   ├─> Navigate to ProductDetailScreen
   ├─> Display complete product information:
   │   ├─> Large product image
   │   ├─> Product name and description
   │   ├─> Current price and original price (if discounted)
   │   ├─> Rating and review count
   │   ├─> Available sizes (S, M, L, XL)
   │   ├─> Available colors
   │   ├─> Stock quantity
   │   └─> Customer reviews
   ├─> User selects size and color (if applicable)
   ├─> User chooses action:
   │   ├─> "Add to Cart" button
   │   └─> "Add to Wishlist" button (heart icon)
   └─> User taps "Add to Cart"

4. ADD TO CART
   ├─> ProductController.addToCart(product)
   ├─> Check if product already in cart:
   │   ├─> If yes: Increment quantity
   │   └─> If no: Add new CartItem with quantity = 1
   ├─> Update cartItems observable list
   ├─> Save cart to SharedPreferences (persistence)
   ├─> Show success snackbar: "{Product} added to cart"
   └─> Cart badge updated with item count

5. VIEW CART
   ├─> User taps cart icon (bottom navigation or top bar)
   ├─> Navigate to CartScreen
   ├─> Display all cart items:
   │   ├─> Product image, name, price
   │   ├─> Quantity selector (+/- buttons)
   │   ├─> Remove button (swipe or tap)
   │   └─> Item total (price × quantity)
   ├─> Show cart summary:
   │   ├─> Subtotal (sum of all items)
   │   ├─> Delivery charges (if applicable)
   │   ├─> Taxes (if applicable)
   │   └─> Grand Total
   ├─> User adjusts quantities if needed
   └─> User taps "Proceed to Checkout" button

6. CHECKOUT - ADDRESS
   ├─> Navigate to CheckoutScreen
   ├─> Load user's saved addresses
   │   ├─> AddressController.loadAddresses()
   │   └─> Fetch from Firestore 'addresses' collection
   ├─> Display default address (if exists)
   ├─> User options:
   │   ├─> Use default address
   │   ├─> Select different saved address
   │   └─> Add new address
   ├─> If adding new address:
   │   ├─> Navigate to AddAddressScreen
   │   ├─> User fills form:
   │   │   ├─> Name
   │   │   ├─> Phone number
   │   │   ├─> Address line 1
   │   │   ├─> Address line 2 (optional)
   │   │   ├─> City
   │   │   ├─> State
   │   │   ├─> ZIP code
   │   │   └─> Set as default checkbox
   │   ├─> AddressController.addAddress()
   │   ├─> Save to Firestore
   │   └─> Return to CheckoutScreen
   └─> Address selected and displayed

7. CHECKOUT - PAYMENT
   ├─> Payment section on CheckoutScreen
   ├─> Load saved payment methods
   │   ├─> PaymentMethodController.loadPaymentMethods()
   │   └─> Fetch from Firestore 'payment_methods' collection
   ├─> Display default payment method (if exists)
   ├─> User options:
   │   ├─> Use default payment
   │   ├─> Select different saved payment
   │   └─> Add new payment method
   ├─> If adding new payment:
   │   ├─> Navigate to AddPaymentMethodScreen
   │   ├─> User selects type:
   │   │   ├─> Credit/Debit Card
   │   │   ├─> UPI
   │   │   ├─> Net Banking
   │   │   └─> Cash on Delivery (COD)
   │   ├─> User fills payment details
   │   ├─> PaymentMethodController.addPaymentMethod()
   │   ├─> Save to Firestore
   │   └─> Return to CheckoutScreen
   └─> Payment method selected

8. CHECKOUT - REVIEW
   ├─> Order summary displayed:
   │   ├─> Delivery address
   │   ├─> Payment method
   │   ├─> Order items with quantities
   │   └─> Total amount
   ├─> User reviews all details
   └─> User taps "Place Order" button

9. ORDER PLACEMENT
   ├─> ProductController.placeOrder()
   ├─> Validation:
   │   ├─> Check cart not empty
   │   ├─> Check address selected
   │   ├─> Check payment method selected
   │   └─> Validate all required fields
   ├─> Generate unique order ID: "order_{timestamp}"
   ├─> Create Order object:
   │   ├─> userId: current user UID
   │   ├─> items: copy of cartItems
   │   ├─> totalAmount: grand total
   │   ├─> customerName: from address
   │   ├─> phoneNumber: from address
   │   ├─> email: user email
   │   ├─> address: full address string
   │   ├─> paymentMethod: selected payment type
   │   ├─> orderStatus: "Pending"
   │   ├─> orderDate: DateTime.now()
   │   └─> statusHistory: [initial "Pending" status]
   ├─> Save order:
   │   ├─> FirestoreService.saveOrder(order)
   │   └─> Firestore 'orders' collection
   ├─> Send notifications:
   │   ├─> FCMService.sendOrderNotificationToAdmin()
   │   └─> Admin receives "New order placed" notification
   ├─> Clear cart:
   │   ├─> ProductController.clearCart()
   │   └─> Remove from SharedPreferences
   └─> Navigate to OrderSuccessScreen

10. ORDER CONFIRMATION
    ├─> OrderSuccessScreen displayed
    ├─> Show success message
    ├─> Display order ID
    ├─> Show expected delivery timeline
    ├─> User options:
    │   ├─> "View Order Details" → MyOrdersScreen
    │   ├─> "Continue Shopping" → HomeScreen
    │   └─> "Track Order" → Order tracking feature
    └─> User can track order status in My Orders

11. ORDER TRACKING (USER)
    ├─> User navigates to Profile → My Orders
    ├─> OrderController.loadOrders()
    ├─> Fetch user's orders from Firestore
    ├─> Display order list:
    │   ├─> Order ID, date, total, status
    │   └─> Status badge (color-coded)
    ├─> User taps on order
    ├─> Navigate to UserOrderDetailScreen
    ├─> Display order details:
    │   ├─> Order information
    │   ├─> Items list
    │   ├─> Status history timeline
    │   ├─> Delivery address
    │   └─> Payment method
    ├─> User receives FCM notifications:
    │   ├─> Order confirmed
    │   ├─> Order shipped (with tracking number)
    │   └─> Order delivered
    └─> After delivery, user can write review

12. POST-DELIVERY
    ├─> Order status: "Delivered"
    ├─> User receives delivery notification
    ├─> "Write a Review" button appears
    ├─> User taps to review product
    ├─> User rates product (1-5 stars)
    ├─> User writes comment
    ├─> ProductController.submitReview()
    ├─> Review saved to 'reviews' collection
    ├─> Product rating updated
    └─> Review appears on product detail page
```

---

### 6.2 Admin Order Processing Flow

```
┌─────────────────────────────────────────────────────────────┐
│               ADMIN ORDER PROCESSING WORKFLOW                │
└─────────────────────────────────────────────────────────────┘

1. NEW ORDER NOTIFICATION
   ├─> Customer places order
   ├─> Admin receives FCM notification:
   │   ├─> Title: "New Order Placed"
   │   ├─> Body: "Order #{orderId} from {customerName}"
   │   └─> Taps notification
   ├─> Navigate to InventoryScreen (Order Dashboard)
   └─> Order appears in "Pending" tab

2. ORDER DASHBOARD
   ├─> InventoryScreen displays all orders
   ├─> Tabs for filtering:
   │   ├─> All Orders
   │   ├─> Pending (with count badge)
   │   ├─> Confirmed
   │   ├─> Shipped
   │   └─> Delivered
   ├─> Each order card shows:
   │   ├─> Order ID
   │   ├─> Customer name
   │   ├─> Order date
   │   ├─> Total amount
   │   ├─> Current status
   │   └─> Quick action buttons
   ├─> Admin searches for specific order (optional)
   └─> Admin taps on order card

3. ORDER REVIEW
   ├─> Navigate to InventoryDetailScreen
   ├─> Display complete order information:
   │   ├─> Order ID and date
   │   ├─> Customer details:
   │   │   ├─> Name
   │   │   ├─> Email
   │   │   ├─> Phone number
   │   │   └─> Delivery address
   │   ├─> Order items:
   │   │   ├─> Product images
   │   │   ├─> Product names
   │   │   ├─> Quantities
   │   │   ├─> Individual prices
   │   │   └─> Subtotals
   │   ├─> Payment method
   │   ├─> Total amount
   │   ├─> Current status
   │   └─> Status history timeline
   ├─> Admin verifies order details
   └─> Admin decides on action

4. CONFIRM ORDER
   ├─> Admin selects "Confirmed" from status dropdown
   ├─> Admin adds note (optional): "Order verified, preparing shipment"
   ├─> Admin taps "Update Status" button
   ├─> OrderController.updateOrderStatus()
   │   ├─> Update order in Firestore:
   │   │   ├─> orderStatus: "Confirmed"
   │   │   ├─> confirmedAt: DateTime.now()
   │   │   └─> Add to statusHistory
   │   └─> Send FCM notification to customer:
   │       ├─> Title: "Order Confirmed"
   │       └─> Body: "Your order #{orderId} has been confirmed"
   ├─> Success message shown to admin
   └─> Order moved to "Confirmed" tab

5. PREPARE SHIPMENT
   ├─> Admin packages the order
   ├─> Admin obtains tracking number from courier
   ├─> Admin returns to order detail screen
   └─> Admin updates status to "Shipped"

6. SHIP ORDER
   ├─> Admin selects "Shipped" from status dropdown
   ├─> Admin enters tracking number
   ├─> Admin adds delivery note (optional): "Expected delivery in 3-5 days"
   ├─> Admin taps "Update Status" button
   ├─> OrderController.updateOrderStatus()
   │   ├─> Update order in Firestore:
   │   │   ├─> orderStatus: "Shipped"
   │   │   ├─> shippedAt: DateTime.now()
   │   │   ├─> trackingNumber: entered number
   │   │   ├─> deliveryNote: entered note
   │   │   └─> Add to statusHistory
   │   └─> Send FCM notification to customer:
   │       ├─> Title: "Order Shipped"
   │       ├─> Body: "Your order is on the way! Track: {trackingNumber}"
   │       └─> Notification includes tracking info
   ├─> Success message shown to admin
   └─> Order moved to "Shipped" tab

7. DELIVERY CONFIRMATION
   ├─> Admin confirms delivery (via courier or customer contact)
   ├─> Admin selects "Delivered" from status dropdown
   ├─> Admin adds note (optional): "Delivered successfully"
   ├─> Admin taps "Update Status" button
   ├─> OrderController.updateOrderStatus()
   │   ├─> Update order in Firestore:
   │   │   ├─> orderStatus: "Delivered"
   │   │   ├─> deliveredAt: DateTime.now()
   │   │   └─> Add to statusHistory
   │   ├─> Update product sold count:
   │   │   ├─> For each item in order
   │   │   └─> FirestoreService.incrementProductSoldCount()
   │   └─> Send FCM notification to customer:
   │       ├─> Title: "Order Delivered"
   │       └─> Body: "Your order has been delivered. Enjoy!"
   ├─> Success message shown to admin
   ├─> Order moved to "Delivered" tab
   └─> Transaction complete

8. CANCELLATION (IF NEEDED)
   ├─> Admin or customer requests cancellation
   ├─> Admin verifies order can be cancelled (not yet shipped)
   ├─> Admin selects "Cancelled" from status dropdown
   ├─> Admin adds cancellation reason
   ├─> Admin taps "Update Status" button
   ├─> OrderController.updateOrderStatus()
   │   ├─> Update order in Firestore:
   │   │   ├─> orderStatus: "Cancelled"
   │   │   └─> Add to statusHistory with reason
   │   ├─> Restore product stock (if inventory tracking enabled)
   │   └─> Send notification to customer
   ├─> Process refund (if payment was collected)
   └─> Order marked as cancelled
```

---

### 6.3 Product Management Workflow (Admin)

```
┌─────────────────────────────────────────────────────────────┐
│              PRODUCT MANAGEMENT WORKFLOW (ADMIN)             │
└─────────────────────────────────────────────────────────────┘

1. ADD NEW PRODUCT
   ├─> Admin taps "Add Product" button (HomeScreen or AllProductsScreen)
   ├─> Navigate to AddProductScreen
   ├─> Admin fills product details:
   │   ├─> Product name
   │   ├─> Description
   │   ├─> Category (dropdown: Jerseys, Shoes, Accessories, Balls, Training)
   │   ├─> Team (dropdown: Manchester United, Real Madrid, Bayern, etc.)
   │   ├─> Brand (dropdown: Adidas, Nike, Puma, Others)
   │   ├─> Price
   │   ├─> Original price (optional, for discounts)
   │   ├─> Quantity (stock)
   │   ├─> Available sizes (multi-select: S, M, L, XL, XXL)
   │   └─> Available colors (color picker)
   ├─> Admin uploads product image:
   │   ├─> Tap "Choose Image" button
   │   ├─> Image picker options:
   │   │   ├─> Camera
   │   │   └─> Gallery
   │   ├─> Admin selects image
   │   ├─> ImageUploadService processes image:
   │   │   ├─> Compress image
   │   │   ├─> Upload to Cloudinary
   │   │   └─> Get image URL
   │   └─> Image preview shown
   ├─> Admin taps "Add Product" button
   ├─> ProductController.addProduct()
   │   ├─> Validate all fields
   │   ├─> Create Product object
   │   ├─> Generate product ID: "product_{timestamp}"
   │   ├─> FirestoreService.addProduct()
   │   └─> Save to 'products' collection
   ├─> Success message: "Product added successfully"
   └─> Navigate back to product list

2. EDIT PRODUCT
   ├─> Admin views product in AllProductsScreen
   ├─> Admin taps "Edit" button on product card
   ├─> Navigate to EditProductScreen
   ├─> Load existing product data
   ├─> Admin modifies fields:
   │   ├─> Any field can be changed
   │   └─> Can upload new image
   ├─> Admin taps "Update Product" button
   ├─> ProductController.updateProduct()
   │   ├─> Validate changes
   │   ├─> FirestoreService.updateProduct()
   │   └─> Update in Firestore
   ├─> Success message: "Product updated"
   └─> Navigate back

3. DELETE PRODUCT
   ├─> Admin taps "Delete" button on product
   ├─> Confirmation dialog appears:
   │   ├─> "Are you sure you want to delete this product?"
   │   └─> "Cancel" / "Delete" buttons
   ├─> Admin confirms deletion
   ├─> ProductController.deleteProduct()
   │   ├─> FirestoreService.deleteProduct()
   │   └─> Remove from Firestore
   ├─> Remove from local product list
   ├─> Success message: "Product deleted"
   └─> Product no longer visible to users

4. MANAGE INVENTORY
   ├─> Admin monitors stock levels
   ├─> Low stock alert (can be implemented)
   ├─> Admin updates product quantity:
   │   ├─> Edit product
   │   ├─> Update quantity field
   │   └─> Save changes
   └─> Stock levels updated in real-time
```

---

## 7. Key Services

### 7.1 FirestoreService

**File**: `lib/services/firestore_service.dart`

**Purpose**: Central service for all Firebase Firestore operations

**Key Responsibilities**:
- Product CRUD operations
- Order management
- Address management
- Payment method management
- Review management
- Support ticket operations

**Major Methods**:

#### Product Operations:
```dart
Future<List<Product>> getProducts()
Future<String?> addProduct(Product product)
Future<bool> updateProduct(String productId, Map<String, dynamic> updates)
Future<bool> deleteProduct(String productId)
Future<bool> toggleFavorite(String productId, bool isFavorite)
Future<List<Product>> getProductsByCategory(String category)
Future<List<Product>> getFavoriteProducts()
Stream<List<Product>> getProductsStream()  // Real-time updates
Future<bool> incrementProductSoldCount(String productId, int quantity)
```

#### Order Operations:
```dart
Future<String?> saveOrder(Order order)
Future<List<Order>> getUserOrders(String userId)
Future<List<Order>> getAllOrders()  // Admin only
Future<Order?> getOrderById(String orderId)
Future<bool> updateOrderStatus(String orderId, Map<String, dynamic> updates)
```

#### Address Operations:
```dart
Future<String?> addAddress(Address address)
Future<List<Address>> getUserAddresses(String userId)
Future<bool> updateAddress(String addressId, Map<String, dynamic> updates)
Future<bool> deleteAddress(String addressId)
Future<bool> setDefaultAddress(String userId, String addressId)
```

#### Review Operations:
```dart
Future<String?> addReview(Review review)
Future<List<Review>> getProductReviews(String productId)
Future<bool> canUserReview(String userId, String productId)
Future<bool> updateProductRating(String productId)
```

#### Support Ticket Operations:
```dart
Future<String?> createSupportTicket(SupportTicket ticket)
Future<List<SupportTicket>> getUserTickets(String userId)
Future<List<SupportTicket>> getAllSupportTickets()
Future<bool> replyToTicket(String ticketId, TicketReply reply)
Future<bool> updateTicketStatus(String ticketId, String status)
```

**Collections Used**:
- `products`
- `orders`
- `addresses`
- `payment_methods`
- `reviews`
- `support_tickets`
- `users`

---

### 7.2 AuthService

**File**: `lib/services/auth_service.dart`

**Purpose**: Handles all authentication operations

**Key Methods**:
```dart
// Authentication
Future<UserCredential?> signInWithGoogle()
Future<UserCredential?> signInWithEmailPassword(String email, String password)
Future<UserCredential?> registerWithEmailPassword(String email, String password)
Future<void> sendPasswordResetEmail(String email)
Future<void> sendEmailVerification()
Future<void> signOut()

// User Data
Future<void> _saveUserToFirestore(User user)
Future<Map<String, dynamic>?> getUserProfile()
Future<void> updateProfileImage(String imageUrl)
Future<void> updateCoverImage(String imageUrl)

// State
User? get currentUser
bool get isLoggedIn
Stream<User?> get authStateChanges
```

**Firebase Integration**:
- Firebase Authentication for user management
- Google Sign-In for OAuth
- Email/Password authentication
- Email verification
- Password reset

---

### 7.3 LocalStorageService

**File**: `lib/services/local_storage_service.dart`

**Purpose**: Local data persistence using SharedPreferences

**Storage Keys**:
- `turf_products` - Cached product list
- `turf_favorites` - Favorited product IDs
- `turf_cart` - Shopping cart items
- `turf_data_initialized` - First-run flag

**Key Methods**:
```dart
// Products
Future<void> saveProducts(List<Product> products)
Future<List<Product>> getProducts()

// Cart
Future<void> saveCartItems(List<CartItem> cartItems)
Future<List<CartItem>> getCartItems()

// Favorites
Future<void> toggleFavorite(String productId, bool isFavorite)

// Initialization
Future<void> onInit()
```

**Offline Functionality**:
- Products cached for offline viewing
- Cart persists across app restarts
- Favorites synced with Firestore when online

---

### 7.4 FCMNotificationService

**File**: `lib/services/fcm_notification_service.dart`

**Purpose**: Push notification management

**Features**:
- Firebase Cloud Messaging integration
- Local notification display
- Background message handling
- Notification routing

**Key Methods**:
```dart
Future<void> initialize()
Future<void> requestPermission()
Future<String?> getToken()
Future<void> saveFCMTokenForUser(String userId)
Future<void> sendOrderNotificationToAdmin(Order order)
Future<void> sendOrderStatusUpdateNotification(String userId, Order order)
```

**Notification Channels**:
- Channel ID: `turf_app_notifications`
- Importance: High
- Sound & Vibration: Enabled

**Notification Types**:
1. New order (to admin)
2. Order status update (to user)
3. Support ticket reply (to user/admin)

---

### 7.5 GeminiChatService

**File**: `lib/services/gemini_chat_service.dart`

**Purpose**: AI chatbot using Google Generative AI (Gemini)

**Configuration**:
- Model: gemini-1.5-flash
- Temperature: 0.7 (balanced creativity)
- Max tokens: Configurable

**Key Methods**:
```dart
Future<void> initialize()
Future<String> sendMessage(String userMessage, List<Product> products)
Stream<String> sendMessageStream(String userMessage)  // Real-time streaming
```

**System Prompt**:
```
You are Turf-Mate Assistant, a helpful chatbot for a football 
products e-commerce app called Turf-Mate.

Your role:
- Help users find products (jerseys, shoes, accessories)
- Assist with orders and deliveries
- Guide through app features
- Answer product questions

Stay on topic - only discuss TurfMate products and services.
```

**Context Awareness**:
- Receives current product catalog in each request
- Can recommend products based on user query
- Maintains conversation history (locally)

---

### 7.6 ImageUploadService

**File**: `lib/services/image_upload_service.dart`

**Purpose**: Image handling and upload

**Features**:
- Image picking from camera/gallery
- Image compression
- Upload to Firebase Storage or Cloudinary

**Key Methods**:
```dart
Future<String?> pickAndUploadImage()
Future<String?> uploadImage(File imageFile)
Future<Uint8List?> compressImage(Uint8List imageBytes)
```

---

### 7.7 CloudinaryService

**File**: `lib/services/cloudinary_service.dart`

**Purpose**: Cloudinary image CDN integration

**Features**:
- Upload images to Cloudinary
- Automatic image optimization
- CDN delivery for fast loading

**Configuration**:
- Cloud name: Configured in service
- Upload preset: Public or authenticated
- Folder: `turf_app/products`

---

## 8. Security & Authentication

### 8.1 Authentication Methods

1. **Email/Password**:
   - Firebase Authentication
   - Email verification required
   - Password reset via email
   - Admin bypass: `admin@turfmate.com`

2. **Google Sign-In**:
   - OAuth 2.0 flow
   - One-tap sign-in
   - Auto-creates user profile

### 8.2 Security Considerations

**Current Implementation (Development/Testing)**:

✅ **Implemented**:
- Firebase Authentication for user management
- Email verification requirement
- Secure password storage (Firebase handles)
- FCM token management
- User session management

⚠️ **Security Gaps** (Must fix for production):

1. **Admin Access Control**:
   - Currently hardcoded email check: `admin@turfmate.com`
   - **Fix**: Implement Firebase Custom Claims for role-based access
   ```dart
   // Firebase Admin SDK (backend)
   admin.auth().setCustomUserClaims(uid, { admin: true });
   ```

2. **Payment Data Storage**:
   - Payment methods stored in Firestore
   - Card CVV should NEVER be stored
   - **Fix**: Use payment gateway tokens (Stripe, Razorpay)
   - Implement PCI DSS compliance

3. **Firestore Security Rules**:
   - Must implement proper security rules
   - Example rules needed:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Products: Read all, write admin only
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
                      request.auth.token.admin == true;
       }
       
       // Orders: Users can read own, admins read all
       match /orders/{orderId} {
         allow read: if request.auth != null && 
                      (resource.data.userId == request.auth.uid ||
                       request.auth.token.admin == true);
         allow create: if request.auth != null;
         allow update: if request.auth.token.admin == true;
       }
       
       // Addresses: Users can CRUD own only
       match /addresses/{addressId} {
         allow read, write: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
       }
       
       // Similar rules for payment_methods, reviews, support_tickets
     }
   }
   ```

4. **API Keys**:
   - Firebase config in `firebase_options.dart`
   - Gemini API key (should be in environment variables)
   - **Fix**: Use environment variables or Firebase Remote Config

5. **Data Validation**:
   - Input validation in UI
   - **Fix**: Add server-side validation in Cloud Functions

6. **Image Upload Security**:
   - Anyone can upload images currently
   - **Fix**: Verify user authentication before upload
   - Implement file size and type restrictions

### 8.3 Recommended Security Enhancements

**Priority 1 (Critical)**:
1. Implement Firestore Security Rules
2. Remove credit card CVV storage
3. Add role-based access control (admin claims)
4. Secure API keys with environment variables

**Priority 2 (High)**:
5. Implement rate limiting for API calls
6. Add input sanitization to prevent XSS
7. Implement CAPTCHA for registration
8. Add two-factor authentication option

**Priority 3 (Medium)**:
9. Implement audit logging for admin actions
10. Add data encryption at rest (sensitive fields)
11. Implement session timeout
12. Add account lockout after failed attempts

---

## 9. Deployment Configuration

### 9.1 Firebase Configuration

**File**: `lib/firebase_options.dart`

Generated using FlutterFire CLI:
```bash
flutterfire configure
```

Contains platform-specific Firebase configuration for:
- Android
- iOS
- Web
- Windows
- macOS
- Linux

### 9.2 Android Configuration

**Files**:
- `android/app/build.gradle.kts`
- `android/app/google-services.json`

**Key Settings**:
```kotlin
applicationId = "com.yourdomain.turf_app"
minSdk = 23
targetSdk = 34
versionName = "1.0.0"
```

**Permissions** (AndroidManifest.xml):
- INTERNET
- CAMERA
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- POST_NOTIFICATIONS

### 9.3 iOS Configuration

**Files**:
- `ios/Runner/Info.plist`
- `ios/Runner/GoogleService-Info.plist`

**Key Settings**:
- Bundle Identifier
- Camera usage description
- Photo library usage description
- Minimum iOS version: 12.0

### 9.4 Assets & Icons

**App Icon**:
- Path: `assets/icon.png`
- Configured in `pubspec.yaml`
- Uses `flutter_launcher_icons` package

**Brand Assets**:
- Path: `assets/brands/`
- Team logos and brand images

### 9.5 Cloud Functions (Optional)

**Directory**: `cloud_functions/` and `functions/`

**Purpose**:
- Server-side order processing
- Scheduled product updates
- Admin notification triggers
- Automated email sending

**Files**:
- `functions/index.js` - Cloud Function definitions
- `functions/package.json` - Node.js dependencies

**Example Functions**:
```javascript
// Send email when order is placed
exports.sendOrderEmail = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    // Send email logic
  });
```

### 9.6 Firebase Services Setup

**Required Firebase Services**:
1. ✅ **Authentication**
   - Email/Password provider enabled
   - Google provider enabled

2. ✅ **Firestore Database**
   - Collections created: products, orders, addresses, etc.
   - Indexes configured (if needed)

3. ✅ **Cloud Storage**
   - Bucket for user uploads
   - Storage rules configured

4. ✅ **Cloud Messaging**
   - FCM enabled
   - Server key configured

5. ⚠️ **Security Rules** (needs implementation)

**Setup Documentation**:
- `GOOGLE_SIGNIN_SETUP.md`
- `CLOUD_FUNCTION_SETUP.md`
- `FIRESTORE_INDEX_SETUP.md`
- `EMAIL_PASSWORD_SETUP_FIX.md`

### 9.7 Environment Configuration

**Development**:
```bash
flutter run
```

**Production Build**:

**Android**:
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**:
```bash
flutter build ios --release
```

**Web**:
```bash
flutter build web --release
```

### 9.8 Dependencies Installation

```bash
# Get all dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons:main

# Clean build
flutter clean
flutter pub get
flutter run
```

---

## 10. Summary & Recommendations

### Project Strengths

✅ **Well-Structured Architecture**:
- Clear separation of concerns
- Service-based architecture
- Reusable components

✅ **Comprehensive Features**:
- Complete e-commerce functionality
- Admin panel for management
- AI chatbot integration
- Push notifications
- Offline support

✅ **Modern Tech Stack**:
- Flutter 3.10.0
- GetX state management
- Firebase backend
- Latest dependencies

✅ **User Experience**:
- Intuitive navigation
- Real-time updates
- Responsive UI
- Material Design

### Areas for Improvement

🔴 **Critical**:
1. Implement Firestore Security Rules
2. Remove sensitive payment data storage
3. Add role-based access control
4. Secure API keys

🟡 **High Priority**:
5. Integrate actual payment gateway
6. Add comprehensive error handling
7. Implement data validation
8. Add loading states and error recovery

🟢 **Nice to Have**:
9. Add unit and widget tests
10. Implement analytics tracking
11. Add product search by image
12. Multi-language support
13. Dark mode theme
14. Order cancellation workflow
15. Customer reviews moderation

### Deployment Checklist

**Before Production Launch**:

- [ ] Implement Firestore Security Rules
- [ ] Integrate payment gateway (Stripe/Razorpay)
- [ ] Remove hardcoded admin email, use custom claims
- [ ] Secure all API keys
- [ ] Implement error tracking (Sentry/Crashlytics)
- [ ] Add analytics (Firebase Analytics/Google Analytics)
- [ ] Test on multiple devices and OS versions
- [ ] Implement data backup strategy
- [ ] Set up CI/CD pipeline
- [ ] Write privacy policy and terms of service
- [ ] Configure app store listings
- [ ] Set up customer support system
- [ ] Test payment flows thoroughly
- [ ] Implement refund processing
- [ ] Add order cancellation feature
- [ ] Test offline functionality
- [ ] Optimize image loading and caching
- [ ] Implement proper logging
- [ ] Set up monitoring and alerts
- [ ] Test push notifications on all platforms
- [ ] Verify email delivery (if applicable)

### Performance Optimization

**Recommendations**:
1. Implement pagination for product lists
2. Use cached network images
3. Lazy load product images
4. Optimize Firestore queries with indexes
5. Implement debouncing for search
6. Use riverpod for better state management (optional)
7. Add image compression before upload

### Scalability Considerations

**Future Enhancements**:
1. Microservices architecture for specific features
2. Elasticsearch for advanced product search
3. Redis caching for frequently accessed data
4. CDN for static assets (already using Cloudinary)
5. Load balancing for high traffic
6. Database sharding if order volume grows
7. Implement GraphQL API (optional)

---

## Appendices

### A. Route Definitions

All routes defined in `lib/app/routes/app_routes.dart`:

```dart
Routes.splash → SplashScreen
Routes.onboarding → OnboardingScreen
Routes.login → LoginScreen
Routes.register → RegisterScreen
Routes.forgotPassword → ForgotPasswordScreen
Routes.emailVerification → EmailVerificationScreen
Routes.home → MainNavigationScreen
Routes.productDetail → ProductDetailScreen
Routes.explore → ExploreScreen
Routes.cart → CartScreen
Routes.checkout → CheckoutScreen
Routes.orderSuccess → OrderSuccessScreen
Routes.profile → ProfileScreen
Routes.wishlist → WishlistScreen
Routes.notifications → NotificationsScreen
Routes.myOrders → MyOrdersScreen
Routes.addresses → AddressesScreen
Routes.addAddress → AddAddressScreen
Routes.paymentMethods → PaymentMethodsScreen
Routes.addPaymentMethod → AddPaymentMethodScreen
Routes.allProducts → AllProductsScreen
Routes.addProduct → AddProductScreen
Routes.editProduct → EditProductScreen
Routes.inventory → InventoryScreen
Routes.inventoryDetail → InventoryDetailScreen
Routes.chat → ChatScreen
Routes.myTickets → UserTicketsScreen
Routes.adminTickets → AdminTicketsScreen
Routes.ticketDetail → TicketDetailScreen
```

### B. Color Scheme

Primary colors used throughout the app:

```dart
Primary: Green[800] - #1B5E20
Accent: Orange/Amber for highlights
Success: Green[700]
Error: Red[700]
Warning: Orange[700]
Info: Blue[700]

Status Colors:
- Pending: Orange
- Confirmed: Blue
- Shipped: Purple
- Delivered: Green
- Cancelled: Red
```

### C. Firebase Collections Structure

```
Firestore Database
├── users
│   └── {userId}
│       ├── uid: String
│       ├── email: String
│       ├── displayName: String
│       ├── photoURL: String
│       └── ...
├── products
│   └── {productId}
│       ├── id: String
│       ├── name: String
│       ├── price: Number
│       └── ...
├── orders
│   └── {orderId}
│       ├── userId: String
│       ├── items: Array
│       ├── totalAmount: Number
│       └── ...
├── addresses
│   └── {addressId}
│       ├── userId: String
│       ├── addressLine1: String
│       └── ...
├── payment_methods
│   └── {paymentId}
│       ├── userId: String
│       ├── type: String
│       └── ...
├── reviews
│   └── {reviewId}
│       ├── productId: String
│       ├── userId: String
│       └── ...
└── support_tickets
    └── {ticketId}
        ├── userId: String
        ├── issue: String
        └── ...
```

---

## Conclusion

**TurfMate** is a feature-rich, well-architected e-commerce mobile application built with Flutter and Firebase. The app demonstrates solid software engineering principles with clear separation of concerns, reactive state management using GetX, and a comprehensive service layer.

The project is in a functional state suitable for demonstration and testing. However, before production deployment, critical security enhancements, payment gateway integration, and proper backend security rules must be implemented.

With the recommended improvements, TurfMate has the potential to scale into a robust, production-grade e-commerce platform for sports merchandise.

---

**Document Version**: 1.0  
**Last Updated**: February 17, 2026  
**Analyzed By**: Senior Technical Writer & Flutter Developer  
**Project**: TurfMate - Sports E-commerce App
