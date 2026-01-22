import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:flutter/material.dart';

// This is the add button that is on the product detail page
// When you click, it shows a snackbar which says Successfully added
// This product will be saved in cart page

// ignore: must_be_immutable
class AddButton extends StatefulWidget {
  final double width, height;
  final Product product;
  AddButton({
    super.key,
    required this.width,
    required this.height,
    required this.product,
  });

  @override
  State<AddButton> createState() => _AddButtonState();
  int currentIndex = 1;
}

class _AddButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;
    final provider = CartProvider.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahSecondaryColor : aaliyahPrimaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: GestureDetector(
        onTap: () {
          provider.toggleFavorite(widget.product);

          final snackBar = SnackBar(
            content: Text(
              "Successfully added!",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? aaliyahPrimaryColor : aaliyahLightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: const Duration(seconds: 1),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
            ),
            const SizedBox(width: 8),
            Text(
              aaliyahAddBagBtn,
              style: TextStyle(
                color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
