import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product_detail/product_detail_screen.dart';

class HomeBestSellersGrid extends StatelessWidget {
  final Function(GlobalKey) onAddToCart;

  const HomeBestSellersGrid({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        if (productController.isLoading && productController.bestSellingProductModels.isEmpty) {
          return _buildLoadingSkeleton(context);
        }

        if (productController.errorMessage.isNotEmpty && productController.bestSellingProductModels.isEmpty) {
          return SliverToBoxAdapter(child: _buildErrorWidget(context, productController));
        }

        final bestSellers = productController.bestSellingProductModels;
        if (bestSellers.isEmpty) {
          return const SliverToBoxAdapter(child: Center(child: Text("No Products found")));
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, // Adaptive Reflow
            mainAxisExtent: 260,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = bestSellers[index];
              return ProductCardVertical(
                product: product,
                heroPrefix: 'bestSelling_',
                onPress: () => _navigateToDetail(context, product),
                onAddToCart: onAddToCart,
              );
            },
            childCount: bestSellers.length,
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Skeletonizer(
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
            product: ProductModel(
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
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, ProductController provider) {
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

  void _navigateToDetail(BuildContext context, ProductModel product) {
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
