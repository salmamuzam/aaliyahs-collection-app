import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

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
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // 1. Image Placeholder
              Container(
                height: DeviceUtils.height * 0.4,
                width: double.infinity,
                color: Colors.white,
              ),
              
              // 2. Content Section
              Container(
                transform: Matrix4.translationValues(0, -32, 0),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Container(height: 32, width: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 12),
                    Container(height: 24, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 32),
                    Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 16, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Container(height: 48, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                        const SizedBox(width: 16),
                        Container(height: 48, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(height: 20, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(3, (index) => Container(
                        margin: const EdgeInsets.only(right: 12),
                        height: 150,
                        width: 120,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
