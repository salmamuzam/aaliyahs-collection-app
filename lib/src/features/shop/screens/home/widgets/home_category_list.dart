import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/widgets/category_button.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class HomeCategoryList extends StatelessWidget {
  const HomeCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categoriesData = productProvider.categories;
        
        if (productProvider.isLoading && categoriesData.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        if (categoriesData.isEmpty) {
          return SizedBox(
            height: TUIConstants.relativeHeight(context, 0.06),
            child: const Center(child: Text("No categories found")),
          );
        }

        return SizedBox(
          height: TUIConstants.relativeHeight(context, 0.14),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: categoriesData.length,
            itemExtent: 93.0, // Fixed width 85 + symmetric margin 4*2
            itemBuilder: (context, index) {
              final category = categoriesData[index];
              return CategoryButton(
                category: category,
                isSelected: productProvider.selectedCategoryId == category.id,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(
                        initialCategoryId: category.id, 
                        initialCategoryName: category.name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SizedBox(
        height: TUIConstants.relativeHeight(context, 0.14),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(right: 8),
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
