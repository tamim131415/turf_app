# TurfMate Project - Custom Widgets Documentation

## Overview
This document covers all custom-built reusable widgets created specifically for the TurfMate project. These widgets encapsulate common UI patterns and business logic for cleaner, more maintainable code.

---

## 1. ProductCard Widget

### Purpose
`ProductCard` is a reusable widget that displays product information in a card format.

### Location
`lib/widgets/product_card.dart`

### Features
- Product image display with NetworkImage
- Product name, team, and category
- Price display with currency formatting
- Favorite/wishlist toggle button
- Out of stock indicator
- Responsive sizing for different screens
- Tap navigation to product detail screen
- Add to cart functionality

### Implementation
```dart
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController productController = Get.find<ProductController>();

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.productDetail, arguments: product);
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Favorite Button
            Stack(
              children: [
                Container(
                  height: ResponsiveHelper.isMobile(context) ? 120 : 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      productController.toggleFavorite(product);
                    },
                    child: Obx(() {
                      bool isFavorite = productController.isProductFavorite(product);
                      return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      );
                    }),
                  ),
                ),
                // Out of Stock Badge
                if (product.quantity == 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            // Product Details
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.isMobile(context) ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.team,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      if (product.quantity > 0)
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          color: Colors.green[700],
                          onPressed: () {
                            productController.addToCart(product);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Why Created
- **Reusability**: Used in multiple screens (Home, Explore, All Products)
- **Consistency**: Same product display across app
- **Maintainability**: Change once, updates everywhere
- **Clean Code**: Keeps parent widgets simple

### Usage Examples
```dart
// In product grid
GridView.builder(
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)

// In search results
ListView.builder(
  itemBuilder: (context, index) {
    return ProductCard(product: searchResults[index]);
  },
)
```

---

## 2. CartItemCard Widget

### Purpose
`CartItemCard` displays individual cart items with quantity controls.

### Location
`lib/widgets/cart_item.dart`

### Features
- Product image thumbnail
- Product name and details
- Selected size display
- Quantity increment/decrement controls
- Price calculation (price × quantity)
- Remove from cart button
- Responsive layout

### Implementation
```dart
class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: ResponsiveHelper.isMobile(context) ? 80 : 100,
              height: ResponsiveHelper.isMobile(context) ? 80 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(cartItem.product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Size: ${cartItem.selectedSize}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  controller.updateCartItemQuantity(
                                    cartItem,
                                    cartItem.quantity - 1,
                                  );
                                }
                              },
                              color: Colors.grey[700],
                              iconSize: 20,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '${cartItem.quantity}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                controller.updateCartItemQuantity(
                                  cartItem,
                                  cartItem.quantity + 1,
                                );
                              },
                              color: Colors.green[700],
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        '\$${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              icon: Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () {
                controller.removeFromCart(cartItem);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### Why Created
- **Complex Layout**: Encapsulates quantity control logic
- **State Management**: Integrates with ProductController
- **Reusability**: Used in cart and checkout screens
- **User Experience**: Consistent cart item UI

---

## 3. WishlistItem Widget

### Purpose
`WishlistItem` displays products in the wishlist with quick actions.

### Location
`lib/widgets/wishlist_item.dart`

### Features
- Product image and details
- Remove from wishlist button
- Add to cart from wishlist
- Price display
- Stock status indicator

### Implementation
```dart
class WishlistItem extends StatelessWidget {
  final Product product;

  const WishlistItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.team),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Remove from wishlist
            GestureDetector(
              onTap: () {
                controller.toggleFavorite(product);
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: Colors.red, size: 20),
              ),
            ),
            // Add to cart
            GestureDetector(
              onTap: () {
                controller.addToCart(product);
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shopping_cart, color: Colors.green[700], size: 20),
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed(Routes.productDetail, arguments: product);
        },
      ),
    );
  }
}
```

### Why Created
- **Wishlist-specific**: Different from cart items
- **Quick Actions**: Easy remove and add to cart
- **Clean Code**: Separates wishlist UI logic

---

## 4. SocialLoginButton Widget

### Purpose
`SocialLoginButton` creates consistent social media login buttons.

### Location
`lib/widgets/social_login_button.dart`

### Features
- Customizable icon and text
- Brand colors support
- Loading state
- Tap handler
- Consistent styling

