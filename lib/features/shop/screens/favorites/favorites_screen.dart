import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; 
import 'package:aaliyahs_collection_estore/routes/app_routes.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

// ProductInfoSection was accidentally introduced here, removing it as it belongs in product_detail
// class ProductInfoSection extends StatelessWidget ... (removed)

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  Function(GlobalKey)? _runAddToCartAnimation;
  final ScrollController _scrollController = ScrollController();
  late NavigationController _navigationController;

  // Selection state
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // M3 Behavior: Scroll to top upon re-selection
      _navigationController = Provider.of<NavigationController>(context, listen: false);
      _navigationController.addListener(_handleNavSelection);
    });
  }

  void _handleNavSelection() {
    if (_navigationController.reselectedIndex == 2 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutQuart
      );
    }
  }

  @override
  void dispose() {
    try {
      _navigationController.removeListener(_handleNavSelection);
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSelection(int productId) {
    setState(() {
      if (_selectedIds.contains(productId)) {
        _selectedIds.remove(productId);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(productId);
      }
    });
  }

  void _enterSelectionMode(int productId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(productId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _deleteSelected(FavoriteController provider) {
    final productsToDelete = provider.favorites.where((p) => _selectedIds.contains(p.id)).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove ${productsToDelete.length} ${productsToDelete.length == 1 ? 'item' : 'items'}?"),
        content: const Text('These items will be removed from your wishlist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var product in productsToDelete) {
                provider.toggleFavorite(product);
              }
              _exitSelectionMode();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  content: const Text('Items removed from wishlist'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FavoriteController provider = FavoriteController.of(context);
    final List<ProductModel> favList = provider.favorites;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context, provider),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
            child: AddToCartAnimation(
              cartKey: _cartKey,
              dragAnimation: const DragToCartAnimationOptions(rotation: true),
              createAddToCartAnimation: (runAnimation) => _runAddToCartAnimation = runAnimation,
              child: favList.isEmpty
                  ? _buildEmptyFavorites(context)
                  : _buildFavoriteGrid(favList),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FavoriteController provider) {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedIds.length} selected'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteSelected(provider),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AaliyahSmallAppBar(
      title: 'My Wishlist',
      titleSpacing: 24.0,
      titlePadding: const EdgeInsets.only(top: 8.0),
      leading: IconButton(
        onPressed: () {
          // If we can pop, do so. Otherwise go to Home tab (Index 0).
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Provider.of<NavigationController>(context, listen: false).setIndex(0);
          }
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        const FavoriteAppBarAction(),
        CartAppBarAction(cartKey: _cartKey),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFavoriteGrid(List<ProductModel> favorites) {
    return GridView.builder(
      controller: _scrollController,
      cacheExtent: 1000.0,
      padding: EdgeInsets.all(DeviceUtils.m3Margin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.getGridColumnCount(context),
        mainAxisExtent: DeviceUtils.getVerticalSize(288), // Consistent with other product grids
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        final isSelected = _selectedIds.contains(product.id);
        
        return ProductCardVertical(
          product: product,
          isWishlist: true,
          isSelected: isSelected,
          heroPrefix: 'fav_',
          onPress: () {
            if (_isSelectionMode && product.id != null) {
              _toggleSelection(product.id!);
            } else {
              Navigator.pushNamed(
                context, 
                AppRoutes.productDetail, 
                arguments: product
              );
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _enterSelectionMode(product.id!);
            }
          },
          onAddToCart: (key) {
            if (_runAddToCartAnimation != null) {
              _runAddToCartAnimation!(key);
            }
          },

        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Illustration Container with glassmorphism effect
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   Icon(
                    Icons.favorite_rounded,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  Image.asset(
                    emptyFavoritesIllustration,
                    height: 140,
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Text Content
            Text(
              'Your Wishlist is Empty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add the items you love to your wishlist and we\'ll keep them safe for you.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 48),
            
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  Provider.of<NavigationController>(context, listen: false).setIndex(1); // Go to Shop
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: isDarkMode ? colorScheme.primaryContainer : colorScheme.primary,
                  foregroundColor: isDarkMode ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
