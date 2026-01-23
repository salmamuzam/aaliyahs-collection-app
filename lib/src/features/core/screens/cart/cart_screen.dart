import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/check_out.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/cart/widgets/error_info.dart';
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
      ),
      body: provider.isCartEmpty
          ? _buildEmptyCart(context)
          : _buildCartWithItems(
              context,
              finalList,
              isDarkMode,
              productQuantity,
            ),
    );
  }

  Widget _buildCartWithItems(
    BuildContext context,
    List<Product> finalList,
    bool isDarkMode,
    Widget Function(IconData, int) productQuantity,
  ) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 140),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: finalList.length,
            itemBuilder: (context, index) {
              final cartItems = finalList[index];
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? aaliyahSecondaryColor
                          : aaliyahPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          height: 120,
                          width: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(cartItems.image),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                cartItems.name,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? aaliyahDarkColor
                                          : aaliyahLightColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cartItems.category,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? aaliyahDarkColor
                                          : aaliyahLightColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Rs. ${cartItems.price}",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? aaliyahDarkColor
                                          : aaliyahLightColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Total: Rs. ${cartItems.price * cartItems.quantity}",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        _deleteItem(context, index);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: isDarkMode
                            ? aaliyahPrimaryColor
                            : aaliyahSecondaryColor,
                        size: 22,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 10,
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? aaliyahPrimaryColor
                            : aaliyahSecondaryColor,
                        border: Border.all(color: Colors.blueGrey, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          productQuantity(Icons.remove, index),
                          const SizedBox(width: 8),
                          Text(
                            cartItems.quantity.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? aaliyahLightColor
                                  : aaliyahDarkColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          productQuantity(Icons.add, index),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        Positioned(bottom: 0, left: 0, right: 0, child: const CheckOutBox()),
      ],
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
                child: Image.asset(emptyCartIllustration, fit: BoxFit.contain),
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
                      builder: (context) => const BottomNavBar(),
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
