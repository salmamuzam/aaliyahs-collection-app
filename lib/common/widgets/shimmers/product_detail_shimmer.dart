import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aaliyahs_collection_estore/util/device/device_utility.dart';

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Stack(
          children: [
            // 1. Image Placeholder (Top 45%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: DeviceUtils.height * 0.45,
              child: Container(
                color: Colors.white,
              ),
            ),

            // 2. AppBar Placeholders
            Positioned(
              top: DeviceUtils.getVerticalSize(40),
              left: DeviceUtils.getHorizontalSize(20),
              right: DeviceUtils.getHorizontalSize(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Content Card Placeholder
            Positioned.fill(
              top: DeviceUtils.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30), // Space for fab
                    
                    // Title Lines
                    Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 10),
                    Container(height: 24, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    
                    const SizedBox(height: 24),

                    // Price
                    Container(height: 32, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    
                    const SizedBox(height: 24),

                    // Description Lines
                    Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 14, width: DeviceUtils.width * 0.7, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    
                    const SizedBox(height: 24),
                    
                    // Options / Attributes
                    Row(
                      children: [
                        Container(height: 40, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                        const SizedBox(width: 16),
                        Container(height: 40, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 4. Favorite Button Placeholder
            Positioned(
              top: DeviceUtils.height * 0.4 - DeviceUtils.getSize(25),
              right: 25,
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 5. Bottom Action Bar Placeholder
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 100, // Approximate height
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )
                ),
                 child: Row(
                  children: [
                    Expanded(child: Container(height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)))),
                  ],
                 )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
