# TurfMate Project - Input & Form Widgets Documentation

## Overview
This document covers all input and form-related widgets used in the TurfMate project. These widgets handle user input, data collection, and form validation.

---

## 1. TextField Widget

### Purpose
`TextField` is the primary widget for text input in Flutter.

### Usage in TurfMate
- **Search Functionality**: Product search in home and explore screens
- **Chat Messages**: User messages in chatbot
- **Admin Notes**: Order management notes
- **Support Tickets**: Message input in support system

### Key Features Used
```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search products...',
    prefixIcon: Icon(Icons.search, color: Colors.grey),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => _searchController.clear(),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
  onChanged: (value) {
    // Search logic
  },
)
```

### Why Used
- Real-time search functionality
- Simple text input without form validation
- Chat and messaging features
- Quick note-taking interfaces

### Examples in Project
- `lib/screens/home/home_screen.dart` - Product search bar
- `lib/screens/chat/chat_screen.dart` - Chat message input
- `lib/screens/inventory/admin_orders_screen.dart` - Search orders, add notes
- `lib/screens/inventory/order_detail_screen.dart` - Tracking number input
- `lib/screens/support/help_support_screen.dart` - Ticket description

---

## 2. TextFormField Widget

### Purpose
`TextFormField` extends TextField with built-in form validation support.

### Usage in TurfMate
- **Login/Register**: Email and password fields
- **Address Forms**: Shipping address collection
- **Payment Forms**: Card details input
- **Profile Editing**: User information updates

### Key Features Used
```dart
TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: AppStrings.email,
    prefixIcon: Icon(Icons.email, color: Colors.green[700]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  },
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

### Why Used
- Built-in validation support
- Form state management
- Professional error handling
- User-friendly feedback

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Email & password
- `lib/screens/auth/register_screen.dart` - Registration form
- `lib/screens/address/add_address_screen.dart` - Address fields
- `lib/screens/payment/add_card_screen.dart` - Card information
- Used in **all** forms with validation requirements

---

## 3. TextEditingController

### Purpose
`TextEditingController` manages the state and content of text fields.

### Usage in TurfMate
- **Value Access**: Reading input values
- **Programmatic Changes**: Setting text programmatically
- **Clearing Input**: Reset fields after submission
- **Initial Values**: Pre-filling forms

### Key Features Used
```dart
class MyFormState extends State<MyForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial value
    _emailController.text = 'user@example.com';
    
    // Listen to changes
    _emailController.addListener(() {
      print('Email: ${_emailController.text}');
    });
  }

  @override
  void dispose() {
    // Always dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submitForm() {
    final email = _emailController.text;
    // Use the value
  }
}
```

### Why Used
- Required for TextField/TextFormField
- Programmatic control of input
- Listen to text changes
- Memory management

### Examples in Project
- Declared in **every** screen with text input
- `lib/screens/auth/login_screen.dart` - Email/password controllers
- `lib/screens/home/home_screen.dart` - Search controller
- `lib/screens/address/add_address_screen.dart` - 7 controllers for address fields
- `lib/screens/chat/chat_screen.dart` - Message controller

---

## 4. ElevatedButton Widget

### Purpose
`ElevatedButton` creates material design raised buttons with elevation.

### Usage in TurfMate
- **Primary Actions**: Login, Register, Checkout
- **Form Submission**: Submit buttons for forms
- **Important Actions**: Add to Cart, Place Order
- **Call to Action**: Get Started, Buy Now

### Key Features Used
```dart
ElevatedButton(
  onPressed: () {
    // Action
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700],
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 5,
  ),
  child: Text(
    'Login',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
)

// With icon
ElevatedButton.icon(
  onPressed: () {},
  icon: Icon(Icons.shopping_cart),
  label: Text('Add to Cart'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700],
  ),
)
```

### Why Used
- Clear visual hierarchy
- Primary action indication
- Material Design compliance
- Accessible and recognizable

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Login button
- `lib/screens/auth/register_screen.dart` - Register button
- `lib/screens/onboarding/onboarding_screen.dart` - Get Started
- `lib/widgets/product_card.dart` - Add to Cart
- `lib/screens/cart/cart_screen.dart` - Checkout button
- Used in **40+** locations

---

## 5. TextButton Widget

### Purpose
`TextButton` creates flat text buttons without elevation.

### Usage in TurfMate
- **Secondary Actions**: Cancel, Skip, Back
- **Link-style Actions**: Forgot Password, Terms & Conditions
- **Subtle Actions**: Mark as Read, Dismiss
- **Navigation Links**: View All, See More

### Key Features Used
```dart
TextButton(
  onPressed: () {
    Get.toNamed(Routes.forgotPassword);
  },
  child: Text(
    'Forgot Password?',
    style: TextStyle(
      color: Colors.green[700],
      fontWeight: FontWeight.w500,
    ),
  ),
)

