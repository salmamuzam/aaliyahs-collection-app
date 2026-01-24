import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:aaliyahs_collection_estore/provider/connectivity_provider.dart';
import 'package:aaliyahs_collection_estore/provider/notification_provider.dart';
import 'package:aaliyahs_collection_estore/provider/order_provider.dart';
import 'package:aaliyahs_collection_estore/provider/address_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/no_internet_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:aaliyahs_collection_estore/services/notification_service.dart';

// Fathima Salma Muzammil - CB009970 (COM2461 Batch)
// MAD1 Assignment Task 2 (Code Submission)

// This is the main file, my app runs from here
// It's basically the starting point
// I have defined poppins from google fonts here instead of putting in asset folders because it's easier.
// Google font package can be seen in pubspec.yaml file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
  } catch (e) {
     debugPrint("Firebase Error: $e");
  }

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  await NotificationService.initialize();

  // EXCEPTIONAL: Custom Error Handling for non-crash loop in release
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 16),
            const Text(
              "Something went wrong!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(details.exception.toString(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  };

  runApp(const AaliyahApp());
}

class AaliyahApp extends StatelessWidget {
  const AaliyahApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    // Providers, I have used a state management library because it is easier
    // Providers: Using Provider Pattern for scalable state management.
    // Each feature has its own provider (Separation of Concerns).
    // This allows UI components to reactively listen to state changes (Reactive UI).
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()), // manage Cart state
      ChangeNotifierProvider(create: (_) => FavoriteProvider()), // manage Wishlist
      ChangeNotifierProvider(create: (_) => AuthProvider()), // manage Authentication
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => AddressProvider()),
    ],

    child: ToastificationWrapper(
      child: MaterialApp(
        title: 'Aaliyah\'s Collection',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Listen to connectivity changes globally
          final isConnected = Provider.of<ConnectivityProvider>(context).isConnected;
          if (!isConnected) {
            return const NoInternetScreen();
          }
          return child!;
        },

        // Light Theme
        themeMode: ThemeMode.system,
        theme: AaliyahAppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(
            AaliyahAppTheme.lightTheme.textTheme,
          ),
        ),

        // Dark Theme
        darkTheme: AaliyahAppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(
            AaliyahAppTheme.darkTheme.textTheme,
          ),
        ),
        // The app starts from the welcome screen
        home: const WelcomeScreen(),
      ),
    ),
  );
}
