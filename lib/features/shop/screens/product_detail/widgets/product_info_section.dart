import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/review_model.dart';
import 'package:provider/provider.dart';

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
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildItemTitle(isDarkMode).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 15),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.only(right: 24),
              labelStyle: (Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized ?? 
                           Theme.of(context).textTheme.titleSmall),
              unselectedLabelStyle: Theme.of(context).textTheme.titleSmall,
              tabs: [
                const Tab(text: 'Description'),
                Tab(text: 'Reviews ($reviewCount)'),
                const Tab(text: 'Write Review'),
              ],
            ),
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
                      Text('Based on ${controller.reviews.length} Reviews', 
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                          textAlign: TextAlign.right),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 0),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = controller.reviews[index];
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                          const SizedBox(width: 12),
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
                        textAlign: TextAlign.justify,
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
          fontSize: (20 * textScale).clamp(24.0, 56.0),
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
          fontSize: 20,
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
          fontSize: 20,
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
              child: Text(existingReview == null ? 'Share Your Experience' : 'Edit Your Review', 
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
        Text('Your Review will Help Other Modest Fashion Lovers find their Perfect Pieces!', 
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.justify),
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
            hintText: 'Write Your Thoughts Here...',
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
          height: 56,
          child: FilledButton(
            onPressed: () {
              final reviewText = _reviewController.text.trim();
              
              // Validation 1: Check for empty fields
              if (reviewText.isEmpty) {
                _showErrorToast('Empty Fields!', 'Please write your review!');
                return;
              }
              
              // Validation 2: Check minimum length
              if (reviewText.length < 10) {
                _showErrorToast('Too Short!', 'Please enter at least 10 characters!');
                return;
              }
              
              // Validation 3: Check if only numbers
              if (RegExp(r'^\d+$').hasMatch(reviewText)) {
                _showErrorToast('Invalid Format!', 'Please enter only letters!');
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
                    ? 'Your review has been posted successfully!' 
                    : 'Your review has been updated successfully!'),
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
                const SnackBar(content: Text('Your review has been deleted successfully!')),
              );
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String title, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }


  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }


}

