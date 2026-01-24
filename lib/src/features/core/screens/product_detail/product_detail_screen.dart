import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
// import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
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
  int _selectedColorIndex = 0;
  
  // Mock colors for the UI as per reference
  final List<Color> _productColors = [
    const Color(0xFFF6625E), // Redish
    const Color(0xFF836DB8), // Purpleish
    const Color(0xFFDECB9C), // Beige
    const Color(0xFFFFFFFF), // White
  ];

  @override
  Widget build(BuildContext context) {
    // Determine image type
    final isNetworkImage = widget.product.image.startsWith('http');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.black54 : Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black54 : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text("4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                ],
              ),
            ),
          ),
          // Hidden cart icon for animation target
          Visibility(
            visible: false,
            maintainState: true,
             child: CartAppBarAction(cartKey: cartKey),
          ),
        ],
      ),
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
            // Top Image Section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F6F9), // Light background like reference
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Hero(
                      tag: "product_${widget.product.id}",
                      child: SizedBox(
                        height: 250,
                        width: 250,
                        child: isNetworkImage
                            ? CachedNetworkImage(imageUrl: widget.product.image, fit: BoxFit.contain)
                            : Image.asset(widget.product.image, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mock Thumbnails
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.all(6),
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: index == 0 ? const Color(0xFFFF7643) : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                               if (index == 0)
                                 BoxShadow(color: const Color(0xFFFF7643).withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: isNetworkImage
                            ? CachedNetworkImage(imageUrl: widget.product.image, fit: BoxFit.contain)
                            : Image.asset(widget.product.image, fit: BoxFit.contain),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Content Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Favorite
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Consumer<FavoriteProvider>(
                          builder: (context, favProvider, _) {
                            final bool isFav = favProvider.isExists(widget.product);
                            return GestureDetector(
                              onTap: () => favProvider.toggleFavorite(widget.product),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isFav 
                                      ? const Color(0xFFFFE6E6) 
                                      : (isDarkMode ? Colors.grey.shade800 : const Color(0xFFF5F6F9)),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? const Color(0xFFFF4848) : Colors.grey,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ReadMoreText(
                              widget.product.description,
                              trimLines: 3,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: ' See More Detail >',
                              trimExpandedText: ' Show Less',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade300 : const Color(0xFF757575),
                                height: 1.5,
                              ),
                              moreStyle: const TextStyle(
                                color: Color(0xFFFF7643),
                                fontWeight: FontWeight.bold,
                              ),
                              lessStyle: const TextStyle(
                                color: Color(0xFFFF7643),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                             const SizedBox(height: 24),

                            // Color & Quantity Row
                            Row(
                              children: [
                                // Color Selector
                                ...List.generate(_productColors.length, (index) {
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColorIndex = index),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(3), // Border width
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedColorIndex == index 
                                              ? const Color(0xFFFF7643) 
                                              : Colors.transparent, 
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _productColors[index],
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 2,
                                            )
                                          ]
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                const Spacer(),

                                // Quantity Selector
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey.shade800 : Colors.white, // In reference usually light
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildQtyBtn(Icons.remove, () {
                                        if (_quantity > 1) setState(() => _quantity--);
                                      }),
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                          child: Text(
                                            "$_quantity",
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      _buildQtyBtn(Icons.add, () {
                                          setState(() => _quantity++);
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                           // Add to Cart Logic
                           HapticFeedback.mediumImpact();
                           final provider = Provider.of<CartProvider>(context, listen: false);
                           // Usually need to add quantity support to provider, but for now loop add 
                           for(int i=0; i<_quantity; i++){
                              provider.addToCart(widget.product);
                           }
                           
                           // Animate
                           runAddToCartAnimation(cartKey);
                           
                           ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Added to Cart"),
                                backgroundColor: const Color(0xFFFF7643),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 1),
                              ),
                           );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7643), // Orange color from reference
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFFFF7643).withValues(alpha: 0.4),
                        ),
                        child: const Text(
                          "Add to Chart", // Using "Chart" as per reference, though "Cart" is correct English :D
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black87),
        onPressed: onTap,
      ),
    );
  }
}
