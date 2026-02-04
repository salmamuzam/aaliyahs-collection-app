import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aaliyahs_collection_estore/util/config/firebase_options.dart';
import 'package:aaliyahs_collection_estore/data/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await NotificationService.initialize();

  // Enforce Edge-to-Edge (Modern Android Requirement)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Default for light theme
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  if (kDebugMode) {
    // debugInvertOversizedImages = true; // Disabled: This caused images to flip and change color
  }

  runApp(const AaliyahApp());
}