// In AppBar
actions: [
  TextButton(
    onPressed: () {},
    child: Text(
      'Skip',
      style: TextStyle(color: Colors.grey[700]),
    ),
  ),
]
```

### Why Used
- Less prominent than ElevatedButton
- Good for secondary actions
- Link-style navigation
- Cleaner interface

### Examples in Project
- `lib/screens/onboarding/onboarding_screen.dart` - Skip button
- `lib/screens/auth/login_screen.dart` - Forgot Password
- `lib/screens/auth/register_screen.dart` - Already have account
- `lib/screens/notifications/notifications_screen.dart` - Mark all as read
- Used for **secondary actions** throughout app

---

## 6. IconButton Widget

### Purpose
`IconButton` creates clickable icon-only buttons.

### Usage in TurfMate
- **Quantity Controls**: Plus/minus for cart items
- **Toggle Actions**: Favorite heart icon
- **Quick Actions**: Delete, Edit, Share
- **Navigation**: Back buttons, menu triggers

### Key Features Used
```dart
// Quantity control
Row(
  children: [
    IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {
        controller.decrementQuantity(product);
      },
      color: Colors.grey[700],
    ),
    Text('$quantity'),
    IconButton(
      icon: Icon(Icons.add_circle_outline),
      onPressed: () {
        controller.incrementQuantity(product);
      },
      color: Colors.green[700],
    ),
  ],
)

// Favorite toggle
IconButton(
  icon: Icon(
    isFavorite ? Icons.favorite : Icons.favorite_border,
    color: isFavorite ? Colors.red : Colors.grey,
  ),
  onPressed: () {
    controller.toggleFavorite(product);
  },
)
```

### Why Used
- Space-efficient
- Clear visual feedback
- Universal icon language
- Quick interactions

### Examples in Project
- `lib/widgets/cart_item.dart` - Quantity and delete buttons
- `lib/widgets/product_card.dart` - Favorite button
- `lib/screens/product/product_detail_screen.dart` - Back and share
- `lib/screens/home/home_screen.dart` - Cart button in AppBar
- Used extensively (**100+** instances)

---

## 7. Checkbox Widget

### Purpose
`Checkbox` allows users to select/deselect boolean options.

### Usage in TurfMate
- **Remember Me**: Login screen option
- **Terms Acceptance**: Registration agreements
- **Default Selection**: Set as default address
- **Filters**: Product filtering options

### Key Features Used
```dart
CheckboxListTile(
  title: Text('Set as default address'),
  value: _isDefault,
  onChanged: (bool? value) {
    setState(() {
      _isDefault = value ?? false;
    });
  },
  activeColor: Colors.green[700],
  controlAffinity: ListTileControlAffinity.leading,
)

// Simple checkbox
Row(
  children: [
    Checkbox(
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value ?? false;
        });
      },
      activeColor: Colors.green[700],
    ),
    Text('Remember Me'),
  ],
)
```

### Why Used
- Clear yes/no choices
- Visual confirmation
- Standard UI pattern
- Easy to understand

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Remember Me option
- `lib/screens/address/add_address_screen.dart` - Default address
- `lib/screens/auth/register_screen.dart` - Terms & conditions

---

## 8. DropdownButton Widget

### Purpose
`DropdownButton` displays a dropdown menu for selecting from a list of options.

### Usage in TurfMate
- **Size Selection**: Product size options
- **Status Updates**: Order status changes
- **Sorting**: Product list sorting
- **Filtering**: Category selection

### Key Features Used
```dart
Obx(() => DropdownButton<String>(
  value: detailController.selectedSize.value,
  items: product.sizes.map((String size) {
    return DropdownMenuItem<String>(
      value: size,
      child: Text(size),
    );
  }).toList(),
  onChanged: (String? newValue) {
    if (newValue != null) {
      detailController.selectSize(newValue);
    }
  },
  underline: Container(),
  icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
))
```

### Why Used
- Space-efficient selection
- Clear options display
- Standard mobile pattern
- Good for bounded choices

### Examples in Project
- `lib/screens/product/product_detail_screen.dart` - Size selection
- `lib/screens/inventory/order_detail_screen.dart` - Status dropdown
- Admin interfaces for status changes

---

## 9. Switch Widget

### Purpose
`Switch` provides on/off toggle functionality.

### Usage in TurfMate
- **Settings**: Enable/disable features
- **Notifications**: Toggle notification preferences
- **Visibility**: Show/hide elements
- **Status Changes**: Active/Inactive states

### Key Features Used
```dart
SwitchListTile(
  title: Text('Enable Notifications'),
  subtitle: Text('Receive updates about your orders'),
  value: _notificationsEnabled,
  onChanged: (bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  },
  activeColor: Colors.green[700],
)

