import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/category_button.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/profile_screen.dart';

import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

// This is the main home screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to ensure context is available for potential toast/navigation if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Refresh user profile first to get the latest token
    await userProvider.fetchUserProfile();

    // Fetch home data (Best sellers & categories) using the token
    await productProvider.fetchHomeData(token: userProvider.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: AddToCartAnimation(
          cartKey: cartKey,
          height: 30,
          width: 30,
          opacity: 0.85,
          dragAnimation: const DragToCartAnimationOptions(
            rotation: true,
          ),
          jumpAnimation: const JumpAnimationOptions(),
          createAddToCartAnimation: (runAddToCartAnimation) {
            this.runAddToCartAnimation = runAddToCartAnimation;
          },
          child: _buildUI(context),
        ),
      ),
    );
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 16),
              _title(context),
              const SizedBox(height: 16),
              Text(
                "Explore",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _categoriesList(context),
              const SizedBox(height: 24),
              _bannerCarousel(context),
              const SizedBox(height: 16),
              _bestSellingTitle(context),
              const SizedBox(height: 16),
              _productsGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            "Aaliyah's Collection",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FavoriteAppBarAction(),
            CartAppBarAction(cartKey: cartKey),
            const SizedBox(width: 8),

            Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.5),
                  child: user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.profilePhotoUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => FadeShimmer(
                            height: 45,
                            width: 45,
                            radius: 22.5,
                            highlightColor: isDarkMode ? const Color(0xff3a3e3f) : const Color(0xfff9f9f9),
                            baseColor: isDarkMode ? const Color(0xff2d2f30) : const Color(0xffe6e6e6),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.person),
                        )
                      : const Icon(Icons.person),
                ),
              ),
            );

          },
        ),
        ],
        ),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Hello, ",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextSpan(
                text: user?.firstName ?? "Guest",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: "\n"),
              TextSpan(
                text: aaliyahTextSpan2,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categoriesList(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categoriesData = productProvider.categories;
        
        if (productProvider.isLoading && categoriesData.isEmpty) {
          return SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero, // Start at same line as heading
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8), // Reduced gap
                child: Column(
                  children: [
                    FadeShimmer(
                      height: 68,
                      width: 68,
                      radius: 34,
                      highlightColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xff3a3e3f)
                          : const Color(0xfff9f9f9),
                      baseColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xff2d2f30)
                          : const Color(0xffe6e6e6),
                    ),
                    const SizedBox(height: 10),
                    FadeShimmer(
                      height: 12,
                      width: 60,
                      radius: 4,
                      highlightColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xff3a3e3f)
                          : const Color(0xfff9f9f9),
                      baseColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xff2d2f30)
                          : const Color(0xffe6e6e6),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (categoriesData.isEmpty) {
          return const SizedBox(
            height: 50,
            child: Center(child: Text("No categories found")),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero, // Start at same line as heading
            itemCount: categoriesData.length,
            itemBuilder: (context, index) {
              final cat = categoriesData[index];
              return Padding(
                padding: const EdgeInsets.only(right: 0), // Removed gap as requested (or minimized)
                child: CategoryButton(
                  category: cat,
                  isSelected: productProvider.selectedCategoryId == cat.id,
                  onTap: () {
                    // Navigate to Shop and filter
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductScreen(initialCategoryId: cat.id, initialCategoryName: cat.name),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _bannerCarousel(BuildContext context) {
    final List<String> bannerImages = [
      aaliyahBannerImage1,
      aaliyahBannerImage2,
      aaliyahBannerImage3,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double carouselHeight = constraints.maxWidth < 600 ? 150 : 370.5;

        return CarouselSlider(
          options: CarouselOptions(
            height: carouselHeight,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
          ),
          items: bannerImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _productsGrid(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && productProvider.bestSellingProducts.isEmpty) {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 12,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FadeShimmer(
                    height: 200,
                    width: double.infinity,
                    radius: 15,
                    highlightColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xff3a3e3f)
                        : const Color(0xfff9f9f9),
                    baseColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xff2d2f30)
                        : const Color(0xffe6e6e6),
                  ),
                ),
                const SizedBox(height: 8),
                FadeShimmer(
                  height: 16,
                  width: 120,
                  radius: 4,
                  highlightColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff3a3e3f)
                      : const Color(0xfff9f9f9),
                  baseColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2d2f30)
                      : const Color(0xffe6e6e6),
                ),
                const SizedBox(height: 4),
                FadeShimmer(
                  height: 14,
                  width: 80,
                  radius: 4,
                  highlightColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff3a3e3f)
                      : const Color(0xfff9f9f9),
                  baseColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2d2f30)
                      : const Color(0xffe6e6e6),
                ),
              ],
            ),
          );
        }

        if (productProvider.errorMessage.isNotEmpty && productProvider.bestSellingProducts.isEmpty) {
          return Center(
            child: Column(
              children: [
                Text(
                  "Error: ${productProvider.errorMessage}",
                  style: const TextStyle(color: Colors.red),
                ),
                TextButton(
                  onPressed: _fetchData,
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        final bestSellers = productProvider.bestSellingProducts;

        if (bestSellers.isEmpty) {
          // If empty but not loading/error, we still show shimmer for aesthetic placeholder
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 12,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FadeShimmer(
                    height: 200,
                    width: double.infinity,
                    radius: 15,
                    highlightColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xff3a3e3f)
                        : const Color(0xfff9f9f9),
                    baseColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xff2d2f30)
                        : const Color(0xffe6e6e6),
                  ),
                ),
                const SizedBox(height: 8),
                FadeShimmer(
                  height: 16,
                  width: 120,
                  radius: 4,
                  highlightColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff3a3e3f)
                      : const Color(0xfff9f9f9),
                  baseColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2d2f30)
                      : const Color(0xffe6e6e6),
                ),
                const SizedBox(height: 4),
                FadeShimmer(
                  height: 14,
                  width: 80,
                  radius: 4,
                  highlightColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff3a3e3f)
                      : const Color(0xfff9f9f9),
                  baseColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xff2d2f30)
                      : const Color(0xffe6e6e6),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: bestSellers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.65,
                mainAxisSpacing: 12,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = bestSellers[index];
                return ProductCard(
                  product: product,
                  onPress: () {
                    _navigateToProductDetailWithMaterial3(context, product);
                  },
                  onAddToCart: (key) {
                    runAddToCartAnimation(key);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _navigateToProductDetailWithMaterial3(
    BuildContext context,
    Product product,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProductDetailScreen(product: product);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var slideTween = Tween<Offset>(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _bestSellingTitle(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: aaliyahBestSellingTitle,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
