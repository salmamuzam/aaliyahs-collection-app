import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/providers/auth_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/connectivity_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/notification_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/order_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/address_provider.dart';

import 'package:aaliyahs_collection_estore/src/common_widgets/connection/no_internet_screen.dart';
// import 'package:aaliyahs_collection_estore/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/auth_wrapper.dart';

import 'package:aaliyahs_collection_estore/src/utils/theme/theme.dart';
import 'package:aaliyahs_collection_estore/src/config/firebase_options.dart';
import 'package:aaliyahs_collection_estore/src/data/services/notification_service.dart';

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

  runApp(const AaliyahApp());
}



class AaliyahApp extends StatelessWidget {
  const AaliyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize custom Screen utility for responsive design
    DeviceUtils().adaptDeviceScreenSize(context);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return ToastificationWrapper(
            child: MaterialApp(
              title: 'Aaliyah\'s Collection',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              theme: AaliyahAppTheme.lightTheme.copyWith(
                textTheme: GoogleFonts.poppinsTextTheme(AaliyahAppTheme.lightTheme.textTheme),
              ),
              darkTheme: AaliyahAppTheme.darkTheme.copyWith(
                textTheme: GoogleFonts.poppinsTextTheme(AaliyahAppTheme.darkTheme.textTheme),
              ),
              builder: (context, child) {
                final isConnected = Provider.of<ConnectivityProvider>(context).isConnected;
                return (isConnected ? child : const NoInternetScreen()) as Widget;
              },
              initialRoute: '/',
              routes: {
                '/': (context) => const AuthWrapper(),
                '/login': (context) => const LoginScreen(),
                '/signup': (context) => const SignupScreen(),
                '/home': (context) => const NavigationMenu(),
              },
            ),
          );
        },
      ),
    );
  }
}
