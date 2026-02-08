import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';


class ProductCategorySelector extends StatelessWidget {
  const ProductCategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, _CategorySelectionState>(
      selector: (context, provider) => _CategorySelectionState(
        provider.categories,
        provider.selectedCategoryIds,
      ),
      builder: (context, state, child) {
        final categories = state.categories;
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
                  selected: state.selectedIds.isEmpty,
                  label: 'Show all products',
                  hint: 'Double tap to clear filters and show all items',
                  child: FilterChip(
                    label: const Text('All Collections'),
                    selected: state.selectedIds.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<ProductController>().toggleAllCategories(false); 
                      }
                    },
                  ),
                ),
              ),
              // Individual Category Filter Chips
              ...categories.map((category) {
                final isSelected = state.selectedIds.contains(category.id);
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
                          context.read<ProductController>().toggleCategorySelection(category.id!);
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

/// Private helper class to represent the state needed for the Category Selector.
/// Using a separate class with an ']==' operator allows Selector to efficiently 
/// check if the UI actually needs to rebuild.
class _CategorySelectionState {
  final List<dynamic> categories;
  final Set<int> selectedIds;

  _CategorySelectionState(this.categories, this.selectedIds);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CategorySelectionState &&
        other.categories.length == categories.length &&
        other.selectedIds.length == selectedIds.length &&
        other.selectedIds.containsAll(selectedIds);
  }

  @override
  int get hashCode => categories.hashCode ^ selectedIds.hashCode;
}
