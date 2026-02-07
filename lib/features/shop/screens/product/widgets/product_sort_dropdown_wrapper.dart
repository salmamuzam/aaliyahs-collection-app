import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/menus/expressive_menu.dart';

class SortDropdownWrapper extends StatelessWidget {
  const SortDropdownWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductController>(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AaliyahExpressiveMenu(
            width: constraints.maxWidth,
            selectedValue: provider.sortOption,
            onSelected: (value) => provider.setSortOption(value),
            items: const [
              AaliyahMenuItem(label: 'Newest', value: 'Newest', leadingIcon: Icons.new_releases_outlined),
              AaliyahMenuItem(label: 'Price: Low to High', value: 'Price: Low to High', leadingIcon: Icons.arrow_downward_rounded),
              AaliyahMenuItem(label: 'Price: High to Low', value: 'Price: High to Low', leadingIcon: Icons.arrow_upward_rounded),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.sortOption,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.unfold_more_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
