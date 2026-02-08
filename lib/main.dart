import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:aaliyahs_collection_estore/utils/config/firebase_options.dart';
import 'package:aaliyahs_collection_estore/data/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/data/services/image_cache_service.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/performance_monitor.dart';
import 'package:aaliyahs_collection_estore/app.dart';

Future<void> main() async {
  // LAYER 1: Framework Error Catching
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Future: Add Firebase Crashlytics here
    debugPrint('🔴 FRAMEWORK ERROR: ${details.exception}');
  };

  // LAYER 2: Asynchronous error catching (Platform/Native/Async)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('🔴 ASYNC ERROR: $error');
    return true; // Error has been handled
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe initialization
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('⚠️ Warning: .env file missing or corrupted. Falling back to defaults.');
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('❌ Firebase Initialization Failed: $e');
  }

  try {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  } catch (e) {
    debugPrint('⚠️ Stripe key not found in .env');
  }

  await NotificationService.initialize();



  // Initialize optimized image caching
  ImageCacheService().initialize();

  // Initialize performance monitoring (debug mode only)
  if (kDebugMode) {
    PerformanceMonitor().initialize();
    debugPrint('🚀 Performance monitoring enabled');
/*
  } else {
    debugPrint('📈 Firebase Performance Monitoring Active');
  }
*/
  }

  // Enforce Edge-to-Edge (Modern Android Requirement)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  if (kDebugMode) {
    // debugInvertOversizedImages = true; // Disabled: This caused images to flip and change color
  }

  runApp(const AaliyahApp());
}
