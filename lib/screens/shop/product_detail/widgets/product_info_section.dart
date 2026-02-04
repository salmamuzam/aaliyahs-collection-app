import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/data/repositories/data_repository.dart';

class ProductInfoSection extends StatefulWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  State<ProductInfoSection> createState() => _ProductInfoSectionState();
}

class _ProductInfoSectionState extends State<ProductInfoSection> with TickerProviderStateMixin {
  final DataRepository _dataRepository = DataRepository();
  final TextEditingController _notesController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await _dataRepository.getProductNote(widget.product.id ?? 0);
    if (mounted) _notesController.text = note;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 35, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            padding: const EdgeInsets.symmetric(horizontal: 25),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDarkMode ? Colors.white12 : Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: aaliyahPrimaryColor,
        unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        indicatorColor: aaliyahPrimaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: const [
          Tab(text: "Description"),
          Tab(text: "Review (24)"),
          Tab(text: "Your Notes"),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return _buildDescriptionBody(context)
            .animate(key: const ValueKey('desc'))
            .fadeIn(duration: 300.ms);
      case 1:
        return _buildReviewsPlaceholder(context)
            .animate(key: const ValueKey('reviews'))
            .fadeIn(duration: 300.ms);
      case 2:
        return _buildNotesSection(context)
            .animate(key: const ValueKey('notes'))
            .fadeIn(duration: 300.ms);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildItemTitle(bool isDarkMode) {
    return Text(
      _toTitleCase(widget.product.displayName),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }


  Widget _buildItemPrice(bool isDarkMode) {
    return Text(
      "LKR ${widget.product.price.replaceAll(RegExp(r'[^0-9.]'), '')}",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.error, // Semantic color for price/alert
      ),
    );
  }

  Widget _buildDescriptionBody(BuildContext context) {
    return ReadMoreText(
      widget.product.description,
      trimLines: 10,
      trimMode: TrimMode.Line,
      trimCollapsedText: 'Read more',
      trimExpandedText: ' Read less',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.6,
        fontSize: 15,
      ),
      textAlign: TextAlign.justify,
      moreStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      lessStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.4), // Using alpha for subtle background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "These notes are private and saved locally on your device.",
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesController,
          maxLines: 5,
          onChanged: (value) => _dataRepository.saveProductNote(widget.product.id ?? 0, value),
          decoration: InputDecoration(
            hintText: "Add personal notes about this item (e.g. size preference, gift ideas)...",
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildReviewsPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text("4.8", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
             Column(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 20))),
                 const SizedBox(height: 4),
                 Text("Based on 24 reviews", style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
               ],
             )
          ],
        ),
        const SizedBox(height: 20),
        // Mock Review Item
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundColor: colorScheme.secondaryContainer, radius: 16, child: Icon(Icons.person, size: 20, color: colorScheme.onSecondaryContainer)),
                  const SizedBox(width: 10),
                  Text("Fatima A.", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  const Spacer(),
                  Text("2 days ago", style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Absolutely love the fabric quality! Fits perfectly.",
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
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

