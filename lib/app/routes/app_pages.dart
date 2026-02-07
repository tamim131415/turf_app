import 'package:get/get.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/explore/explore_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/cart/checkout_screen.dart';
import '../../screens/cart/order_success_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/wishlist/wishlist_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/product/all_products_screen.dart';
import '../../screens/product/add_product_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => SplashScreen()),
    GetPage(name: Routes.ONBOARDING, page: () => OnboardingScreen()),
    GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
    GetPage(name: Routes.REGISTER, page: () => RegisterScreen()),
    GetPage(name: Routes.FORGOT_PASSWORD, page: () => ForgotPasswordScreen()),
    GetPage(name: Routes.HOME, page: () => MainNavigationScreen()),
    GetPage(name: Routes.MAIN_NAVIGATION, page: () => MainNavigationScreen()),
    GetPage(name: Routes.PRODUCT_DETAIL, page: () => ProductDetailScreen()),
    GetPage(name: Routes.EXPLORE, page: () => ExploreScreen()),
    GetPage(name: Routes.CART, page: () => CartScreen()),
    GetPage(name: Routes.CHECKOUT, page: () => CheckoutScreen()),
    GetPage(name: Routes.ORDER_SUCCESS, page: () => OrderSuccessScreen()),
    GetPage(name: Routes.PROFILE, page: () => ProfileScreen()),
    GetPage(name: Routes.WISHLIST, page: () => WishlistScreen()),
    GetPage(name: Routes.NOTIFICATIONS, page: () => NotificationsScreen()),
    GetPage(name: Routes.ALL_PRODUCTS, page: () => const AllProductsScreen()),
    GetPage(name: Routes.ADD_PRODUCT, page: () => AddProductScreen()),
  ];
}
