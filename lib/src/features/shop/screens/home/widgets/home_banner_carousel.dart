import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  // Optimization Technique #1: Use ValueNotifier to avoid full widget rebuild on index change
  final ValueNotifier<int> _carouselIndexNotifier = ValueNotifier<int>(0);

  final List<String> _bannerImages = const [
    aaliyahBannerImage1,
    aaliyahBannerImage2,
    aaliyahBannerImage3,
  ];

  @override
  void dispose() {
    _carouselIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, // Best practice: Maintain consistent ratio across devices
          child: RepaintBoundary(
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  _carouselIndexNotifier.value = index;
                },
              ),
              items: _bannerImages.map((image) => _buildBannerItem(context, image)).toList(),
            ),
          ),
        ),
        SizedBox(height: DeviceUtils.getVerticalSize(8)),
        _buildDotsIndicator(),
      ],
    );
  }

  Widget _buildBannerItem(BuildContext context, String image) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahDarkColor.withValues(alpha: 0.5) : aaliyahLightColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          cacheHeight: 400, // Optimization: Limit local image memory footprint
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ValueListenableBuilder<int>(
      valueListenable: _carouselIndexNotifier,
      builder: (context, index, child) {
        return AnimatedSmoothIndicator(
          activeIndex: index,
          count: _bannerImages.length,
          effect: ScrollingDotsEffect(
            activeDotColor: (isDarkMode ? aaliyahLightColor : aaliyahDarkColor),
            dotColor: Colors.grey.shade300,
            dotHeight: 8,
            dotWidth: 8,
            fixedCenter: true,
          ),
        );
      },
    );
  }
}
