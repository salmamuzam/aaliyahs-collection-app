import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class ProductCategorySelector extends StatelessWidget {
  const ProductCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final category = isAll ? null : categories[index - 1];
                final isSelected = isAll 
                    ? provider.selectedCategoryId == null 
                    : provider.selectedCategoryId == category?.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(isAll ? "All" : category!.displayName),
                    selected: isSelected,
                    showCheckmark: true,
                    selectedColor: aaliyahSecondaryColor,
                    checkmarkColor: Colors.white,
                    backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        provider.fetchShopProducts(categoryId: isAll ? null : category?.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
