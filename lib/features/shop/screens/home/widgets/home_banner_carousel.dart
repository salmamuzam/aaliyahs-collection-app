import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final CarouselController _carouselController = CarouselController();
  final List<String> _bannerImages = const [
    aaliyahBannerImage1,
    aaliyahBannerImage2,
    aaliyahBannerImage3,
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final access = Provider.of<AccessibilityController>(context);
    final bool reduceMotion = access.reduceMotion;

    return Column(
      children: [
        SizedBox(
          height: 180, // Reduced from 220 for a more compact mobile look
          child: CarouselView(
            controller: _carouselController,
            itemExtent: reduceMotion 
                ? MediaQuery.of(context).size.width * 0.9 // Static size in reduced motion
                : MediaQuery.of(context).size.width * 0.85, 
            shrinkExtent: reduceMotion 
                ? MediaQuery.of(context).size.width * 0.9 
                : MediaQuery.of(context).size.width * 0.65,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusXL), 
            ),
            elevation: 0,
            onTap: (index) {
              // Standard M3 Tap Ripple is handled by CarouselView internal items
            },
            children: _bannerImages.asMap().entries.map((entry) {
              final int index = entry.key;
              final String image = entry.value;
              
              return Semantics(
                label: 'Promotional item ${index + 1} of ${_bannerImages.length}',
                container: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Action for banner
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8), 
                      child: _buildBannerContent(image, reduceMotion),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: DeviceUtils.getVerticalSize(8)),
      ],
    );
  }

  Widget _buildBannerContent(String image, bool reduceMotion) {
    // Banners are full-width but limited height (220dp)
    // Cache at appropriate resolution for display
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = (screenWidth * devicePixelRatio).toInt();
    final cacheHeight = (180 * devicePixelRatio).toInt();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Parallax-ish Background
        Image.asset(
          image,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
          // M3 carousels often have a subtle overlay or parallax feel
        ),
        
        // Content Overlay (Optional: Gradient for text readability)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        // Text Content
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Eid Special Collection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Up to 30% Off on all Abayas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

