import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aaliyahs_collection_estore/routes/app_routes.dart';
import 'package:aaliyahs_collection_estore/routes/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';
import 'package:dynamic_color/dynamic_color.dart';


import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/features/authentication/controllers/auth_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/utils/device/connectivity_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/order_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/address_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_detail_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/checkout_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/errors/global_error_widget.dart';

import 'package:aaliyahs_collection_estore/utils/theme/theme.dart';

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
        ChangeNotifierProvider(create: (_) => AccessibilityController()),  // Manages accessibility preferences
        ChangeNotifierProvider(create: (_) => NavigationController()),    // Manages global navigation state
        ChangeNotifierProvider(create: (_) => CheckoutController()),       // Manages multi-step checkout
      ],
      
      // WHY 10 CONTROLLERS? Each handles a specific responsibility (separation of concerns)
      // This makes the code organized, maintainable, and easy to test
      
      // STEP 3: Setup RESPONSIVE DESIGN
      // ScreenUtilInit makes the app look good on all screen sizes
      child: ScreenUtilInit(
        minTextAdapt: true,                // Ensures text is readable on all devices
        splitScreenMode: true,             // Supports split-screen multitasking
        builder: (context, child) {
          return ToastificationWrapper(
            child: Consumer<AccessibilityController>(
              builder: (context, accessController, _) {
                return DynamicColorBuilder(
                  builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                
                // Determine valid schemes (System Dynamic vs App Default)
                ColorScheme lightScheme;
                ColorScheme darkScheme;

                if (lightDynamic != null && !accessController.highContrast) {
                  lightScheme = lightDynamic.harmonized();
                } else {
                  lightScheme = AaliyahAppTheme.lightTheme.colorScheme;
                }

                if (darkDynamic != null && !accessController.highContrast) {
                  darkScheme = darkDynamic.harmonized();
                } else {
                  darkScheme = AaliyahAppTheme.darkTheme.colorScheme;
                }

                // Create Theme Data
                ThemeData lightTheme = (lightDynamic != null && !accessController.highContrast)
                    ? AaliyahAppTheme.createTheme(lightScheme, Brightness.light)
                    : (accessController.highContrast 
                        ? AaliyahAppTheme.highContrastLightTheme 
                        : AaliyahAppTheme.lightTheme);

                ThemeData darkTheme = (darkDynamic != null && !accessController.highContrast)
                    ? AaliyahAppTheme.createTheme(darkScheme, Brightness.dark)
                    : (accessController.highContrast 
                        ? AaliyahAppTheme.highContrastDarkTheme 
                        : AaliyahAppTheme.darkTheme);

                // Apply M3 Motion Physics: Page Transitions
                const m3PageTransitions = PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                );

                lightTheme = lightTheme.copyWith(pageTransitionsTheme: m3PageTransitions);
                darkTheme = darkTheme.copyWith(pageTransitionsTheme: m3PageTransitions);

                // Apply Font Scaling & Style
                // We use base theme text theme as a reference for text scaling
                // lightTheme = lightTheme.copyWith(textTheme: GoogleFonts.poppinsTextTheme(lightTheme.textTheme));
                // darkTheme = darkTheme.copyWith(textTheme: GoogleFonts.poppinsTextTheme(darkTheme.textTheme));
              
                return MaterialApp(
                  title: 'Aaliyah\'s Collection',
                  debugShowCheckedModeBanner: false,
                  showSemanticsDebugger: accessController.showSemanticsDebugger,
                  locale: accessController.locale,
                
                  // STEP 5: INTERNATIONALIZATION
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                    Locale('es'),
                    Locale('fr'),
                  ],
                  
                  themeMode: accessController.themeMode, 
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  
                  // LAYER 3: Global Error Boundary
                  // Prevents the "Gray Screen of Death" by showing a premium Error UI
                  builder: (context, child) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    
                    // Setup Global Error Boundary builder
                    ErrorWidget.builder = (FlutterErrorDetails details) {
                      return GlobalErrorWidget(errorDetails: details);
                    };

                    return AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
                        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                      ),
                      child: child!,
                    );
                  },
                  
                  // STEP 7: NAVIGATION SETUP
                  initialRoute: AppRoutes.initial,
                  onGenerateRoute: AppRouter.generateRoute,
                );
              }
            );
          }
        ),
      );
        },
      ),
    );
  }
}
