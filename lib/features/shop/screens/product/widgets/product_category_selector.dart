import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';


class ProductCategorySelector extends StatelessWidget {
  const ProductCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // All Collections (No specific category filter)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Semantics(
                  button: true,
                  selected: provider.selectedCategoryIds.isEmpty,
                  label: 'Show all products',
                  hint: 'Double tap to clear filters and show all items',
                  child: FilterChip(
                    label: const Text('All Collections'),
                    selected: provider.selectedCategoryIds.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        provider.toggleAllCategories(false); // Passing false clears all specific filters
                      }
                    },
                  ),
                ),
              ),
              // Individual Category Filter Chips
              ...categories.map((category) {
                final isSelected = provider.selectedCategoryIds.contains(category.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Semantics(
                    container: true,
                    selected: isSelected,
                    label: 'Filter by ${category.displayName}',
                    child: FilterChip(
                      label: Text(category.displayName),
                      selected: isSelected,
                      onSelected: (_) {
                        if (category.id != null) {
                          provider.toggleCategorySelection(category.id!);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
