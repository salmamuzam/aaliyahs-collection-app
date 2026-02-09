import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';

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
  final CarouselController _carouselController = CarouselController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _carouselController.addListener(_onCarouselScroll);
  }

  void _onCarouselScroll() {
   
    _debounceTimer?.cancel();
    

    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_carouselController.hasClients && mounted) {
        final double width = MediaQuery.of(context).size.width;
        if (width > 0) {
          final int index = (_carouselController.offset / width).round();
          if (index >= 0 && index < widget.product.images.length && index != widget.selectedIndex) {
            widget.onPageChanged(index);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _carouselController.removeListener(_onCarouselScroll);
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    final bool reduceMotion = MediaQuery.of(context).accessibleNavigation || 
                             (View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion);

    return Container(
      color: isDarkMode ? colorScheme.surface : Colors.white,
      child: Stack(
        children: [
          CarouselView(
            controller: _carouselController,
            itemExtent: MediaQuery.of(context).size.width,
            shrinkExtent: reduceMotion 
                ? MediaQuery.of(context).size.width 
                : MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(),
            elevation: 0,
            onTap: (index) {
              if (index != widget.selectedIndex) {
                widget.onPageChanged(index);
              }
            },
            children: widget.product.images.asMap().entries.map((entry) {
              final int index = entry.key;
              return Hero(
                tag: widget.product.id != null 
                    ? 'ProductModel_${widget.product.id}_$index' 
                    : 'ProductModel_${widget.product.name}_$index',
                child: Semantics(
                  label: 'Product image ${index + 1} of ${widget.product.images.length}',
                  container: true,
                  child: _buildImageItem(entry.value),
                ),
              );
            }).toList(),
          ),
          
          _buildM3Indicators(),
        ],
      ),
    );
  }

  Widget _buildImageItem(String img) {
    return InkWell(
      onTap: () {},
      child: img.isEmpty
          ? const Icon(Icons.image_not_supported_outlined, size: 80, color: Colors.grey)
          : SmartImage(
              imageUrl: img,
              alignment: Alignment.topCenter,
              errorWidget: const Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
            ),
    );
  }

  Widget _buildM3Indicators() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.product.images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: widget.selectedIndex == index ? 10 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.selectedIndex == index 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
