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
          height: 115, 
          child: CarouselView(
            itemExtent: 80, 
            shrinkExtent: 56,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusXL),
            ),
            elevation: 0,
            onTap: (index) {
              final category = categoriesData[index];
              HapticFeedback.selectionClick();
              // 1. SET FILTER
              productController.fetchShopProducts(categoryIds: [category.id!]);
              // 2. SWITCH TAB
              Provider.of<NavigationController>(context, listen: false).setIndex(1);
            },
            children: categoriesData.map((category) {
              return CategoryButton(
                category: category,
                isSelected: productController.selectedCategoryId == category.id,
                onTap: () {
           
                },
              );
            }).toList(),
          ),
        ).animate().fadeIn(duration: AMotion.durationMedium4); 
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(TUIConstants.shapeRadiusXL),
                      topRight: Radius.circular(TUIConstants.shapeRadiusMedium),
                      bottomLeft: Radius.circular(TUIConstants.shapeRadiusMedium),
                      bottomRight: Radius.circular(TUIConstants.shapeRadiusXL),
                    ),
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
