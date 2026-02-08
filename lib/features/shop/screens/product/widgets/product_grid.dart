import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_loader.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:flutter/services.dart';

class ProductGrid extends StatelessWidget {
  final ScrollController scrollController;
  final Function(GlobalKey) onAddToCart;

  const ProductGrid({
    super.key, 
    required this.scrollController, 
    required this.onAddToCart
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingSkeleton(context);
        }

        if (provider.errorMessage.isNotEmpty && provider.shopProductModels.isEmpty) {
          return _buildErrorWidget(provider);
        }

        final products = provider.filteredShopProductModels;

        if (products.isEmpty) {
          return _buildEmptyWidget(context, provider.searchQuery);
        }

        return _buildGrid(context, products, provider);
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<ProductModel> products, ProductController provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () => provider.fetchShopProducts(categoryIds: provider.selectedCategoryIds.toList()),
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      child: RawScrollbar(
        controller: scrollController,
        thumbColor: colorScheme.primary.withValues(alpha: 0.5),
        radius: const Radius.circular(5),
        thickness: 5,
        thumbVisibility: true,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          padding: EdgeInsets.all(DeviceUtils.m3Margin),
          cacheExtent: 1500, // Optimization #3: Pre-render items outside viewport for smooth scrolling
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridColumnCount(context),
            childAspectRatio: Responsive.getGridAspectRatio(context),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: products.length + (provider.hasMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return provider.isFetchingMore 
                ? const Center(child: ExpressiveLoader(size: 32)) 
                : const SizedBox.shrink();
            }
            
            final product = products[index];
            return RepaintBoundary( // Optimization: Prevents grid items from triggering full repaints
              key: ValueKey(product.id), // Key helps Flutter identify items during UI updates
              child: ProductCardVertical(
                product: product,
                heroPrefix: 'shop_',
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                  );
                },
                onAddToCart: onAddToCart,
              ).animate(delay: (30 * (index % 15)).ms)
               .fadeIn(duration: 400.ms)
               .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutQuad),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        padding: EdgeInsets.all(DeviceUtils.m3Margin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.getGridColumnCount(context),
          childAspectRatio: Responsive.getGridAspectRatio(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => ProductCardVertical(
          product: ProductModel(
            id: 0,
            name: 'Product Name',
            price: '1000',
            description: 'Description...',
            images: [''],
            categoryName: 'Category',
          ),
          onPress: () {},
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, String searchQuery) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Illustration Container with glassmorphism effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    Image.asset(
                      emptyProductsIllustration,
                      height: 100,
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Text Content
              Text(
                searchQuery.isNotEmpty ? 'No Results for "$searchQuery"' : 'No Products Found',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                searchQuery.isNotEmpty 
                  ? 'Try adjusting your filters or search terms.' 
                  : 'No products available in this category.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Action Button - Reset Filters / Explore
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final provider = Provider.of<ProductController>(context, listen: false);
                    provider.clearAllFilters(); // Assuming this method exists or similar logic to reset
                    provider.fetchShopProducts(); // Fetch all products
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: isDarkMode ? colorScheme.primaryContainer : colorScheme.primary,
                    foregroundColor: isDarkMode ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'Explore All Products',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ProductController provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)),
          const FilledButton(onPressed: null, child: Text('Retry')) 
        ],
      ),
    );
  }
}
