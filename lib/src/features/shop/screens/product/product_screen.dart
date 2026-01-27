import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';

// Product Feature Widgets
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/widgets/product_search_bar.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/widgets/product_category_selector.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/widgets/product_grid.dart';

class ProductScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;
  final bool isBestSelling;

  const ProductScreen({
    super.key, 
    this.initialCategoryId, 
    this.initialCategoryName,
    this.isBestSelling = false,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) _runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    const double scrollThreshold = 200;
    
    bool isNearBottom = _scrollController.position.pixels >= 
                       _scrollController.position.maxScrollExtent - scrollThreshold;
    
    if (isNearBottom && !provider.isFetchingMore && provider.hasMore) {
      provider.loadMoreShopProducts();
    }
  }

  void _loadInitialData() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (widget.isBestSelling) {
      provider.fetchAllBestSellingProducts();
    } else {
      provider.fetchShopProducts(categoryId: widget.initialCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: AddToCartAnimation(
        cartKey: _cartKey,
        height: 30,
        width: 30,
        opacity: 0.85,
        dragAnimation: const DragToCartAnimationOptions(rotation: true),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAddToCartAnimation) {
          _runAddToCartAnimation = runAddToCartAnimation;
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200), // Best practice for wide monitors
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final String title = widget.initialCategoryName != null && widget.initialCategoryName!.isNotEmpty
        ? "${widget.initialCategoryName![0].toUpperCase()}${widget.initialCategoryName!.substring(1).toLowerCase()}"
        : "Shop";

    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        ),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        const FavoriteAppBarAction(),
        CartAppBarAction(cartKey: _cartKey),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        FadeInDown(child: const ProductSearchBar()),
        FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: const ProductCategorySelector(),
        ),
        Expanded(
          child: FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ProductGrid(
              scrollController: _scrollController,
              onAddToCart: (key) => _runAddToCartAnimation(key),
            ),
          ),
        ),
      ],
    );
  }
}
