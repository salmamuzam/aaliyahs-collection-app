import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/utils/helpers/responsive_helper.dart';

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
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.shopProducts.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        if (provider.errorMessage.isNotEmpty && provider.shopProducts.isEmpty) {
          return _buildErrorWidget(provider);
        }

        final products = provider.filteredShopProducts;

        if (products.isEmpty) {
          return _buildEmptyWidget(context, provider.searchQuery);
        }

        return _buildGrid(context, products, provider);
      },
    );
  }

  Widget _buildGrid(BuildContext context, List<Product> products, ProductProvider provider) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      cacheExtent: 1500, // Optimization #3: Pre-render items outside viewport for smooth scrolling
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220, // Best practice: Ensures balance across all screen widths
        childAspectRatio: 0.65,
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
            onPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
              );
            },
            onAddToCart: onAddToCart,
          ),
        );
      },
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
          product: Product(
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
              : "No products found.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ProductProvider provider) {
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
