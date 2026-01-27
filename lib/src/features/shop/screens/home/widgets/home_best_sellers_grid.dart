import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/utils/helpers/responsive_helper.dart';

class HomeBestSellersGrid extends StatelessWidget {
  final Function(GlobalKey) onAddToCart;

  const HomeBestSellersGrid({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && productProvider.bestSellingProducts.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        if (productProvider.errorMessage.isNotEmpty && productProvider.bestSellingProducts.isEmpty) {
          return _buildErrorWidget(context, productProvider);
        }

        final bestSellers = productProvider.bestSellingProducts;
        if (bestSellers.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = Responsive.getGridColumnCount(context);

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: bestSellers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.65,
                mainAxisSpacing: 12,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = bestSellers[index];
                return ProductCardVertical(
                  product: product,
                  onPress: () => _navigateToDetail(context, product),
                  onAddToCart: onAddToCart,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          mainAxisSpacing: 12,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) => ProductCardVertical(
          product: Product(
            id: 0,
            name: 'Loading Product Name',
            price: '0000',
            description: 'Loading description...',
            images: [''],
            categoryName: 'Category',
          ),
          onPress: () {},
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, ProductProvider provider) {
    return Center(
      child: Column(
        children: [
          Text("Error: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: () => provider.fetchHomeData(),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
