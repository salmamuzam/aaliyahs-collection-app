import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/provider/auth_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/authentication/screens/welcome/welcome_screen.dart';
import 'package:aaliyahs_collection_estore/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

// Fathima Salma Muzammil - CB009970 (COM2461 Batch)
// MAD1 Assignment Task 2 (Code Submission)

// This is the main file, my app runs from here
// It's basically the starting point
// I have defined poppins from google fonts here instead of putting in asset folders because it's easier.
// Google font package can be seen in pubspec.yaml file

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AaliyahApp());
}

class AaliyahApp extends StatelessWidget {
  const AaliyahApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    // Providers, I have used a state management library because it is easier
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
    ],

    child: ToastificationWrapper(
      child: MaterialApp(
        title: 'Aaliyah\'s Collection',
        debugShowCheckedModeBanner: false,

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
        home: WelcomeScreen(),
      ),
    ),
  );
}
