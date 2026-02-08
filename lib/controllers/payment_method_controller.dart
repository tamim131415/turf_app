import 'package:get/get.dart';
import '../models/payment_method.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class PaymentMethodController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<PaymentMethod> paymentMethods = <PaymentMethod>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final methods = await _firestoreService.getUserPaymentMethods(userId);
        paymentMethods.value = methods;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // If this is set as default, unset other defaults
      if (paymentMethod.isDefault) {
        for (var method in paymentMethods) {
          if (method.isDefault) {
            await _firestoreService.updatePaymentMethod(method.id, {
              'isDefault': false,
            });
          }
        }
      }

      await _firestoreService.savePaymentMethod(paymentMethod);
      await loadPaymentMethods();
      Get.back();
      Get.snackbar('Success', 'Payment method added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePaymentMethod(PaymentMethod paymentMethod) async {
    try {
      isLoading.value = true;

      // If this is set as default, unset other defaults
      if (paymentMethod.isDefault) {
        for (var method in paymentMethods) {
          if (method.id != paymentMethod.id && method.isDefault) {
            await _firestoreService.updatePaymentMethod(method.id, {
              'isDefault': false,
            });
          }
        }
      }

      await _firestoreService.updatePaymentMethod(
        paymentMethod.id,
        paymentMethod.toMap(),
      );
      await loadPaymentMethods();
      Get.back();
      Get.snackbar('Success', 'Payment method updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePaymentMethod(String id) async {
    try {
      isLoading.value = true;
      await _firestoreService.deletePaymentMethod(id);
      await loadPaymentMethods();
      Get.snackbar('Success', 'Payment method deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    try {
      isLoading.value = true;

      // Unset all other defaults
      for (var method in paymentMethods) {
        if (method.isDefault) {
          await _firestoreService.updatePaymentMethod(method.id, {
            'isDefault': false,
          });
        }
      }

      // Set this one as default
      await _firestoreService.updatePaymentMethod(id, {'isDefault': true});

      await loadPaymentMethods();
      Get.snackbar('Success', 'Default payment method updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to set default payment method: $e');
    } finally {
      isLoading.value = false;
    }
  }

  PaymentMethod? get defaultPaymentMethod {
    final defaultMethods = paymentMethods
        .where((method) => method.isDefault)
        .toList();
    if (defaultMethods.isNotEmpty) {
      return defaultMethods.first;
    }
    return paymentMethods.isNotEmpty ? paymentMethods.first : null;
  }
}
