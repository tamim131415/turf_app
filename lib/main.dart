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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // Initialize services
  await Get.putAsync(() async {
    final service = LocalStorageService();
    await service.onInit();
    return service;
  });

  Get.put(FirestoreService());

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
      title: 'Turf-Mate',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
