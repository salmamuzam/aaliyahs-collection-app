import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/utils/device/device_utility.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Padding(
          padding: DeviceUtils.getPadding(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Flexible( // "Good Row" practice: Flexible adapts to space
                child: TextField(
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: Icon(
                      Icons.search, 
                      color: isDarkMode ? Colors.white : null
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DeviceUtils.getSize(10)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    contentPadding: DeviceUtils.getPadding(vertical: 0),
                  ),
                ),
              ),
              SizedBox(width: DeviceUtils.getHorizontalSize(8)),
              _buildSortMenu(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortMenu(BuildContext context, ProductProvider provider) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: "Sort",
      onSelected: (value) => provider.setSortOption(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Newest', child: Text('Newest')),
        const PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
        const PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
      ],
    );
  }
}
