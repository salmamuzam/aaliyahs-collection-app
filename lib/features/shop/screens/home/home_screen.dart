import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/utils/theme/custom_colors.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
// Home Feature Widgets
import 'package:aaliyahs_collection_estore/features/shop/screens/home/widgets/home_top_bar.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/home/widgets/home_banner_carousel.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/home/widgets/home_category_list.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/home/widgets/home_best_sellers_grid.dart';
import 'package:aaliyahs_collection_estore/common/widgets/texts/section_heading.dart';

class HomeScreen extends StatefulWidget {
  final Function(GlobalKey)? onAddToCartAnimation;
  
  const HomeScreen({
    super.key, 
    this.onAddToCartAnimation
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Removed internal cartKey and runAddToCartAnimation local var
  final ScrollController _scrollController = ScrollController();
  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      
      // Listen for re-selection to scroll to top (M3 Behavior)
      _navigationController = Provider.of<NavigationController>(context, listen: false);
      _navigationController.addListener(_handleNavSelection);
    });
  }
  
  void _handleNavSelection() {
    if (_navigationController.reselectedIndex == 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutQuart
      );
    }
  }

  @override
  void dispose() {
    // Clean up listener and controller
    try {
      _navigationController.removeListener(_handleNavSelection);
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final productController = Provider.of<ProductController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    await Future.wait([
      userController.fetchUserProfile(),
      productController.fetchHomeData(token: userController.token),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = DeviceUtils.isCompact;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final aaliyahCustomColors = Theme.of(context).extension<AaliyahCustomColors>();
    
    return Scaffold(
      body: SafeArea(
        bottom: false,
        // Removed internal AddToCartAnimation wrapper
        child: RefreshIndicator(
            onRefresh: _fetchData,
            child: isCompact
                ? Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
                      child: CustomScrollView(
                        key: const PageStorageKey<String>('home_compact_scroll'),
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          _buildHeaderSection(),
                          _buildOfflineIndicator(),
                          _buildCategorySection(),
                          _buildBestSellersHeaderSection(),
                          _buildBestSellersGridSection(),
                          SliverToBoxAdapter(child: SizedBox(height: DeviceUtils.m3Padding(8))),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // Left Pane: Category Navigation (Fixed)
                      Container(
                        width: DeviceUtils.recommendedFixedPaneWidth,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          border: Border(
                            right: BorderSide(
                              color: ((isDarkMode 
                                        ? aaliyahCustomColors?.success 
                                        : aaliyahCustomColors?.successContainer) ?? Colors.transparent).withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: _buildCategoryNavigationPane(),
                      ),
                      
                      // Right Pane: Main Content (Flexible)
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
                            child: CustomScrollView(
                              key: const PageStorageKey<String>('home_expanded_scroll'),
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                _buildHeaderSection(),
                                _buildOfflineIndicator(),
                                _buildBestSellersHeaderSection(),
                                _buildBestSellersGridSection(),
                                SliverToBoxAdapter(child: SizedBox(height: DeviceUtils.m3Padding(8))),
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
  }

  Widget _buildHeaderSection() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        DeviceUtils.m3Margin, 
        DeviceUtils.m3Padding(2), 
        DeviceUtils.m3Margin, 
        0
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RepaintBoundary(child: HomeTopBar()),
            SizedBox(height: DeviceUtils.m3Padding(4)), 
            _buildHomeWelcomeContent(),
            SizedBox(height: DeviceUtils.m3Padding(4)), 
            const RepaintBoundary(child: HomeBannerCarousel()),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeWelcomeContent() {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        final user = userController.user;
        final textScale = MediaQuery.of(context).textScaler.scale(1.0);
        final colorScheme = Theme.of(context).colorScheme;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Hi, ${user?.firstName ?? 'Guest'} ${user?.lastName ?? ''}",
              style: (Theme.of(context).extension<AaliyahTypography>()?.editorialSmall ?? 
                      Theme.of(context).textTheme.titleLarge)?.copyWith(
                fontSize: (20 * textScale).clamp(16.0, 32.0),
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: (12 * textScale).clamp(10.0, 16.0),
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: DeviceUtils.m3Padding(2)), // Reduced padding
            SectionHeading(
              title: 'Shop By Category',
              actionLabel: 'See All',
              onActionPressed: () {
                Provider.of<ProductController>(context, listen: false).toggleAllCategories(false);
                Provider.of<NavigationController>(context, listen: false).setIndex(1);
              },
            ),
            SizedBox(height: DeviceUtils.m3Padding(3)), // 12dp
            const HomeCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellersHeaderSection() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        DeviceUtils.m3Margin, 
        0, // Reduced padding
        DeviceUtils.m3Margin, 
        DeviceUtils.m3Padding(4)  // 16dp
      ),
      sliver: SliverToBoxAdapter(
        child: SectionHeading(
          title: aaliyahBestSellingTitle,
          actionLabel: 'See All',
          onActionPressed: () => _navigateToBestSellers(context),
        ),
      ),
    );
  }

  Widget _buildBestSellersGridSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
      sliver: HomeBestSellersGrid(onAddToCart: (GlobalKey key) {
        if (widget.onAddToCartAnimation != null) {
          widget.onAddToCartAnimation!(key);
        }
      }),
    );
  }

  Widget _buildOfflineIndicator() {
    return Consumer<ProductController>(
      builder: (context, provider, _) {
        if (!provider.isUsingLocalData) return const SliverToBoxAdapter(child: SizedBox.shrink());
        
        // M3 Advanced: Access custom caution color role from theme extension
        final customColors = Theme.of(context).extension<AaliyahCustomColors>();
        final cautionColor = customColors?.caution ?? Colors.amber;
        final cautionContainer = customColors?.cautionContainer ?? Colors.amber.withValues(alpha: 0.1);
        final onCautionContainer = customColors?.onCautionContainer ?? Colors.orange;

        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: DeviceUtils.m3Margin, 
              vertical: DeviceUtils.m3Padding(2)
            ),
            padding: EdgeInsets.symmetric(
              vertical: DeviceUtils.m3Padding(2), 
              horizontal: DeviceUtils.m3Padding(3)
            ),
            decoration: BoxDecoration(
              color: cautionContainer,
              borderRadius: BorderRadius.circular(DeviceUtils.m3Padding(2)),
              border: Border.all(color: cautionColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 16, color: cautionColor),
                SizedBox(width: DeviceUtils.m3Padding(2)),
                Expanded(
                  child: Text(
                    'Offline mode. Showing cached content.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: onCautionContainer),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryNavigationPane() {
    return Consumer<ProductController>(
      builder: (context, provider, _) {
        final categories = provider.categories;
        final colorScheme = Theme.of(context).colorScheme;
        
        return ListView(
          padding: EdgeInsets.all(DeviceUtils.m3Margin),
          children: [
            Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: DeviceUtils.m3Padding(4)),
            
            // All Products
            ListTile(
              leading: Icon(Icons.grid_view_rounded, color: colorScheme.primary),
              title: const Text('All Products'),
              onTap: () {
                Provider.of<ProductController>(context, listen: false).toggleAllCategories(false);
                Provider.of<NavigationController>(context, listen: false).setIndex(1);
              },
            ),
            
            SizedBox(height: DeviceUtils.m3Padding(2)),
            
            // Category List
            ...categories.map((category) {
              return ListTile(
                leading: Icon(Icons.category_outlined, color: colorScheme.onSurfaceVariant),
                title: Text(category.displayName),
                onTap: () {
                  provider.fetchShopProducts(categoryIds: [category.id!]);
                  Provider.of<NavigationController>(context, listen: false).setIndex(1);
                },
              );
            }),
            
            SizedBox(height: DeviceUtils.m3Padding(6)),
            AaliyahDividerTheme.fullWidthDivider(context, height: 1),
            SizedBox(height: DeviceUtils.m3Padding(2)),
            
            // Best Sellers Quick Link
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text('Best Sellers'),
              onTap: () => _navigateToBestSellers(context),
            ),
          ],
        );
      },
    );
  }

  void _navigateToBestSellers(BuildContext context) {
    Provider.of<ProductController>(context, listen: false).fetchAllBestSellingProducts();
    Provider.of<NavigationController>(context, listen: false).setIndex(1);
  }
}
