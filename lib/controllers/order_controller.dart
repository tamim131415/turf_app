import 'package:get/get.dart';
import '../models/order.dart' as app_models;
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/app_strings.dart';

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

      if (userId != null) {
        orders.value = await _firestoreService.getUserOrders(userId);
      } else {}
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToLoadOrders);
    } finally {
      isLoading.value = false;
    }
  }
}
