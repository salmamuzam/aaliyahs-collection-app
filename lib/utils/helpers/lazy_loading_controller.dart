import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_loader.dart';

/// Lazy Loading Controller
/// Manages pagination and lazy loading for product lists
/// Implements infinite scroll pattern for better performance
class LazyLoadingController extends ChangeNotifier {
  final List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;
  String? _error;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get currentPage => _currentPage;

  /// Load initial products
  Future<void> loadInitial(Future<List<ProductModel>> Function(int page, int pageSize) fetchFunction) async {
    _products.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    await loadMore(fetchFunction);
  }

  /// Load more products (pagination)
  Future<void> loadMore(Future<List<ProductModel>> Function(int page, int pageSize) fetchFunction) async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProducts = await fetchFunction(_currentPage, _pageSize);
      
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint(' LazyLoadingController: Error loading products - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh products 
  Future<void> refresh(Future<List<ProductModel>> Function(int page, int pageSize) fetchFunction) async {
    await loadInitial(fetchFunction);
  }

  /// Clear all products
  void clear() {
    _products.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _products.clear();
    super.dispose();
  }
}


class LazyLoadingListView extends StatefulWidget {
  final LazyLoadingController controller;
  final Future<List<ProductModel>> Function(int page, int pageSize) fetchFunction;
  final Widget Function(BuildContext context, ProductModel product, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final double? itemExtent;
  final EdgeInsetsGeometry? padding;

  const LazyLoadingListView({
    super.key,
    required this.controller,
    required this.fetchFunction,
    required this.itemBuilder,
    this.emptyWidget,
    this.errorWidget,
    this.itemExtent,
    this.padding,
  });

  @override
  State<LazyLoadingListView> createState() => _LazyLoadingListViewState();
}

class _LazyLoadingListViewState extends State<LazyLoadingListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    if (widget.controller.products.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadInitial(widget.fetchFunction);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when 80% scrolled
      widget.controller.loadMore(widget.fetchFunction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        // Error state
        if (widget.controller.error != null && widget.controller.products.isEmpty) {
          return widget.errorWidget ?? _buildErrorWidget();
        }

        // Empty state
        if (widget.controller.products.isEmpty && !widget.controller.isLoading) {
          return widget.emptyWidget ?? _buildEmptyWidget();
        }

        // List with items
        return RefreshIndicator(
          onRefresh: () => widget.controller.refresh(widget.fetchFunction),
          child: ListView.builder(
            controller: _scrollController,
            padding: widget.padding,
            itemExtent: widget.itemExtent,
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 200.0, // Preload items for smoother scrolling
            itemCount: widget.controller.products.length + 
                      (widget.controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at the end
              if (index == widget.controller.products.length) {
                return _buildLoadingIndicator();
              }

              // Product item
              final product = widget.controller.products[index];
              return widget.itemBuilder(context, product, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: ExpressiveLoader(size: 32),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${widget.controller.error}',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.controller.refresh(widget.fetchFunction),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