### Implementation
```dart
class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Usage Examples
```dart
SocialLoginButton(
  text: 'Continue with Google',
  icon: Icons.g_mobiledata,
  color: Colors.red,
  onPressed: () => authController.signInWithGoogle(),
)
```

### Why Created
- **Consistency**: Same style for all social logins
- **Reusability**: Easy to add more providers
- **Branding**: Maintains brand colors

---

## 5. Custom Status Badge Widget

### Purpose
Display order/ticket status with appropriate colors and icons.

### Features
- Color-coded status
- Icon representation
- Rounded badge design
- Consistent across app

### Implementation Pattern
```dart
Widget _buildStatusBadge(String status) {
  Color color;
  IconData icon;

  switch (status.toLowerCase()) {
    case 'pending':
      color = Colors.orange;
      icon = Icons.pending;
      break;
    case 'confirmed':
      color = Colors.blue;
      icon = Icons.check_circle;
      break;
    case 'shipped':
      color = Colors.purple;
      icon = Icons.local_shipping;
      break;
    case 'delivered':
      color = Colors.green;
      icon = Icons.done_all;
      break;
    case 'cancelled':
      color = Colors.red;
      icon = Icons.cancel;
      break;
    default:
      color = Colors.grey;
      icon = Icons.info;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
```

### Why Created
- **Visual Clarity**: Status immediately recognizable
- **Consistency**: Same design throughout app
- **User Experience**: Color-coded information

---

## 6. Empty State Widgets

### Purpose
Display friendly empty state messages with actions.

### Usage
- Empty cart
- No orders
- No notifications
- No search results

### Implementation Pattern
```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Usage Examples
```dart
// Empty cart
EmptyStateWidget(
  icon: Icons.shopping_cart_outlined,
  title: 'Your cart is empty',
  message: 'Start adding products to your cart',
  actionText: 'Start Shopping',
  onAction: () => Get.toNamed(Routes.home),
)

// No orders
EmptyStateWidget(
  icon: Icons.shopping_bag_outlined,
  title: 'No orders yet',
  message: 'You haven\'t placed any orders',
)
```

---

## 7. Responsive Helper

### Purpose
Utility class for responsive UI design across different screen sizes.

### Location
`lib/utils/responsive_helper.dart`

### Features
- Screen size detection (mobile, tablet, desktop)
- Responsive padding
- Responsive font sizes
- Grid column calculation

### Implementation
```dart
class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
           MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getPadding(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isMobile(context)) return small;
    if (isTablet(context)) return medium;
    return large;
  }

  static double getFontSize(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isMobile(context)) return small;
    if (isTablet(context)) return medium;
    return large;
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
}
```

### Usage Examples
```dart
// Responsive padding
Padding(
  padding: EdgeInsets.all(
    ResponsiveHelper.getPadding(
      context,
      small: 16,
      medium: 24,
      large: 32,
    ),
  ),
)

// Responsive grid
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveHelper.getGridColumns(context),
  ),
)
```

---

## Custom Widget Best Practices

### 1. Widget Composition
```dart
// ✅ Good - Small, focused widgets
class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildImage(),
          _buildDetails(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildImage() { /* ... */ }
  Widget _buildDetails() { /* ... */ }
  Widget _buildActions() { /* ... */ }
}
```

### 2. Parameter Naming
```dart
// ✅ Good - Clear, descriptive names
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isLoading;
  
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
  });
}
```

### 3. Documentation
```dart
/// A reusable card widget for displaying product information.
///
/// This widget shows:
/// - Product image with favorite button
/// - Product name, team, and category
/// - Price and add to cart button
/// - Out of stock indicator when applicable
///
/// Usage:
/// ```dart
/// ProductCard(product: myProduct)
/// ```
class ProductCard extends StatelessWidget {
  // ...
}
```

---

## Summary

### Custom Widgets in TurfMate
```
lib/widgets/
├── product_card.dart          (Product display)
├── cart_item.dart             (Cart item with controls)
├── wishlist_item.dart         (Wishlist display)
└── social_login_button.dart   (Social login buttons)
```

### Widget Usage Statistics
- **ProductCard**: Used in 5+ screens (most reused)
- **CartItemCard**: Cart and checkout screens
- **WishlistItem**: Wishlist screen
- **EmptyStateWidget**: 10+ empty states

### Benefits of Custom Widgets
- ✅ **Reusability**: Write once, use everywhere
- ✅ **Maintainability**: Update in one place
- ✅ **Consistency**: Same look and feel
- ✅ **Testing**: Easier to test isolated widgets
- ✅ **Readability**: Cleaner parent widgets
- ✅ **Collaboration**: Team members understand patterns

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
