import 'package:get/get.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/email_verification_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/cart/checkout_screen.dart';
import '../../screens/cart/order_success_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/wishlist/wishlist_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/orders/my_orders_screen.dart';
import '../../screens/address/addresses_screen.dart';
import '../../screens/address/add_address_screen.dart';
import '../../screens/payment/payment_methods_screen.dart';
import '../../screens/payment/add_payment_method_screen.dart';
import '../../screens/product/all_products_screen.dart';
import '../../screens/product/add_product_screen.dart';
import '../../screens/product/edit_product_screen.dart';
import '../../screens/inventory/inventory_screen.dart';
import '../../screens/inventory/inventory_detail_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/support/user_tickets_screen.dart';
import '../../screens/support/admin_tickets_screen.dart';
import '../../screens/support/ticket_detail_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.splash, page: () => SplashScreen()),
    GetPage(name: Routes.onboarding, page: () => OnboardingScreen()),
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.register, page: () => RegisterScreen()),
    GetPage(name: Routes.forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(
      name: Routes.emailVerification,
      page: () => EmailVerificationScreen(),
    ),
    GetPage(name: Routes.home, page: () => MainNavigationScreen()),
    GetPage(name: Routes.mainNavigation, page: () => MainNavigationScreen()),
    GetPage(name: Routes.productDetail, page: () => ProductDetailScreen()),
    GetPage(name: Routes.explore, page: () => ExploreScreen()),
    GetPage(name: Routes.cart, page: () => CartScreen()),
    GetPage(name: Routes.checkout, page: () => CheckoutScreen()),
    GetPage(name: Routes.orderSuccess, page: () => OrderSuccessScreen()),
    GetPage(name: Routes.profile, page: () => ProfileScreen()),
    GetPage(name: Routes.wishlist, page: () => WishlistScreen()),
    GetPage(name: Routes.notifications, page: () => NotificationsScreen()),
    GetPage(name: Routes.myOrders, page: () => const MyOrdersScreen()),
    GetPage(name: Routes.addresses, page: () => const AddressesScreen()),
    GetPage(name: Routes.addAddress, page: () => const AddAddressScreen()),
    GetPage(name: Routes.paymentMethods, page: () => PaymentMethodsScreen()),
    GetPage(
      name: Routes.addPaymentMethod,
      page: () => const AddPaymentMethodScreen(),
    ),
    GetPage(name: Routes.allProducts, page: () => const AllProductsScreen()),
    GetPage(name: Routes.addProduct, page: () => AddProductScreen()),
    GetPage(name: Routes.editProduct, page: () => const EditProductScreen()),
    GetPage(name: Routes.inventory, page: () => const InventoryScreen()),
    GetPage(
      name: Routes.inventoryDetail,
      page: () => const InventoryDetailScreen(),
    ),
    GetPage(name: Routes.chat, page: () => ChatScreen()),
    GetPage(name: Routes.myTickets, page: () => const UserTicketsScreen()),
    GetPage(name: Routes.adminTickets, page: () => const AdminTicketsScreen()),
    GetPage(
      name: Routes.ticketDetail,
      page: () => const TicketDetailScreen(ticketId: ''),
    ),
  ];
}
