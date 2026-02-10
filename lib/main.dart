import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'services/firestore_service.dart';
import 'services/local_storage_service.dart';
import 'services/image_upload_service.dart';
import 'services/local_image_service.dart';
import 'services/cloudinary_service.dart';
import 'services/auth_service.dart';
import 'utils/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized or configuration error - app continues in offline mode
  }

  // Initialize services
  await Get.putAsync(() async {
    final service = LocalStorageService();
    await service.onInit();
    return service;
  });

  Get.put(FirestoreService());
  Get.put(ImageUploadService());
  Get.put(LocalImageService());
  Get.put(CloudinaryService());
  Get.put(AuthService());

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ProductController());

  runApp(TurfMateApp());
}

class TurfMateApp extends StatelessWidget {
  const TurfMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
