import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/review_model.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product_detail/product_detail_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_detail_controller.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';

class ProductInfoSection extends StatefulWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> with TickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category Assist Chip
                      if (widget.product.categoryName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Semantics(
                            button: true,
                            label: 'Category: ${widget.product.categoryName}',
                            child: ActionChip(
                              avatar: ExcludeSemantics(
                                child: Icon(Icons.label_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                              ),
                              label: Text(widget.product.categoryName),
                              onPressed: () {}, // Could navigate to category search
                              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Share Assist Chip (Standard M3 Action)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Semantics(
                          button: true,
                          label: 'Share this product',
                          child: ActionChip(
                            avatar: ExcludeSemantics(
                              child: Icon(Icons.share_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            label: const Text('Share'),
                            onPressed: () {
                              // Standard Share implementation
                            },
                          ),
                        ),
                      ),
                      // Add to Wishlist Assist Chip (Contextual Action)
                      Semantics(
                        button: true,
                        label: 'Save to wishlist',
                        child: ActionChip(
                          avatar: ExcludeSemantics(
                            child: Icon(Icons.favorite_border_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          label: const Text('Save'),
                          onPressed: () {
                            // Wishlist logic
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildItemTitle(isDarkMode).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),
                _buildItemPrice(isDarkMode).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTabBar(isDarkMode),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return _buildTabContent(context);
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildRelatedProducts(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<ProductDetailController>(
      builder: (context, controller, _) {
        final reviewCount = controller.reviews.length;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            labelStyle: (Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized ?? 
                         Theme.of(context).textTheme.titleSmall),
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
            tabs: [
              const Tab(text: 'Description'),
              Tab(text: 'Reviews ($reviewCount)'),
              const Tab(text: 'Write Review'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return _buildDescriptionBody(context)
            .animate(key: const ValueKey('desc'))
            .fadeIn(duration: 300.ms);
      case 1:
        return _buildReviewsList(context)
            .animate(key: const ValueKey('reviews'))
            .fadeIn(duration: 300.ms);
      case 2:
        return _buildWriteReviewSection(context)
            .animate(key: const ValueKey('add_review'))
            .fadeIn(duration: 300.ms);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReviewsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<ProductDetailController>(
      builder: (context, controller, _) {
        if (controller.reviews.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.rate_review_outlined, size: 64, color: colorScheme.outline),
                const SizedBox(height: 12),
                Text('No reviews yet. Be the first to review!', 
                  style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        // Calculate Average Rating
        double avgRating = 0;
        for (var r in controller.reviews) { avgRating += r.rating; }
        avgRating = avgRating / controller.reviews.length;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(avgRating.toStringAsFixed(1), 
                      style: GoogleFonts.robotoMono(
                        fontSize: 48, 
                        fontWeight: FontWeight.bold, 
                        color: colorScheme.onSurface,
                        letterSpacing: -2,
                      )),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) => Icon(
                          index < avgRating.floor() ? Icons.star : Icons.star_border, 
                          color: Colors.amber, 
                          size: 20,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text('Based on ${controller.reviews.length} reviews', 
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          textAlign: TextAlign.right),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = controller.reviews[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(TUIConstants.cardRadius), // 20
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.secondaryContainer,
                            radius: 18,
                            backgroundImage: (review.userImage != null && review.userImage!.startsWith('assets/'))
                                ? AssetImage(review.userImage!) as ImageProvider 
                                : (review.userImage != null ? NetworkImage(review.userImage!) : null),
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint('Profile Image Load Error: $exception');
                            },
                            child: (review.userImage == null) 
                                ? Icon(Icons.person, size: 20, color: colorScheme.onSecondaryContainer)
                                : null,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review.userName, 
                                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                Row(
                                  children: List.generate(5, (sIdx) => Icon(
                                    sIdx < review.rating.floor() ? Icons.star : Icons.star_border, 
                                    color: Colors.amber, 
                                    size: 14,
                                  )),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(review.date, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        review.comment,
                        style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.4,
                            fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemTitle(bool isDarkMode) {
    // Respect text scaling but prevent extreme sizes that break layout
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    
    return Semantics(
      header: true,
      child: Text(
        _toTitleCase(widget.product.displayName),
        style: (Theme.of(context).extension<AaliyahTypography>()?.editorialMedium ?? 
               Theme.of(context).textTheme.headlineMedium)?.copyWith(
          fontSize: (32 * textScale).clamp(24.0, 56.0),
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _buildItemPrice(bool isDarkMode) {
    return Semantics(
      label: 'Price',
      child: Text(
        "LKR ${widget.product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
        style: GoogleFonts.robotoMono(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // Primary color for price
        ),
      ),
    );
  }

  Widget _buildDescriptionBody(BuildContext context) {
    return Semantics(
      label: 'Product Description',
      container: true,
      child: ReadMoreText(
        widget.product.description,
        trimLines: 10,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Read more',
        trimExpandedText: ' Read less',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.justify,
        moreStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
        lessStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWriteReviewSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final detailController = context.watch<ProductDetailController>();
    final existingReview = detailController.currentUserReview;

    // Pre-fill if editing for the first time in this session
    if (existingReview != null && _reviewController.text.isEmpty) {
      _reviewController.text = existingReview.comment;
      _userRating = existingReview.rating;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(existingReview == null ? 'Share your experience' : 'Edit Your Review', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorScheme.onSurface),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (existingReview != null)
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, detailController),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete Review',
              )
          ],
        ),
        const SizedBox(height: 8),
        Text('Your review will help other modest-fashion lovers find the perfect pieces!', 
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        
        // Star Rating Selection
        Center(
          child: Column(
            children: [
              Text('Rating: $_userRating', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _userRating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setState(() {
                        _userRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        TextField(
          controller: _reviewController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Write your thoughts here...',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TUIConstants.inputFieldRadius), // 12
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 20),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: () {
              if (_reviewController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please write a comment first!')),
                );
                return;
              }

              if (existingReview == null) {
                // ADD NEW
                final newReview = ReviewModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productId: widget.product.id ?? 0,
                  userName: detailController.currentUserName,
                  userImage: detailController.currentUserImage,
                  rating: _userRating,
                  comment: _reviewController.text,
                  date: 'Today',
                );
                detailController.addReview(newReview);
              } else {
                // UPDATE EXISTING
                detailController.updateReview(_reviewController.text, _userRating);
              }
              
              // Move to reviews list
              _tabController.animateTo(1);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colorScheme.primary,
                  content: Text(existingReview == null 
                    ? 'Thank you! Your review has been added' 
                    : 'Your review has been updated'),
                ),
              );
            },
            child: Text(existingReview == null ? 'Submit Review' : 'Update Review', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, ProductDetailController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This review and its rating will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              controller.deleteReview();
              _reviewController.clear();
              setState(() { _userRating = 5.0; });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review deleted successfully')),
              );
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }


  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Widget _buildRelatedProducts(BuildContext context, bool isDarkMode) {
    return Consumer<ProductController>(
      builder: (context, controller, _) {
        // Show Skeleton if loading (Polished Interaction)
        if (controller.isLoading) {
           return Padding(
             padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Container(height: 20, width: 150, color: Colors.grey.withValues(alpha: 0.1)),
                 const SizedBox(height: 12),
                 SizedBox(
                   height: 290,
                   child: ListView.separated(
                     scrollDirection: Axis.horizontal,
                     itemCount: 3,
                     separatorBuilder: (_, __) => const SizedBox(width: 15),
                     itemBuilder: (_, __) => Container(
                       width: 160,
                       decoration: BoxDecoration(
                         color: Colors.grey.withValues(alpha: 0.1),
                         borderRadius: BorderRadius.circular(15),
                       ),
                     ),
                   ),
                 )
               ],
             ),
           );
        }

        // Filter: Same Category, Not Current Product, limit to 5
        final related = controller.shopProductModels
            .where((p) => p.categoryId == widget.product.categoryId && p.id != widget.product.id)
            .take(5)
            .toList();

        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
              child: Text(
                'You might also like',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 290, // Fixed height for horizontal card list
              child: ListView.separated(
               padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                separatorBuilder: (_, __) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                   final p = related[index];
                   return SizedBox(
                     width: 160, // Fixed width for nice aspect ratio
                     child: ProductCardVertical(
                       product: p, 
                       heroPrefix: 'related_${widget.product.id}', // Unique key to avoid conflicts
                       onPress: () => Navigator.push(
                         context, 
                         MaterialPageRoute(builder: (context) => ProductDetailScreen(product: p))
                       )
                     ),
                   );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

