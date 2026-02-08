import 'package:get/get.dart';
import '../models/order.dart' as app_models;
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class OrderController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<app_models.Order> orders = <app_models.Order>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.uid;

      print('📱 OrderController: Loading orders for user: $userId');

      if (userId != null) {
        orders.value = await _firestoreService.getUserOrders(userId);
        print('📱 OrderController: Loaded ${orders.length} orders');
      } else {
        print('⚠️ OrderController: No user ID found');
      }
    } catch (e) {
      print('❌ OrderController: Error loading orders: $e');
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }
}
