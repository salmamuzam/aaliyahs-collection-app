import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/layouts/adaptive_pane_layout.dart';
import 'package:aaliyahs_collection_estore/common/widgets/layouts/pane_container.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/widgets/product_category_selector.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/widgets/product_grid.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/widgets/product_vertical_category_list.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/widgets/product_sort_dropdown_wrapper.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';

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
  Function(GlobalKey)? _runAddToCartAnimation;
  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      
      // M3 Behavior: Scroll to top upon re-selection
      _navigationController = Provider.of<NavigationController>(context, listen: false);
      _navigationController.addListener(_handleNavSelection);
    });
  }

  void _handleNavSelection() {
    if (_navigationController.reselectedIndex == 1 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutQuart
      );
    }
  }

  @override
  void dispose() {
    // Correctly cleanup listeners before disposing controller
    try {
      _navigationController.removeListener(_handleNavSelection);
    } catch (_) {}
    
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
    } else if (widget.initialCategoryId != null) {
      // Explicitly requested category
      provider.fetchShopProducts(categoryIds: [widget.initialCategoryId!]);
    } else if (provider.selectedCategoryIds.isEmpty && provider.shopProductModels.isEmpty) {
      // Only fetch default "All" if no filters exist and no cache
      provider.fetchShopProducts();
    }
    // If selectedCategoryIds is NOT empty, it means Home already set a filter, 
    // and fetchShopProducts was already called there, so we don't call it again here.
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
    final isCompact = DeviceUtils.isCompact;

    
    return Scaffold(
      appBar: _buildSearchAppBar(context),
      body: AddToCartAnimation(
        cartKey: _cartKey,
        dragAnimation: const DragToCartAnimationOptions(rotation: true),
        createAddToCartAnimation: (runAddToCartAnimation) {
          _runAddToCartAnimation = runAddToCartAnimation;
        },
        child: SafeArea(
          top: false,
          bottom: false,
          child: isCompact
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: _buildMobileBody(),
                  ),
                )
              : AdaptivePaneLayout(
                  resizableDividers: true,
                  maxWidth: DeviceUtils.maxContentWidth,
                  panes: [
                    // PANE 1: Filter/Category Side Pane (Fixed, Resizable)
                    AdaptivePaneItem(
                      id: 'filter_pane',
                      config: PaneConfig(
                        id: 'filter_pane',
                        isFixed: true,
                        fixedWidth: DeviceUtils.recommendedFixedPaneWidth,
                        minWidth: DeviceUtils.paneMinWidth,
                        maxWidth: DeviceUtils.paneMaxWidth,
                        resizable: true,
                        persistResize: true,
                      ),
                      minWindowSize: WindowSizeClass.medium,
                      child: _buildSidePane(context),
                    ),
                    
                    // PANE 2: Product Grid (Flexible)
                    AdaptivePaneItem(
                      id: 'grid_pane',
                      config: const PaneConfig(
                        id: 'grid_pane',
                      ),
                      child: _buildGridPane(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Shop'),
      leading: IconButton(
        onPressed: () {
          Provider.of<NavigationController>(context, listen: false).setIndex(0);
        },
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back to Home',
      ),
      actions: [
        const FavoriteAppBarAction(),
        CartAppBarAction(cartKey: _cartKey),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileBody() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Full Width Search Bar Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AnimatedContainer(
            duration: AMotion.durationStationaryEmphasized,
            curve: AMotion.easingEmphasized,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: _isListening 
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(TUIConstants.shapeRadiusXL),
                      topRight: Radius.circular(TUIConstants.shapeRadiusSmall),
                      bottomLeft: Radius.circular(TUIConstants.shapeRadiusSmall),
                      bottomRight: Radius.circular(TUIConstants.shapeRadiusXL),
                    )
                  : BorderRadius.circular(25),
              border: Border.all(
                color: _isListening ? colorScheme.primary : colorScheme.outlineVariant,
                width: _isListening ? 2.0 : 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => Provider.of<ProductController>(context, listen: false).setSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening...' : 'Search products...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(top: 1),
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? colorScheme.error : colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildSectionHeader('Browse By Category'),
        const ProductCategorySelector(),
        const SortDropdownWrapper(),
        Expanded(
          child: AnimatedSwitcher(
            duration: Provider.of<AccessibilityController>(context).reduceMotion ? AMotion.durationShort4 : AMotion.durationMedium2,
            transitionBuilder: (child, animation) {
              if (Provider.of<AccessibilityController>(context).reduceMotion) {
                return FadeTransition(opacity: animation, child: child);
              }
              // M3 Lateral: Pure slide without fade (better relationship/swipe hint)
              return SlideTransition(
                position: animation.drive(Tween<Offset>(
                  begin: const Offset(0.08, 0), // Standard lateral slide
                  end: Offset.zero,
                ).chain(CurveTween(curve: AMotion.easingStandard))),
                child: child,
              );
            },
            child: ProductGrid(
              key: ValueKey(Provider.of<ProductController>(context).selectedCategoryId),
              scrollController: _scrollController,
              onAddToCart: (key) {
                if (_runAddToCartAnimation != null) {
                  _runAddToCartAnimation!(key);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidePane(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DeviceUtils.m3Padding(4), // 16dp
        vertical: DeviceUtils.m3Padding(6),    // 24dp
      ),
      color: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTERS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colorScheme.primary,
                ),
          ),
          SizedBox(height: DeviceUtils.m3Padding(6)), // 24dp
          const SortDropdownWrapper(),
          SizedBox(height: DeviceUtils.m3Padding(6)), // 24dp
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: DeviceUtils.m3Padding(3)), // 12dp
          const Expanded(
            child: VerticalCategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPane() {
    final reduceMotion = Provider.of<AccessibilityController>(context, listen: false).reduceMotion;
    return AnimatedSwitcher(
      duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationMedium2,
      transitionBuilder: (child, animation) {
        if (reduceMotion) {
          return FadeTransition(opacity: animation, child: child);
        }
        return SlideTransition(
          position: animation.drive(Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: AMotion.easingStandard))),
          child: child,
        );
      },
      child: ProductGrid(
        key: ValueKey(Provider.of<ProductController>(context).selectedCategoryId),
        scrollController: _scrollController,
        onAddToCart: (key) {
          if (_runAddToCartAnimation != null) {
            _runAddToCartAnimation!(key);
          }
        },
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          header: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

