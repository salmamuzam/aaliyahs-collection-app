import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:aaliyahs_collection_estore/util/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/screens/shop/product/product_screen.dart';

// Home Feature Widgets
import 'package:aaliyahs_collection_estore/screens/shop/home/widgets/home_top_bar.dart';
import 'package:aaliyahs_collection_estore/screens/shop/home/widgets/home_banner_carousel.dart';
import 'package:aaliyahs_collection_estore/screens/shop/home/widgets/home_category_list.dart';
import 'package:aaliyahs_collection_estore/screens/shop/home/widgets/home_best_sellers_grid.dart';
import 'package:aaliyahs_collection_estore/common/widgets/texts/section_heading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: AddToCartAnimation(
          cartKey: cartKey,
          height: TUIConstants.cartAnimHeight,
          width: TUIConstants.cartAnimWidth,
          opacity: TUIConstants.cartAnimOpacity,
          dragAnimation: const DragToCartAnimationOptions(rotation: true),
          jumpAnimation: const JumpAnimationOptions(),
          createAddToCartAnimation: (Function(GlobalKey) runAnimation) {
            runAddToCartAnimation = runAnimation;
          },
          child: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeaderSection(),
                _buildOfflineIndicator(),
                _buildCategorySection(),
                _buildBestSellersHeaderSection(),
                _buildBestSellersGridSection(),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            const RepaintBoundary(child: HomeTopBar()),
            SizedBox(height: 16.h),
            const RepaintBoundary(child: HomeBannerCarousel()),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            const SectionHeading(title: "Our Collections"),
            SizedBox(height: 12.h),
            const HomeCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellersHeaderSection() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      sliver: SliverToBoxAdapter(
        child: SectionHeading(
          title: aaliyahBestSellingTitle,
          actionLabel: "See All",
          onActionPressed: () => _navigateToBestSellers(context),
        ),
      ),
    );
  }

  Widget _buildBestSellersGridSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: HomeBestSellersGrid(onAddToCart: (GlobalKey key) => runAddToCartAnimation(key)),
    );
  }

  Widget _buildOfflineIndicator() {
    return Consumer<ProductController>(
      builder: (context, provider, _) {
        if (!provider.isUsingLocalData) return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, size: 16, color: Colors.amber),
                SizedBox(width: 8.w),
                Expanded(
                  child: const Text(
                    "Offline Mode: Showing Local Asset Data",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
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

  void _navigateToBestSellers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const ProductScreen(
          isBestSelling: true,
          initialCategoryName: "Best Sellers",
        ),
      ),
    );
  }
}
