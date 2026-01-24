import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/check_out.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/error_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Main Cart Screen

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = CartProvider.of(context);
    final finalList = provider.cart;

    Widget productQuantity(IconData icon, int index) {
      return GestureDetector(
        onTap: () {
          if (icon == Icons.add) {
            provider.incrementQtn(index);
          } else {
            provider.decrementQtn(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 18),
        ),
      );
    }

    var isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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
          aaliyahCartTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: const [
          FavoriteAppBarAction(),
          CartAppBarAction(),
          SizedBox(width: 8),
        ],
      ),
      body: provider.isCartEmpty
          ? _buildEmptyCart(context)
          : _buildCartWithItems(
              context,
              provider,
              finalList,
              isDarkMode,
              productQuantity,
            ),
    );
  }

  Widget _buildCartWithItems(
    BuildContext context,
    CartProvider provider,
    List<Product> finalList,
    bool isDarkMode,
    Widget Function(IconData, int) productQuantity,
  ) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 140),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.withValues(alpha: 0.1),
              height: 32,
            ),
            itemCount: finalList.length,
            itemBuilder: (context, index) {
              final cartItems = finalList[index];
              return Dismissible(
                key: Key(cartItems.id.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteItem(context, index);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade400),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Container
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey.shade800 : const Color(0xFFE0F2F1), // Light teal bg like reference
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: cartItems.image.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: cartItems.image,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => FadeShimmer(
                                    height: 80,
                                    width: 80,
                                    radius: 12,
                                    highlightColor: isDarkMode ? const Color(0xff3a3e3f) : const Color(0xfff9f9f9),
                                    baseColor: isDarkMode ? const Color(0xff2d2f30) : const Color(0xffe6e6e6),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                                )
                              : Image.asset(cartItems.image, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details & Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItems.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cartItems.category,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Quantity Row
                            Row(
                              children: [
                                _buildQtyBtn(Icons.remove, () => provider.decrementQtn(index), false),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    "${cartItems.quantity}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _buildQtyBtn(Icons.add, () => provider.incrementQtn(index), true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Rs. ${(cartItems.priceDouble * cartItems.quantity).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: const CheckOutBox()),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isBlue) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: isBlue ? Colors.blue.shade400 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isBlue ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  void _deleteItem(BuildContext context, int index) {
    final provider = CartProvider.of(context, listen: false);
    final product = provider.cart[index];

    provider.removeFromCart(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} removed from cart"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return SafeArea(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          padding: EdgeInsets.all(isDesktop ? 40 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              SizedBox(
                width: isDesktop ? 300 : 250,
                height: isDesktop ? 200 : 250,
                child: Lottie.network(
                  'https://assets5.lottiefiles.com/packages/lf20_qhmsz7uw.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Text Content
              ErrorInfo(
                title: "Empty Cart!",
                description:
                    "It seems like you haven't added anything to your cart yet. Let's find some great items to fill it up!",
                btnText: "Discover Products",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
