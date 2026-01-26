import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/common_widgets/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/provider/favorite_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter/services.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.product.images.isEmpty) {
      return const Scaffold(body: Center(child: Text("No product details available")));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      body: AddToCartAnimation(
        cartKey: cartKey,
        height: 30,
        width: 30,
        opacity: 0.85,
        dragAnimation: const DragToCartAnimationOptions(rotation: true),
        jumpAnimation: const JumpAnimationOptions(),
        createAddToCartAnimation: (runAddToCartAnimation) {
          this.runAddToCartAnimation = runAddToCartAnimation;
        },
        child: Stack(
          children: [
            // 1. Background Image Section (Top half)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Container(
                color: isDarkMode ? Colors.grey.shade900 : const Color(0xFFFFF8E1),
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.product.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final img = widget.product.images[index];
                        final isNetwork = img.startsWith('http');
                        return Hero(
                          tag: "product_${widget.product.id}_$index",
                          child: Center(
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: img.isEmpty 
                                ? const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey)
                                : isNetwork
                                    ? CachedNetworkImage(
                                        imageUrl: img, 
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                                      )
                                    : Image.asset(img, fit: BoxFit.cover, alignment: Alignment.topCenter),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Left Arrow
                    if (_selectedImageIndex > 0)
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 25),
                            onPressed: () {
                              // Programmatically scroll pageview if needed, or use controller
                            },
                          ),
                        ),
                      ),
                    
                    // Right Arrow
                    if (_selectedImageIndex < widget.product.images.length - 1)
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 25),
                            onPressed: () {
                              // Programmatically scroll pageview
                            },
                          ),
                        ),
                      ),

                    // Dot Indicators
                    Positioned(
                      bottom: 25,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _selectedImageIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _selectedImageIndex == index
                                  ? aaliyahPrimaryColor
                                  : Colors.grey.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Custom App Bar (Floating)
            Positioned(
              top: 40,
              left: 20,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFloatingBtn(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                    isDarkMode: isDarkMode,
                  ),
                  CartAppBarAction(cartKey: cartKey, color: isDarkMode ? Colors.white : Colors.black),
                ],
              ),
            ),

            // 3. Main Content Card (Scrollable)
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(25, 35, 25, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.product.displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Text(
                        "LKR ${widget.product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ReadMoreText(
                        widget.product.description,
                        trimLines: 4,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Read more',
                        trimExpandedText: ' Read less',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.6,
                        ),
                        moreStyle: TextStyle(color: aaliyahPrimaryColor, fontWeight: FontWeight.bold),
                        lessStyle: TextStyle(color: aaliyahPrimaryColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Floating Favorite Button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4 - 25,
              right: 25,
              child: Consumer<FavoriteProvider>(
                builder: (context, favProvider, _) {
                  final bool isFav = favProvider.isExists(widget.product);
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: aaliyahPrimaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: aaliyahPrimaryColor,
                      radius: 25,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () => favProvider.toggleFavorite(widget.product),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 5. Bottom Action Bar (Floating at bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActionBar(context, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBtn({required IconData icon, required VoidCallback onTap, required bool isDarkMode}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black26 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: isDarkMode ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          // Quantity Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildQuantityBtn(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "$_quantity",
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
                _buildQuantityBtn(Icons.add, () {
                  setState(() => _quantity++);
                }),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Add to Cart Button (Text only as requested)
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                final provider = Provider.of<CartProvider>(context, listen: false);
                for (int i = 0; i < _quantity; i++) {
                  provider.addToCart(widget.product);
                }
                runAddToCartAnimation(cartKey);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Added to Cart"),
                    backgroundColor: aaliyahPrimaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: aaliyahPrimaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: aaliyahPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Add to cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
    );
  }
}

