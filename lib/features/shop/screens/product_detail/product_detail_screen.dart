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

// Product Detail Feature Widgets
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
      context.read<ProductDetailController>().initialize(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailController>(
      builder: (context, controller, child) {
        if (controller.isLoading || controller.product == null) {
          return const ProductDetailShimmer();
        }

        final productToDisplay = controller.product!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
           context.read<ProductController>().addToRecentlyViewed(productToDisplay);
        });

        final isCompact = DeviceUtils.isCompact;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // M3 Content-based Dynamic Color: Trigger generation when product is loaded
        if (controller.contentColorScheme == null && !controller.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateContentTheme(controller, productToDisplay, isDarkMode ? Brightness.dark : Brightness.light);
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
                                  // Left Pane: Image Gallery (50%)
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
                                  
                                  // Divider
                                  ExcludeSemantics(
                                    child: VerticalDivider(
                                      width: DeviceUtils.paneSpacer, 
                                      thickness: 1, 
                                      color: controller.contentColorScheme?.outlineVariant ?? Theme.of(context).colorScheme.outlineVariant
                                    ),
                                  ),
                                  
                                  // Right Pane: Product Info (50%)
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

        // Apply Content Theme if available
        if (controller.contentColorScheme != null) {
          return Theme(
            data: AaliyahAppTheme.createTheme(
              controller.contentColorScheme!, 
              isDarkMode ? Brightness.dark : Brightness.light
            ),
            child: scaffold,
          );
        }

        return scaffold;
      },
    );
  }

  void _updateContentTheme(ProductDetailController controller, ProductModel product, Brightness brightness) {
    if (product.image.isEmpty) return;
    
    ImageProvider imageProvider;
    if (product.image.startsWith('http')) {
      imageProvider = NetworkImage(product.image);
    } else {
      imageProvider = AssetImage(product.image);
    }
    
    controller.generateColorScheme(imageProvider, brightness);
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
              child: _buildFloatingBtn(
                context: context,
                icon: Icons.arrow_back_rounded, 
                onTap: () => Navigator.pop(context),
              ),
            ),
            const Spacer(),
            Consumer<FavoriteController>(
              builder: (context, favProvider, _) {
                final bool isFav = favProvider.isExists(product);
                return Semantics(
                  label: isFav ? 'Remove from favorites' : 'Add to favorites',
                  button: true,
                  child: _buildFloatingBtn(
                    context: context,
                    icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      favProvider.toggleFavorite(product);
                    },
                    iconColor: isFav ? colorScheme.primary : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Consumer<CartController>(
              builder: (context, cartProvider, _) {
                final count = cartProvider.cart.length;
                return Semantics(
                  label: count > 0 ? 'Shopping cart, ${count > 999 ? "999+" : count}' : 'Shopping cart, empty',
                  button: true,
                  child: AddToCartIcon(
                    key: _cartKey,
                    badgeOptions: const BadgeOptions(active: false),
                    icon: _buildFloatingBtn(
                      context: context,
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      ),
                      badge: count > 0 ? Badge(
                        label: Text(count > 999 ? '999+' : count.toString()),
                        alignment: AlignmentDirectional.topEnd,
                      ) : null,
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
        padding: const EdgeInsetsDirectional.only(start: 20),
        child: Semantics(
          label: 'Back',
          button: true,
          child: _buildFloatingBtn(
            context: context,
            icon: backIcon, 
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Consumer<FavoriteController>(
          builder: (context, favProvider, _) {
            final bool isFav = favProvider.isExists(product);
            return Semantics(
              label: isFav ? 'Remove from wishlist' : 'Add to wishlist',
              button: true,
              child: _buildFloatingBtn(
                context: context,
                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  favProvider.toggleFavorite(product);
                },
                iconColor: isFav ? colorScheme.primary : null,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 20),
          child: Consumer<CartController>(
            builder: (context, cartProvider, _) {
              final count = cartProvider.cart.length;
              return Semantics(
                label: count > 0 ? 'Shopping cart, ${count > 999 ? "999+" : count}' : 'Shopping cart, empty',
                button: true,
                child: AddToCartIcon(
                  key: _cartKey,
                  badgeOptions: const BadgeOptions(active: false),
                  icon: _buildFloatingBtn(
                    context: context,
                    icon: Icons.shopping_bag_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    ),
                    badge: count > 0 ? Badge(
                      label: Text(count > 999 ? '999+' : count.toString()),
                      alignment: AlignmentDirectional.topEnd,
                    ) : null,
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

  Widget _buildFloatingBtn({
    required BuildContext context, 
    required IconData icon, 
    required VoidCallback onTap, 
    Color? iconColor,
    Badge? badge,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconWidget = Icon(icon, color: iconColor ?? colorScheme.onSurface, size: 20);
    
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        // M3 Elevation: Level 1 for secondary floating elements
        elevation: 1,
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: badge != null 
              ? Badge(
                  label: badge.label,
                  alignment: badge.alignment ?? AlignmentDirectional.topEnd,
                  child: iconWidget,
                )
              : iconWidget,
          ),
        ),
      ),
    );
  }
}
