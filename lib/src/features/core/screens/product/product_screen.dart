import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/repository/category_repository.dart';
import 'package:aaliyahs_collection_estore/repository/product_repository.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:flutter/material.dart';

// This is the product screen. All the products are filtered by category
// That means when you click on a category, let's say abaya, it will show abayas, so basically products specific for that category

class ProductScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductScreen({super.key, this.initialCategory});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int isSelected = 0;
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();

    final initialCategoryName = widget.initialCategory ?? categories[0].name;
    _setInitialCategory(initialCategoryName);
    _filterProducts(initialCategoryName);
  }

  void _setInitialCategory(String categoryName) {
    final index = categories.indexWhere(
      (category) => category.name == categoryName,
    );
    if (index != -1) {
      setState(() {
        isSelected = index;
      });
    }
  }

  void _filterProducts(String categoryName) {
    setState(() {
      if (categoryName == "All") {
        filteredProducts = products;
      } else {
        filteredProducts = getProductsByCategory(categoryName);
      }
    });
  }

  void _onCategoryTap(int index, String categoryName) {
    setState(() {
      isSelected = index;
    });
    _filterProducts(categoryName);
  }

  void _onProductTap(Product product) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(
          // I made it a bit fast, so that response time is fast, because in reality humans do not like to wait long time when shopping
          milliseconds: 350,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          aaliyahProductText,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double buttonWidth =
                    constraints.maxWidth / categories.length - 8;

                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(categories.length, (index) {
                    final Category category = categories[index];
                    return SizedBox(
                      width: buttonWidth,
                      child: _buildProductCategory(
                        index: index,
                        name: category.name,
                        onTap: () => _onCategoryTap(index, category.name),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _productsGrid(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCategory({
    required int index,
    required String name,
    required VoidCallback onTap,
  }) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bool selected = isSelected == index;

    final Color backgroundColor = isDarkMode
        ? (selected ? aaliyahLightColor : aaliyahSecondaryColor)
        : (selected ? aaliyahDarkColor : aaliyahPrimaryColor);

    final Color textColor = isDarkMode
        ? (selected ? aaliyahDarkColor : aaliyahDarkColor)
        : (selected ? aaliyahLightColor : aaliyahLightColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _productsGrid(BuildContext context) {
    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          "No products found in this category",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: false,
          itemCount: filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ProductCard(
              product: product,
              onPress: () => _onProductTap(product),
            );
          },
        );
      },
    );
  }
}
