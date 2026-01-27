import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class ProductImageCarousel extends StatefulWidget {
  final Product product;
  final int selectedIndex;
  final Function(int) onPageChanged;

  const ProductImageCarousel({
    super.key,
    required this.product,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && 
        _pageController.hasClients && 
        _pageController.page?.round() != widget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.grey.shade900 : const Color(0xFFFFF8E1),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.product.images.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final String img = widget.product.images[index];
              return Hero(
                tag: "product_${widget.product.id}_$index",
                child: Center(
                  child: img.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey)
                      : CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.topCenter,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                        ),
                ),
              );
            },
          ),
          _buildDotIndicators(),
          _buildArrowNav(context),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Positioned(
      bottom: 25,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.product.images.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: widget.selectedIndex == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.selectedIndex == index ? aaliyahPrimaryColor : Colors.grey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowNav(BuildContext context) {
    if (widget.product.images.length <= 1) return const SizedBox.shrink();

    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Arrow
              widget.selectedIndex > 0
                  ? _arrowButton(
                      Icons.arrow_back_ios_new, 
                      () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                    )
                  : const SizedBox(width: 40),
              
              // Right Arrow
              widget.selectedIndex < widget.product.images.length - 1
                  ? _arrowButton(
                      Icons.arrow_forward_ios, 
                      () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                    )
                  : const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
