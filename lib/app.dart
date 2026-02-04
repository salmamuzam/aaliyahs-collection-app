import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/connectivity_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/order_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/address_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_detail_controller.dart';

import 'package:aaliyahs_collection_estore/screens/authentication/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/screens/authentication/auth_wrapper.dart';
import 'package:aaliyahs_collection_estore/util/theme/theme.dart';

class AaliyahApp extends StatelessWidget {
  const AaliyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // STEP 1: Initialize responsive design utility
    // This adapts the app to different screen sizes (phones, tablets, etc.)
    DeviceUtils().adaptDeviceScreenSize(context);
    
    // STEP 2: Setup STATE MANAGEMENT using Provider
    // MultiProvider wraps the entire app and provides access to all controllers
    // This is the "brain" of the app - it manages all data and state
    return MultiProvider(
      providers: [
        // Each ChangeNotifierProvider creates a controller that can notify the UI when data changes
        // Think of these as different departments in a store:
        
        ChangeNotifierProvider(create: (_) => CartController()),           // Manages shopping cart items
        ChangeNotifierProvider(create: (_) => FavoriteController()),       // Manages wishlist/favorites
        ChangeNotifierProvider(create: (_) => AuthController()),           // Manages login/logout
        ChangeNotifierProvider(create: (_) => UserController()),           // Manages user profile data
        ChangeNotifierProvider(create: (_) => ProductController()),        // Manages product listings and filters
        ChangeNotifierProvider(create: (_) => ConnectivityController()),   // Monitors internet connection
        ChangeNotifierProvider(create: (_) => NotificationController()),   // Manages app notifications
        ChangeNotifierProvider(create: (_) => OrderController()),          // Manages order history
        ChangeNotifierProvider(create: (_) => AddressController()),        // Manages shipping addresses
        ChangeNotifierProvider(create: (_) => ProductDetailController()),  // Manages individual product details
        
        // WHY 10 CONTROLLERS? Each handles a specific responsibility (separation of concerns)
        // This makes the code organized, maintainable, and easy to test
      ],
      
      // STEP 3: Setup RESPONSIVE DESIGN
      // ScreenUtilInit makes the app look good on all screen sizes
      child: ScreenUtilInit(
        designSize: const Size(360, 690),  // Base design size (standard phone)
        minTextAdapt: true,                // Ensures text is readable on all devices
        splitScreenMode: true,             // Supports split-screen multitasking
        builder: (context, child) {
          // STEP 4: Wrap with ToastificationWrapper for notifications
          return ToastificationWrapper(
            child: MaterialApp(
              title: 'Aaliyah\'s Collection',
              debugShowCheckedModeBanner: false,  // Removes debug banner
              
              // STEP 5: INTERNATIONALIZATION - Support multiple languages
              // This makes the app accessible to users worldwide
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,   // Material widgets in different languages
                GlobalWidgetsLocalizations.delegate,    // Basic widgets in different languages
                GlobalCupertinoLocalizations.delegate,  // iOS-style widgets in different languages
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('ar'), // Arabic (supports right-to-left text)
                Locale('es'), // Spanish
                Locale('fr'), // French
              ],
              
              // STEP 6: THEME SETUP - Light and Dark Mode
              // ThemeMode.system means the app automatically switches based on device settings
              themeMode: ThemeMode.system,
              
              // Light theme - used when device is in light mode
              theme: AaliyahAppTheme.lightTheme.copyWith(
                textTheme: GoogleFonts.poppinsTextTheme(AaliyahAppTheme.lightTheme.textTheme),
              ),
              
              // Dark theme - used when device is in dark mode
              // Uses lighter colors for better contrast on dark backgrounds
              darkTheme: AaliyahAppTheme.darkTheme.copyWith(
                textTheme: GoogleFonts.poppinsTextTheme(AaliyahAppTheme.darkTheme.textTheme),
              ),
              
              builder: (context, child) {
                return child!;
              },
              
              // STEP 7: NAVIGATION SETUP - Define app routes
              initialRoute: '/',  // App starts at AuthWrapper (checks if user is logged in)
              routes: {
                '/': (context) => const AuthWrapper(),        // Decides: show login or home
                '/login': (context) => const LoginScreen(),   // Login page
                '/signup': (context) => const SignupScreen(), // Registration page
                '/home': (context) => const NavigationMenu(), // Main app (after login)
              },
            ),
          );
        },
      ),
    );
  }
}
