import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';

class VerticalCategoryList extends StatelessWidget {
  const VerticalCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, provider, _) { 
        final categories = provider.categories;
        
        bool? allSelected;
        if (provider.selectedCategoryIds.isEmpty) {
          allSelected = false;
        } else if (provider.selectedCategoryIds.length == categories.length) {
          allSelected = true;
        } else {
          allSelected = null;
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Semantics(
              label: 'All Collections',
              checked: allSelected == true,
              child: ListTile(
                selected: allSelected == true,
                leading: Checkbox(
                  value: allSelected,
                  tristate: true,
                  onChanged: (val) => provider.toggleAllCategories(val),
                ),
                title: const Text('All Collections', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => provider.toggleAllCategories(allSelected == true ? false : true),
              ),
            ),
            AaliyahDividerTheme.fullWidthDivider(context, height: 1),
            ...categories.map((category) {
              final bool isSelected = provider.selectedCategoryIds.contains(category.id);
              final int catId = category.id ?? 0;
              return Semantics(
                label: 'Category: ${category.displayName}',
                checked: isSelected,
                child: ListTile(
                  selected: isSelected,
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (_) => provider.toggleCategorySelection(catId),
                  ),
                  title: Text(
                    category.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () => provider.toggleCategorySelection(catId),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
