import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/search_app_bar.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

// Product Feature Widgets
import 'package:aaliyahs_collection_estore/screens/shop/product/widgets/product_category_selector.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product/widgets/product_grid.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CartIconKey> _cartKey = GlobalKey<CartIconKey>();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  late Function(GlobalKey) _runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<ProductController>(context, listen: false);
    const double scrollThreshold = 200;
    
    bool isNearBottom = _scrollController.position.pixels >= 
                       _scrollController.position.maxScrollExtent - scrollThreshold;
    
    if (isNearBottom && !provider.isFetchingMore && provider.hasMore) {
      provider.loadMoreShopProducts();
    }
  }

  void _loadInitialData() {
    final provider = Provider.of<ProductController>(context, listen: false);
    if (widget.isBestSelling) {
      provider.fetchAllBestSellingProducts();
    } else {
      provider.fetchShopProducts(categoryId: widget.initialCategoryId);
    }
  }

  Future<void> _listen() async {
    final provider = Provider.of<ProductController>(context, listen: false);
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isDenied) return;

      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            provider.setSearchQuery(val.recognizedWords);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(context),
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
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AaliyahSearchAppBar(
      controller: _searchController,
      hintText: "Search products...",
      onChanged: (value) => Provider.of<ProductController>(context, listen: false).setSearchQuery(value),
      onMicPress: _listen,
      isListening: _isListening,
      onBackPress: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationMenu()),
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
        const SizedBox(height: 8),
        const ProductCategorySelector(),
        Consumer<ProductController>(
          builder: (context, provider, child) {
            return const SortDropdownWrapper();
          },
        ),
        Expanded(
          child: ProductGrid(
            scrollController: _scrollController,
            onAddToCart: (key) => _runAddToCartAnimation(key),
          ),
        ),
      ],
    );
  }
}

class SortDropdownWrapper extends StatelessWidget {
  const SortDropdownWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductController>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomDropdown<String>(
        hintText: 'Sort by',
        items: const ['Newest', 'Price: Low to High', 'Price: High to Low'],
        initialItem: provider.sortOption,
        onChanged: (value) {
          if (value != null) provider.setSortOption(value);
        },
        decoration: CustomDropdownDecoration(
          closedFillColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
          expandedFillColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          closedBorder: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          expandedBorder: Border.all(color: aaliyahPrimaryColor),
          closedSuffixIcon: const Icon(Icons.keyboard_arrow_down, size: 20),
          expandedSuffixIcon: const Icon(Icons.keyboard_arrow_up, size: 20),
          headerStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          listItemStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
