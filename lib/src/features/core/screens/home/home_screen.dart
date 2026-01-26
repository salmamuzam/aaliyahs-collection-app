import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/formatters/text_formatter.dart';
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
import 'package:aaliyahs_collection_estore/provider/notification_provider.dart';

import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/notification_screen.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

// This is the main home screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  int _currentCarouselIndex = 0;

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
              FadeInDown(child: _topBar(context)),
              const SizedBox(height: 16),
              FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: _bannerCarousel(context),
              ),
              const SizedBox(height: 8),
              _buildDotsIndicator(),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  "Our Collections",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _categoriesList(context),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: _bestSellingTitle(context),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: _productsGrid(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: Border.all(color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: user?.profilePhotoUrl != null && user!.profilePhotoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.profilePhotoUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.person),
                            )
                          : const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, ${TFormatter.toSentenceCase(user?.firstName ?? 'Guest')} ${TFormatter.toSentenceCase(user?.lastName ?? '')}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Welcome",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min, // Use min size to keep icons tight
              children: [
                Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    return Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotificationScreen()),
                            );
                          },
                          icon: Icon(
                            Icons.notifications_outlined,
                            size: 28,
                            color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
                          ),
                        ),
                        if (provider.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${provider.unreadCount}',
                                style: const TextStyle(
                                  color: aaliyahLightColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }



  Widget _categoriesList(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final categoriesData = productProvider.categories;
        
        if (productProvider.isLoading && categoriesData.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Container(
                        height: 68,
                        width: 68,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
                    HapticFeedback.selectionClick();
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
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          items: bannerImages.map((image) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? aaliyahDarkColor.withValues(alpha: 0.5) : aaliyahLightColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.transparent : Colors.black.withValues(alpha: 0.05)),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDotsIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: _currentCarouselIndex,
        count: 3,
        effect: ScrollingDotsEffect(
          activeDotColor: (isDarkMode ? aaliyahLightColor : aaliyahDarkColor),
          dotColor: Colors.grey.shade300,
          dotHeight: 8,
          dotWidth: 8,
          fixedCenter: true,
        ),
      ),
    );
  }

  Widget _productsGrid(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading && productProvider.bestSellingProducts.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 12,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) => ProductCard(
                product: Product(
                  id: 0,
                  name: 'Product Name Here',
                  price: '1000',
                  description: 'Description goes here...',
                  images: [''],
                  categoryName: 'Category',
                ),
                onPress: () {},
                onAddToCart: (k) {},
              ),
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
          return const Center(child: Text("No products found"));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = Responsive.getGridColumnCount(context);

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          aaliyahBestSellingTitle,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductScreen(
                  isBestSelling: true, 
                  initialCategoryName: "Best Sellers",
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
          ),
          child: const Text("See All"),
        ),
      ],
    );
  }
}
