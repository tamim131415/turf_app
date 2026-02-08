import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhotoURL = ''.obs;
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        isLoggedIn.value = true;
        userEmail.value = user.email ?? '';
        userName.value = user.displayName ?? user.email?.split('@')[0] ?? '';
        userPhotoURL.value = user.photoURL ?? '';
      } else {
        isLoggedIn.value = false;
        userEmail.value = '';
        userName.value = '';
        userPhotoURL.value = '';
      }
    });
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        Get.offAllNamed(Routes.HOME);
        Get.snackbar(
          'Success',
          'Welcome ${userCredential.user?.displayName ?? 'User'}!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void login(String email, String password) async {
    isLoading.value = true;

    try {
      final userCredential = await _authService.signInWithEmailPassword(
        email,
        password,
      );

      if (userCredential != null) {
        Get.offAllNamed(Routes.HOME);
        Get.snackbar('Success', 'Login successful!');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to login: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void register(String name, String email, String password) async {
    isLoading.value = true;

    try {
      final userCredential = await _authService.registerWithEmailPassword(
        email,
        password,
        name,
      );

      if (userCredential != null) {
        Get.offAllNamed(Routes.HOME);
        Get.snackbar('Success', 'Registration successful!');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to register: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    isLoading.value = true;

    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword(String email) async {
    isLoading.value = true;

    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Password reset link sent to your email');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
