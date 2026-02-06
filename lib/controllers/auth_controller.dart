import 'package:get/get.dart';
import '../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  void login(String email, String password) async {
    isLoading.value = true;

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    // Simple validation for demo
    if (email.isNotEmpty && password.length >= 6) {
      isLoggedIn.value = true;
      userEmail.value = email;
      userName.value = email.split('@')[0]; // Extract name from email
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Success', 'Login successful!');
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }

    isLoading.value = false;
  }

  void register(String name, String email, String password) async {
    isLoading.value = true;

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    // Simple validation for demo
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      userName.value = name;
      userEmail.value = email;
      isLoggedIn.value = true;
      Get.offAllNamed(Routes.HOME);
      Get.snackbar('Success', 'Registration successful!');
    } else {
      Get.snackbar('Error', 'Please fill all fields correctly');
    }

    isLoading.value = false;
  }

  void logout() {
    isLoggedIn.value = false;
    userName.value = '';
    userEmail.value = '';
    Get.offAllNamed(Routes.LOGIN);
  }

  void forgotPassword(String email) async {
    isLoading.value = true;

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));

    Get.snackbar('Success', 'Password reset link sent to your email');
    isLoading.value = false;
  }
}
