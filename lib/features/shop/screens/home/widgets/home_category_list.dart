import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/home/widgets/home_category_button.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';

class HomeCategoryList extends StatelessWidget {
  const HomeCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        final categoriesData = productController.categories;
        
        if (productController.isLoading && categoriesData.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        if (categoriesData.isEmpty) {
          return SizedBox(
            height: TUIConstants.relativeHeight(context, 0.06),
            child: const Center(child: Text('No categories available')),
          );
        }

        return SizedBox(
          height: 140, // Consistent height for the carousel area
          child: CarouselView(
            itemExtent: 100, // Multi-browse: large items around 100dp
            shrinkExtent: 56, // Multi-browse: small items around 56dp
            padding: const EdgeInsets.symmetric(horizontal: 4), // M3: 8dp between elements (half on each side here conceptually)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusXL),
            ),
            elevation: 0,
            children: categoriesData.map((category) {
              return CategoryButton(
                category: category,
                isSelected: productController.selectedCategoryId == category.id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  
                  // 1. SET FILTER (Using existing functionality)
                  productController.fetchShopProducts(categoryIds: [category.id!]);
                  
                  // 2. SWITCH TAB to Shop (Index 1)
                  Provider.of<NavigationController>(context, listen: false).setIndex(1);
                  
                  // No Navigator.push - we switch tabs instead for a better 'Shop' page experience
                },
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: AMotion.durationMedium4); // M3: Content quickly fades in once loaded
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      effect: const ShimmerEffect(
        baseColor: aaliyahShimmerBaseColor,
        highlightColor: aaliyahShimmerHighlightColor,
      ),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
            child: Column(
              children: [
                Container(
                  height: 68,
                  width: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: TUIConstants.relativeHeight(context, 0.01)),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
