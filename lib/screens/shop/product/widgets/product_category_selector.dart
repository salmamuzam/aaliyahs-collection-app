import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

class ProductCategorySelector extends StatelessWidget {
  const ProductCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Determine current index based on controller state
        int initialIndex = 0;
        if (provider.selectedCategoryId != null) {
          initialIndex = categories.indexWhere((c) => c.id == provider.selectedCategoryId) + 1;
          if (initialIndex < 0) initialIndex = 0;
        }

        return DefaultTabController(
          length: categories.length + 1,
          initialIndex: initialIndex,
          key: ValueKey("cat_tabs_${categories.length}_${provider.selectedCategoryId}"),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                onTap: (index) {
                  final category = index == 0 ? null : categories[index - 1];
                  provider.fetchShopProducts(categoryId: category?.id);
                },
                indicatorColor: aaliyahPrimaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: aaliyahPrimaryColor,
                unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                dividerColor: Colors.transparent, // Remove M3 default wide divider
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  const Tab(text: "All"),
                  ...categories.map((c) => Tab(text: c.displayName)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
