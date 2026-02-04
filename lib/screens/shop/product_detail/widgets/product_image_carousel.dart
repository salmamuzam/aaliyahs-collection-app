import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';

class ProductImageCarousel extends StatefulWidget {
  final ProductModel product;
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
      color: isDarkMode ? const Color(0xFF121212) : Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.product.images.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              final String img = widget.product.images[index];
              final heroTag = widget.product.id != null 
                  ? "ProductModel_${widget.product.id}_$index" 
                  : "ProductModel_${widget.product.name}_$index";
              return Hero(
                tag: heroTag,
                child: Center(
                  child: img.isEmpty
                      ? const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey)
                      : Semantics(
                          label: "Product image ${index + 1} of ${widget.product.images.length}: ${widget.product.displayName}",
                          image: true,
                          child: CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.topCenter,
                            // Optimization: Limit decode size to 1000px to save memory
                            memCacheWidth: 1000,
                            memCacheHeight: 1500,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                          ),
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
                  ? Tooltip(
                      message: "Previous Image",
                      child: _arrowButton(
                        Icons.arrow_back_ios_new, 
                        () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                      ),
                    )
                  : const SizedBox(width: 40),
              
              // Right Arrow
              widget.selectedIndex < widget.product.images.length - 1
                  ? Tooltip(
                      message: "Next Image",
                      child: _arrowButton(
                        Icons.arrow_forward_ios, 
                        () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                      ),
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
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
