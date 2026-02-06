import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/util/helpers/responsive_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

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
        if (provider.isLoading && provider.shopProductModels.isEmpty) {
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
    return RefreshIndicator(
      onRefresh: () => provider.fetchShopProducts(categoryId: provider.selectedCategoryId),
      color: aaliyahPrimaryColor,
      backgroundColor: Theme.of(context).cardColor,
      child: RawScrollbar(
        controller: scrollController,
        thumbColor: aaliyahPrimaryColor.withValues(alpha: 0.5),
        radius: const Radius.circular(5),
        thickness: 5,
        thumbVisibility: true,
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          padding: const EdgeInsets.all(16),
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
                ? const Center(child: CircularProgressIndicator()) 
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
      enabled: true,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.getGridColumnCount(context),
          childAspectRatio: 0.65,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty 
              ? "No results for \"$searchQuery\"" 
              : "No Products found.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ProductController provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Error: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)),
          const ElevatedButton(onPressed: null, child: Text("Retry")) 
        ],
      ),
    );
  }
}
