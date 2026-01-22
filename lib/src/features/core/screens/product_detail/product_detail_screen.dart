import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/product_detail/widgets/add_button.dart';
import 'package:flutter/material.dart';

// This is the main screen of the product detail screen

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      body: _buildUI(context),

      appBar: _appBar(),
    );
  }

  PreferredSizeWidget _appBar() {
    final provider = FavoriteProvider.of(context);
    return AppBar(
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            provider.toggleFavorite(widget.product);
          },
          icon: Icon(
            provider.isExist(widget.product)
                ? Icons.favorite
                : Icons.favorite_outline,
            size: 25,
          ),
        ),
      ],
    );
  }

  Widget _buildUI(BuildContext context) {
    return Column(
      children: [
        _productImage(context),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
        _productDetails(context),
      ],
    );
  }

  Widget _productImage(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.45,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
        image: DecorationImage(
          fit: BoxFit.contain,
          image: AssetImage(widget.product.image),
        ),
      ),
    );
  }

  Widget _productDetails(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;
    return Expanded(
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * 0.02,
          horizontal: MediaQuery.sizeOf(context).width * 0.05,
        ),
        decoration: BoxDecoration(
          color: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.grey : aaliyahDarkColor,
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _productTitle(context),
            _productPrice(context),
            _productDescription(context),
            _addToCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _productTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.product.name,
          textScaler: const TextScaler.linear(1.4),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _productPrice(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDarkMode = brightness == Brightness.dark;
    return Text(
      "Rs. ${widget.product.price}",
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
      ),
    );
  }

  Widget _productDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Text(widget.product.description),
    );
  }

  Widget _addToCartButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.02,
      ),
      child: AddButton(
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.05,
        product: widget.product,
      ),
    );
  }
}
