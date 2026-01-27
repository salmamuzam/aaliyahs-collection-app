import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/user_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/product_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/product_screen.dart';

// Home Feature Widgets
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/widgets/home_top_bar.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/widgets/home_banner_carousel.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/widgets/home_category_list.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/home/widgets/home_best_sellers_grid.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/texts/section_heading.dart';

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
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    await Future.wait([
      userProvider.fetchUserProfile(),
      productProvider.fetchHomeData(token: userProvider.token),
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
            RepaintBoundary(child: FadeInDown(child: const HomeTopBar())),
            SizedBox(height: 16.h),
            RepaintBoundary(
              child: FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: const HomeBannerCarousel(),
              ),
            ),
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
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const SectionHeading(title: "Our Collections"),
            ),
            SizedBox(height: 12.h),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const HomeCategoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellersHeaderSection() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      sliver: SliverToBoxAdapter(
        child: FadeInUp(
          delay: const Duration(milliseconds: 600),
          child: SectionHeading(
            title: aaliyahBestSellingTitle,
            actionLabel: "See All",
            onActionPressed: () => _navigateToBestSellers(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBestSellersGridSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverToBoxAdapter(
        child: FadeInUp(
          delay: const Duration(milliseconds: 800),
          child: HomeBestSellersGrid(onAddToCart: (GlobalKey key) => runAddToCartAnimation(key)),
        ),
      ),
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
