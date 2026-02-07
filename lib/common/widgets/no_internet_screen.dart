import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_loader.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Consumer<AccessibilityController>(
            builder: (context, access, _) {
              final bool reduceMotion = access.reduceMotion;
              
              return Responsive.buildByOrientation(
                context: context,
                portrait: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      'No Internet Connection',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text('Please check your internet settings.'),
                    const SizedBox(height: 30),
                    ExpressiveLoader(size: ExpressiveLoader.responsiveSize(context, baseSize: 64), semanticLabel: 'Checking for internet connection...'),
                  ],
                ),
                landscape: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.grey),
                    const SizedBox(width: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'No Internet Connection',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Please check your internet settings.'),
                        const SizedBox(height: 20),
                        ExpressiveLoader(size: ExpressiveLoader.responsiveSize(context), semanticLabel: 'Reconnecting...'),
                      ],
                    ),
                  ],
                ),
              )
              .animate(target: reduceMotion ? 0 : 1)
              .fadeIn(duration: AMotion.durationExpressiveEffectsDefault, curve: AMotion.expressiveDefaultEffects)
              .slideY(begin: 0.05, end: 0, duration: AMotion.durationExpressiveDefault, curve: AMotion.springDefaultSpatial(reduceMotion: reduceMotion));
            },
          ),
        ),
      ),
    );
  }
}
