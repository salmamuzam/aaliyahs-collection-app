import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';


class HomeBestSellersGrid extends StatelessWidget {
  final Function(GlobalKey) onAddToCart;

  const HomeBestSellersGrid({super.key, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, productController, child) {
        Widget content;
        
        if (productController.isLoading && productController.bestSellingProductModels.isEmpty) {
          content = _buildLoadingSkeleton(context);
        } else if (productController.errorMessage.isNotEmpty && productController.bestSellingProductModels.isEmpty) {
          content = _buildErrorWidget(context, productController);
        } else {
          final bestSellers = productController.bestSellingProductModels;
          if (bestSellers.isEmpty) {
            content = const SliverToBoxAdapter(child: Center(child: Text('No Products found')));
          } else {
            content = SliverGrid(
              key: const ValueKey('best_sellers_grid'),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220, 
                mainAxisExtent: 290,
                mainAxisSpacing: 12,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = bestSellers[index];
                return ProductCardVertical(
                    product: product,
                    heroPrefix: 'bestSelling_',
                    onPress: () => _navigateToDetail(context, product),
                    onAddToCart: onAddToCart,
                  ).animate().fadeIn(duration: AMotion.durationMedium4); // Animate items instead
                },
                childCount: bestSellers.length,
              ),
            );
          }
        }
        
        return content;
      },
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Skeletonizer(
        effect: const ShimmerEffect(
          baseColor: aaliyahShimmerBaseColor,
          highlightColor: aaliyahShimmerHighlightColor,
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, 
            mainAxisExtent: 290,
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
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          children: [
            Text('Error: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () => provider.fetchHomeData(),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: AMotion.durationLong1, // 450ms
        reverseTransitionDuration: AMotion.durationEnterStandard, // 250ms
        pageBuilder: (context, animation, secondaryAnimation) => ProductDetailScreen(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // M3 Forward pattern: Fade + Slide
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AMotion.easingEmphasizedDecelerate,
          ));

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
