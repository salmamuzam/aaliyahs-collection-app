import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/routes/app_routes.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/login/login_screen.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/signup/signup_screen.dart';
import 'package:aaliyahs_collection_estore/features/authentication/screens/auth_wrapper.dart';
import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/favorites/favorites_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_history_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_detail_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/my_account_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/checkout_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/notification_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/no_internet_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.navigationMenu:
        return MaterialPageRoute(builder: (_) => const NavigationMenu());
      
      // PRO NAVIGATION: Route to specific TABS instead of pushing new screens
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const NavigationMenu(), // Tab 0: Home
        );
      case AppRoutes.store:
        return MaterialPageRoute(
          builder: (_) => const NavigationMenu(initialIndex: 1), // Tab 1: Shop
        );
      case AppRoutes.cart:
        return MaterialPageRoute(
          builder: (_) => const NavigationMenu(initialIndex: 2), // Tab 2: Cart
        );
      case AppRoutes.userProfile:
        return MaterialPageRoute(
          builder: (_) => const NavigationMenu(initialIndex: 3), // Tab 3: Profile
        );
      case AppRoutes.productDetail:
        if (settings.arguments is ProductModel) {
          final product = settings.arguments as ProductModel;
          // PRO FLUTTER: Custom M3 Transition (Slide + Fade)
          return _buildPageRoute(settings, ProductDetailScreen(product: product));
        }
        return _errorRoute();

      case AppRoutes.order:
        return _buildPageRoute(settings, const OrderHistoryScreen());

      case AppRoutes.orderDetail:
        if (settings.arguments is Map<String, dynamic>) {
          final order = settings.arguments as Map<String, dynamic>;
          return _buildPageRoute(settings, OrderDetailScreen(order: order));
        }
        return _errorRoute();

      case AppRoutes.favorites:
        return _buildPageRoute(settings, const FavoriteScreen());

      case AppRoutes.userAccount:
        return _buildPageRoute(settings, const MyAccountScreen());

      case AppRoutes.notifications:
        return _buildPageRoute(settings, const NotificationScreen());

      case AppRoutes.checkout:
        return _buildPageRoute(settings, const CheckoutScreen());

      case AppRoutes.settings:
        return _buildPageRoute(
          settings, 
          Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Center(child: Text('Settings Coming Soon')),
          ),
        );

      case AppRoutes.noInternet:
        return MaterialPageRoute(builder: (_) => const NoInternetScreen());

      default:
        return _errorRoute();
    }
  }

  // HELPER: Professional Slide + Fade Transition
  static PageRouteBuilder _buildPageRoute(RouteSettings settings, Widget child) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.1, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;

        var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found!')),
      ),
    );
  }
}
