import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/app_strings.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isEmailLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
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
      isGoogleLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        Get.offAllNamed(Routes.home);
        Get.snackbar(
          'Success',
          'Welcome ${userCredential.user?.displayName ?? 'User'}!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.failedToSignInWithGoogle}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void login(String email, String password) async {
    // Validate email and password
    if (email.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.pleaseEnterEmail);
      return;
    }

    if (password.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.pleaseEnterPassword);
      return;
    }

    isEmailLoading.value = true;

    try {
      final userCredential = await _authService.signInWithEmailPassword(
        email.trim(),
        password,
      );

      if (userCredential != null) {
        // Skip email verification for admin user
        if (email == 'admin@turfmate.com') {
          Get.offAllNamed(Routes.home);
          Get.snackbar(AppStrings.success, AppStrings.adminLoginSuccessful);
        } else if (userCredential.user?.emailVerified == true) {
          Get.offAllNamed(Routes.home);
          Get.snackbar(AppStrings.success, AppStrings.loginSuccessful);
        } else {
          // Email not verified, go to verification screen
          Get.offAllNamed(Routes.emailVerification);
          Get.snackbar(
            AppStrings.emailNotVerified,
            AppStrings.pleaseVerifyEmail,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        }
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
        case 'invalid-credential':
          errorMessage = 'Invalid email or password';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred';
      }

      Get.snackbar(AppStrings.error, errorMessage);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.failedToLogin}: ${e.toString()}',
      );
    } finally {
      isEmailLoading.value = false;
    }
  }

  void register(String name, String email, String password) async {
    // Validate name, email and password
    if (name.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.pleaseEnterName);
      return;
    }

    if (email.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.pleaseEnterEmail);
      return;
    }

    if (password.trim().isEmpty) {
      Get.snackbar(AppStrings.error, AppStrings.pleaseEnterPassword);
      return;
    }

    isLoading.value = true;

    try {
      final userCredential = await _authService.registerWithEmailPassword(
        email.trim(),
        password,
        name.trim(),
      );

      if (userCredential != null) {
        // Skip email verification for admin user
        if (email == 'admin@turfmate.com') {
          Get.offAllNamed(Routes.home);
          Get.snackbar(
            'Success',
            'Admin account created successfully!',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        } else {
          // Navigate to email verification screen
          Get.offAllNamed(Routes.emailVerification);
          Get.snackbar(
            'Success',
            'Account created! Please verify your email.',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        }
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

      Get.snackbar(AppStrings.error, errorMessage);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.failedToRegister}: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check email verification
  Future<bool> checkEmailVerification() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      if (isVerified) {
        await _authService.updateEmailVerificationStatus();
      }
      return isVerified;
    } catch (e) {
      return false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      Get.snackbar(AppStrings.error, AppStrings.failedToSendVerificationEmail);
    }
  }

  void logout() async {
    isLoading.value = true;

    try {
      // Clear SharedPreferences (profile images, etc.)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_url');
      await prefs.remove('cover_image_url');

      await _authService.signOut();
      Get.offAllNamed(Routes.login);
      Get.snackbar(AppStrings.success, AppStrings.loggedOutSuccessfully);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.failedToLogout}: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword(String email) async {
    isLoading.value = true;

    try {
      await _authService.resetPassword(email);
      Get.snackbar(AppStrings.success, AppStrings.passwordResetLinkSent);
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

      Get.snackbar(AppStrings.error, errorMessage);
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.failedToSendResetEmail}: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
