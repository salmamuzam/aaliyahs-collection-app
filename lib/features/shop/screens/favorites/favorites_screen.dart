import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/widgets/cart_error_info.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; 
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
  late Function(GlobalKey) _runAddToCartAnimation;
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
      subtitle: provider.favorites.isNotEmpty 
          ? "${provider.favorites.length} ${provider.favorites.length == 1 ? 'item' : 'items'}" 
          : null,
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
        childAspectRatio: 0.65,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
              );
            }
          },
          onLongPress: () {
            if (!_isSelectionMode) {
              _enterSelectionMode(product.id!);
            }
          },
          onAddToCart: (key) => _runAddToCartAnimation(key),

        );
      },
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
          padding: EdgeInsets.all(isDesktop ? 40 : DeviceUtils.m3Margin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isDesktop ? 300 : 200,
                height: isDesktop ? 200 : 200, // Reduced from 250 to 200 for mobile
                child: Image.asset(emptyFavoritesIllustration, fit: BoxFit.contain),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 32),
              ErrorInfo(
                title: 'No Favorites Yet!',
                description: "You haven't added any ProductModels to your favorites. Start exploring and save your favorites here!",
                btnText: 'Discover Products',
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
