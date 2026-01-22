import 'package:aaliyahs_collection_estore/repository/category_repository.dart';
import 'package:aaliyahs_collection_estore/repository/product_repository.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/category_button.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// This is the main home screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI(context));
  }

  Widget _buildUI(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 16),
              _title(context),
              const SizedBox(height: 16),
              _categoriesList(context),
              const SizedBox(height: 16),
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
        Text(
          "Aaliyah's Collection",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(aaliyahProfileImage),
          ),
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
    return SizedBox(
      height: 60,
      child: Row(
        children: List.generate(categories.length, (index) {
          Category category = categories[index];
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CategoryButton(
                category: category,
                isSelected: index == 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductScreen(initialCategory: category.name),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  // Carousel Slider - I have updated the package in pubspec.yaml

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
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: bestSellingProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = bestSellingProducts[index];
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
  }

  // This is basically shared element transition. This happens when you click a product and then it transitions smoothly to product detail page
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
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
