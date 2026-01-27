import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/cart/widgets/error_info.dart';

// Modular Cart Widgets
import 'package:aaliyahs_collection_estore/src/features/shop/screens/cart/widgets/cart_item_card.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/cart/widgets/cart_bottom_section.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartProvider provider = Provider.of<CartProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: _buildAppBar(context, isDarkMode),
      body: provider.isCartEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, provider, isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        ),
        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        "My Cart",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: const [
        FavoriteAppBarAction(),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider provider, bool isDarkMode) {
    final cartItems = provider.cart;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            cacheExtent: 1000.0,
            padding: const EdgeInsets.symmetric(
              horizontal: TUIConstants.horizontalPadding * 1.25,
              vertical: TUIConstants.verticalPadding * 1.25,
            ),
            itemCount: cartItems.length + 1,
            itemBuilder: (context, index) {
              if (index == cartItems.length) {
                return _buildAddMoreButton(context, isDarkMode);
              }
              return CartItemCard(
                item: cartItems[index],
                index: index,
                provider: provider,
              );
            },
          ),
        ),
        CartBottomSection(provider: provider),
      ],
    );
  }

  Widget _buildAddMoreButton(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductScreen()),
          ),
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
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
        padding: EdgeInsets.all(isDesktop ? 40 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isDesktop ? 300 : 250,
              height: isDesktop ? 200 : 250,
              child: Image.asset(emptyCartIllustration, fit: BoxFit.contain),
            ),
            const SizedBox(height: 40),
            ErrorInfo(
              title: "Empty Cart!",
              description: "It seems like you haven't added anything to your cart yet. Let's find some great items to fill it up!",
              btnText: "Discover Products",
              press: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
