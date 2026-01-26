import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/error_info.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          ),
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
        ),
        title: Text(
          "My Cart",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const FavoriteAppBarAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isCartEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, provider, finalList, isDarkMode),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider provider,
    List<Product> finalList,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items List
                ...finalList.asMap().entries.map((entry) {
                  return _buildCartItem(context, provider, entry.value, entry.key, isDarkMode);
                }),
                
                const SizedBox(height: 20),
                
                // Add more items button
                TextButton.icon(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductScreen()),
                      );
                  },
                  icon: Icon(Icons.add, color: isDarkMode ? Colors.white : aaliyahPrimaryColor, size: 20),
                  label: Text(
                    "Add more items",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : aaliyahPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom Summary Section
        _buildBottomSection(context, provider, isDarkMode),
      ],
    );
  }

  Widget _buildCartItem(
      BuildContext context, 
      CartProvider provider, 
      Product item, 
      int index, 
      bool isDarkMode
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Layout based on Image Left, Content Right
          
          // Image
          Container(
            height: 120,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            ),
            padding: const EdgeInsets.all(0), 
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: item.image.isEmpty
                  ? const Icon(Icons.image_not_supported_outlined, color: Colors.grey)
                  : item.image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          placeholder: (context, url) => FadeShimmer(
                            height: 120,
                            width: 90,
                            radius: 16,
                            highlightColor: isDarkMode ? const Color(0xff3a3e3f) : const Color(0xfff9f9f9),
                            baseColor: isDarkMode ? const Color(0xff2d2f30) : const Color(0xffe6e6e6),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                        )
                      : Image.asset(item.image, fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    item.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Price
                Text(
                  "Rs. ${(item.priceDouble * item.quantity).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Quantity Controls Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQtyBtn(Icons.remove, () => provider.decrementQtn(index), isDarkMode),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "${item.quantity}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () => provider.incrementQtn(index), isDarkMode),
                  ],
                ),
              ],
            ),
          ),
          
          // Close (Remove) Button
          IconButton(
            onPressed: () {
               provider.removeFromCart(index);
               final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Removed from Cart!',
                  message: '${item.displayName} has been removed from your cart.',
                  contentType: ContentType.warning,
                ),
              );
              ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(snackBar);
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        width: 28,
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, CartProvider provider, bool isDarkMode) {
    // Subtotal text alignment
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
       //  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             // Removed Subtotal row as requested
             
             const SizedBox(height: 12),
             
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDarkMode ? Colors.white : Colors.black)),
                 Text(provider.formattedTotalPrice, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDarkMode ? Colors.white : Colors.black)),
               ],
             ),
             
             const SizedBox(height: 24),
             
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                    );
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: aaliyahPrimaryColor,
                   foregroundColor: Colors.white, 
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   elevation: 0,
                 ),
                 child: const Text(
                   "Checkout",
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
             )
          ],
        ),
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
                  child: Image.asset(
                    emptyCartIllustration,
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