// Simple switch
Switch(
  value: _isDarkMode,
  onChanged: (value) {
    setState(() {
      _isDarkMode = value;
    });
  },
  activeColor: Colors.green[700],
)
```

### Why Used
- Binary state control
- Immediate visual feedback
- Familiar mobile pattern
- Clear on/off indication

### Examples in Project
- Settings screens
- Notification preferences
- Admin toggles

---

## 10. Form Widget

### Purpose
`Form` groups multiple form fields and manages their validation state.

### Usage in TurfMate
- **Login Form**: Email and password validation
- **Registration**: Multi-field validation
- **Address Form**: Complete address collection
- **Card Addition**: Payment information

### Key Features Used
```dart
class MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
          ),
          TextFormField(/* another field */),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // All fields are valid
                _formKey.currentState!.save();
                submitForm();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Why Used
- Centralized validation
- Easy form state management
- Built-in error handling
- Professional form handling

### Examples in Project
- `lib/screens/auth/login_screen.dart` - Login validation
- `lib/screens/auth/register_screen.dart` - Registration validation
- `lib/screens/address/add_address_screen.dart` - Address validation
- All forms with multiple fields

---

## 11. FilterChip Widget

### Purpose
`FilterChip` provides visual filtering options with selected/unselected states.

### Usage in TurfMate
- **Order Filters**: Filter by status (Pending, Shipped, etc.)
- **Category Filters**: Product category selection
- **Status Filters**: Support ticket statuses
- **Tag Selection**: Multiple choice filters

### Key Features Used
```dart
Wrap(
  spacing: 8,
  children: statusFilters.map((filter) {
    final isSelected = selectedFilter.value == filter;
    return FilterChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        selectedFilter.value = filter;
      },
      selectedColor: Colors.green[100],
      checkmarkColor: Colors.green[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.green[700] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }).toList(),
)
```

### Why Used
- Visual filter indication
- Multiple filter support
- Clear selected state
- Modern UI pattern

### Examples in Project
- `lib/screens/inventory/admin_orders_screen.dart` - Order status filters
- `lib/screens/support/admin_tickets_screen.dart` - Ticket filters
- Admin dashboards with filtering needs

---

## Summary

### Input Architecture in TurfMate

```
Form Flow:
1. User Input → TextField/TextFormField
2. Controller manages text state
3. Validation on submit or real-time
4. Visual feedback (errors, success)
5. Action buttons submit data
6. Loading state during processing
7. Success/error response
```

### Form Validation Patterns
```dart
// Email validation
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  if (!value.contains('@')) return 'Invalid email';
  return null;
}

// Password validation
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  if (value.length < 6) return 'Minimum 6 characters';
  return null;
}

// Phone validation
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
    return 'Invalid phone number';
  }
  return null;
}
```

### Most Used Input Widgets
1. **TextField** - 30+ instances (search, notes, messages)
2. **TextFormField** - 25+ instances (forms with validation)
3. **ElevatedButton** - 40+ instances (primary actions)
4. **IconButton** - 100+ instances (quick actions)
5. **TextButton** - 20+ instances (secondary actions)

### Input Patterns Applied
- **Search Pattern**: TextField with real-time filtering
- **Form Pattern**: Form + TextFormField + validation
- **Quantity Pattern**: IconButton + display + IconButton
- **Toggle Pattern**: Checkbox/Switch for boolean states
- **Selection Pattern**: DropdownButton for bounded choices

### Best Practices
- Always dispose TextEditingControllers
- Use Form widget for multi-field validation
- Provide clear error messages
- Show loading states during submission
- Disable buttons while processing
- Clear sensitive data after use
- Use appropriate keyboard types
- Implement proper validation rules

---

**Last Updated**: February 2026
**Project**: TurfMate - Football Jersey E-commerce App
**Framework**: Flutter 3.x with GetX
