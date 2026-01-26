import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';

import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';

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
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (!provider.isFetchingMore && provider.hasMore) {
        provider.loadMoreShopProducts();
      }
    }
  }

  void _loadInitialData() {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (widget.isBestSelling) {
      provider.fetchAllBestSellingProducts();
    } else {
      provider.fetchShopProducts(categoryId: widget.initialCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.initialCategoryName != null && widget.initialCategoryName!.isNotEmpty
              ? "${widget.initialCategoryName![0].toUpperCase()}${widget.initialCategoryName!.substring(1).toLowerCase()}"
              : "Shop",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          const FavoriteAppBarAction(),
          CartAppBarAction(cartKey: cartKey),
          const SizedBox(width: 8),
        ],
      ),
      body: AddToCartAnimation(
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
        child: Column(
          children: [
            FadeInDown(child: _searchAndSortRow()),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: _categorySelector(),
            ),
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _productsGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchAndSortRow() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => provider.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                tooltip: "Sort",
                onSelected: (value) => provider.setSortOption(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Newest', child: Text('Newest')),
                  const PopupMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                  const PopupMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _categorySelector() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final cat = isAll ? null : categories[index - 1];
                final isSelected = isAll 
                    ? provider.selectedCategoryId == null 
                    : provider.selectedCategoryId == cat?.id;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(isAll ? "All" : cat!.displayName),
                    selected: isSelected,
                    showCheckmark: true,
                    selectedColor: aaliyahSecondaryColor,
                    checkmarkColor: Colors.white,
                    backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        provider.fetchShopProducts(categoryId: isAll ? null : cat?.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _productsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.shopProducts.isEmpty) {
          return Skeletonizer(
            enabled: true,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridColumnCount(context),
                childAspectRatio: 0.65,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: 6,
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

        if (provider.errorMessage.isNotEmpty && provider.shopProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Error: ${provider.errorMessage}", style: const TextStyle(color: Colors.red)),
                ElevatedButton(onPressed: _loadInitialData, child: const Text("Retry"))
              ],
            ),
          );
        }

        final products = provider.filteredShopProducts;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty 
                    ? "No results for \"${provider.searchQuery}\"" 
                    : "No products found.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridColumnCount(context),
            childAspectRatio: 0.65,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: products.length + (provider.hasMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return provider.isFetchingMore 
                ? const Center(child: CircularProgressIndicator()) 
                : const SizedBox.shrink();
            }
            final product = products[index];
            return ProductCard(
              product: product,
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                );
              },
              onAddToCart: (key) {
                runAddToCartAnimation(key);
              },
            );
          },
        );
      },
    );
  }
}
