import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_detail_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/theme/theme.dart';
import 'package:flutter/services.dart';


import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/widgets/product_image_carousel.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/widgets/product_info_section.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/widgets/product_detail_bottom_action.dart';
import 'package:aaliyahs_collection_estore/common/widgets/shimmers/product_detail_shimmer.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  Function(GlobalKey)? _runAddToCartAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productController = context.read<ProductController>();
      context.read<ProductDetailController>().initialize(
        widget.product,
        onAddToRecent: (product) => productController.addToRecentlyViewed(product),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailController>(
      builder: (context, controller, child) {
      
        if (controller.product == null) {
          return const ProductDetailShimmer();
        }

        final productToDisplay = controller.product!;
        final isCompact = DeviceUtils.isCompact;
        final brightness = Theme.of(context).brightness;

   
        if (controller.contentColorScheme == null && !controller.isLoading) {
         
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateContentTheme(productToDisplay, brightness);
          });
        }

        Widget scaffold = Scaffold(
          backgroundColor: controller.contentColorScheme?.surface ?? Theme.of(context).colorScheme.surface,
          bottomNavigationBar: _buildBottomActionBar(context, productToDisplay),
          body: AddToCartAnimation(
            cartKey: _cartKey,
            dragAnimation: const DragToCartAnimationOptions(rotation: true),
            createAddToCartAnimation: (runAnimation) => _runAddToCartAnimation = runAnimation,
            child: isCompact
                ? CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(context, controller, productToDisplay),
                      SliverToBoxAdapter(
                        child: ProductInfoSection(product: productToDisplay),
                      ),
                    ],
                  )
                : SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      children: [
                        _buildTabletHeader(context, productToDisplay),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                         
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 500),
                                          child: Padding(
                                            padding: EdgeInsets.all(DeviceUtils.m3Margin),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: ProductImageCarousel(
                                                product: productToDisplay,
                                                selectedIndex: controller.selectedImageIndex,
                                                onPageChanged: (index) => controller.setSelectedImageIndex(index),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                              
                                  ExcludeSemantics(
                                    child: VerticalDivider(
                                      width: DeviceUtils.paneSpacer, 
                                      thickness: 1, 
                                      color: controller.contentColorScheme?.outlineVariant ?? Theme.of(context).colorScheme.outlineVariant
                                    ),
                                  ),
                                  
                                  
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
                                      child: ProductInfoSection(product: productToDisplay),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );

   
        if (controller.contentColorScheme != null) {
          return Theme(
            data: AaliyahAppTheme.createTheme(
              controller.contentColorScheme!, 
              brightness
            ),
            child: scaffold,
          );
        }

        return scaffold;
      },
    );
  }

  Widget _buildTabletHeader(BuildContext context, ProductModel product) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(DeviceUtils.m3Margin, 8, DeviceUtils.m3Margin, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Semantics(
              label: 'Back',
              button: true,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back',
              ),
            ),
            const Spacer(),
            Consumer<FavoriteController>(
              builder: (context, favProvider, _) {
                final bool isFav = favProvider.isExists(product);
                return Semantics(
                  label: isFav ? 'Remove from favorites' : 'Add to favorites',
                  button: true,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      favProvider.toggleFavorite(product);
                    },
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                    color: isFav ? colorScheme.primary : null,
                    tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Consumer<CartController>(
              builder: (context, cartProvider, _) {
                final count = cartProvider.cart.length;
                return Semantics(
                  label: count > 0 ? 'Shopping cart, $count items' : 'Shopping cart, empty',
                  button: true,
                  child: AddToCartIcon(
                    key: _cartKey,
                    badgeOptions: const BadgeOptions(active: false),
                    icon: IconButton.filledTonal(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      ),
                      icon: Badge(
                        isLabelVisible: count > 0,
                        label: Text(count > 999 ? '999+' : count.toString()),
                        child: const Icon(Icons.shopping_bag_outlined),
                      ),
                      tooltip: 'Shopping cart',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProductDetailController controller, ProductModel product) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final IconData backIcon = isIOS ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: DeviceUtils.height * 0.45,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, top: 8, bottom: 8),
        child: Semantics(
          label: 'Back',
          button: true,
          child: IconButton.filledTonal( 
            onPressed: () => Navigator.pop(context),
            icon: Icon(backIcon),
            style: IconButton.styleFrom(
               backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9), 
            ),
            tooltip: 'Back',
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Consumer<FavoriteController>(
            builder: (context, favProvider, _) {
              final bool isFav = favProvider.isExists(product);
              return Semantics(
                label: isFav ? 'Remove from wishlist' : 'Add to wishlist',
                button: true,
                child: IconButton.filledTonal(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    favProvider.toggleFavorite(product);
                  },
                  icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                  color: isFav ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                  ),
                  tooltip: isFav ? 'Remove from wishlist' : 'Add to wishlist',
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 16, top: 8, bottom: 8),
          child: Consumer<CartController>(
            builder: (context, cartProvider, _) {
              final count = cartProvider.cart.length;
              return Semantics(
                label: count > 0 ? 'Shopping cart, $count items' : 'Shopping cart, empty',
                button: true,
                child: AddToCartIcon(
                  key: _cartKey,
                  badgeOptions: const BadgeOptions(active: false),
                  icon: IconButton.filledTonal(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    ),
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text(count > 999 ? '999+' : count.toString()),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                    ),
                    tooltip: 'Shopping cart',
                  ),
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageCarousel(
          product: product,
          selectedIndex: controller.selectedImageIndex,
          onPageChanged: (index) => controller.setSelectedImageIndex(index),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, ProductModel product) {
    return ProductDetailBottomAction(
      product: product,
      onAddToCart: () {
        if (_runAddToCartAnimation != null) {
          _runAddToCartAnimation!(_cartKey);
        }
      },
    );
  }
}
