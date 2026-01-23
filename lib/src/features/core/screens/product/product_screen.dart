import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/category.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/home/widgets/product_card.dart';
import 'package:aaliyahs_collection_estore/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fade_shimmer/fade_shimmer.dart';

class ProductScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? initialCategoryName;

  const ProductScreen({super.key, this.initialCategoryId, this.initialCategoryName});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ScrollController _scrollController = ScrollController();

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
    // Fetch products based on the passed category ID, or all if null
    provider.fetchShopProducts(categoryId: widget.initialCategoryId);
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
          widget.initialCategoryName ?? "Shop All",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: _loadInitialData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          _categorySelector(),
          Expanded(
            child: _productsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _categorySelector() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        if (categories.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  label: Text(isAll ? "All" : cat!.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.fetchShopProducts(categoryId: isAll ? null : cat?.id);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _productsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.shopProducts.isEmpty) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: 6,
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

        final products = provider.shopProducts;

        if (products.isEmpty) {
          return const Center(
            child: Text("No products found in this category", style: TextStyle(fontWeight: FontWeight.bold)),
          );
        }

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
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
            );
          },
        );
      },
    );
  }
}
