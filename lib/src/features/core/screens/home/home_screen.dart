import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/category_button.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/profile_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

// This is the main home screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        child: _buildUI(context),
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
                "Categories",
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
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            final token = userProvider.token;

            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (user != null)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Hello, ${user.firstName}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user.email,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: (user != null && user.profilePhotoUrl.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: user.profilePhotoUrl,
                                httpHeaders: token != null
                                    ? {'Authorization': 'Bearer $token'}
                                    : null,
                                placeholder: (context, url) => FadeShimmer(
                                  height: 50,
                                  width: 50,
                                  radius: 25,
                                  highlightColor: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xff3a3e3f)
                                      : const Color(0xfff9f9f9),
                                  baseColor: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xff2d2f30)
                                      : const Color(0xffe6e6e6),
                                ),
                                errorWidget: (context, url, error) {
                                  debugPrint("CachedNetworkImage Error: $error");
                                  return Image.asset(aaliyahProfileImage,
                                      fit: BoxFit.cover);
                                },
                                fit: BoxFit.cover,
                              )
                            : Image.asset(aaliyahProfileImage,
                                fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _title(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: aaliyahTextSpan,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextSpan(
            text: aaliyahTextSpan2,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
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
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
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
                      width: 50,
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
            itemCount: categoriesData.length,
            itemBuilder: (context, index) {
              final cat = categoriesData[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
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
              childAspectRatio: 0.75,
              mainAxisSpacing: 12,
              crossAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => FadeShimmer(
              height: 200,
              width: 150,
              radius: 15,
              highlightColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff3a3e3f)
                  : const Color(0xfff9f9f9),
              baseColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff2d2f30)
                  : const Color(0xffe6e6e6),
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
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                "No sales yet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
                childAspectRatio: 0.75,
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
