
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/data/repositories/product_repository.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/review_model.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_response.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class ProductDetailController extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  
  ProductModel? _product;
  List<ReviewModel> _reviews = [];
  int _selectedImageIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  ColorScheme? _contentColorScheme; 

  ProductModel? get product => _product;
  List<ReviewModel> get reviews => _reviews;
  int get selectedImageIndex => _selectedImageIndex;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ColorScheme? get contentColorScheme => _contentColorScheme;

  void initialize(ProductModel initialProduct, {required Function(ProductModel) onAddToRecent}) {
    _product = initialProduct; 
    _reviews = [];
    _selectedImageIndex = 0;
    _isLoading = true;
    _errorMessage = '';
    _contentColorScheme = null; 
    
  
    onAddToRecent(initialProduct);

   
    if (initialProduct.image.isNotEmpty) {

    }
    
    // Fetch fresh details
    _fetchFullDetails(initialProduct.id);
  }


  Future<void> updateContentTheme(ProductModel product, Brightness brightness) async {
    if (product.image.isEmpty) return;
    
    try {
      ImageProvider imageProvider;
      if (product.image.startsWith('http')) {
        imageProvider = CachedNetworkImageProvider(product.image);
      } else {
        imageProvider = AssetImage(product.image);
      }


      imageProvider = ResizeImage(imageProvider, width: 100);

      final scheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness: brightness,
      ).timeout(const Duration(seconds: 3));

      _contentColorScheme = scheme;
      notifyListeners();
    } on TimeoutException {
      // debugPrint('Theme generation timed out for product');
    } catch (e) {
      if (e.toString().contains('Stream has been disposed')) {
    
      } else {
         debugPrint('Error generating content color scheme: $e');
      }
    }
  }

  Future<void> _fetchFullDetails(int? id) async {
    if (id == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Fetch Product Details and Reviews in Parallel
      final results = await Future.wait([
        _productRepository.getProductDetails(id),
        _productRepository.getProductReviews(id),
      ]);

      final detailedProduct = results[0] as ApiResponse<ProductModel>;
      final detailedReviews = results[1] as ApiResponse<List<ReviewModel>>;

      if (detailedProduct.success && detailedProduct.data != null) {
        _product = detailedProduct.data;
      }

      if (detailedReviews.success && detailedReviews.data != null) {
        _reviews = detailedReviews.data!;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedImageIndex(int index) {
    if (_selectedImageIndex != index) {
      _selectedImageIndex = index;
      notifyListeners();
    }
  }


  String get currentUserName {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) return user.displayName ?? 'Google User';
    return 'Salma Muzammil'; // Fallback for offline
  }

  String get currentUserImage {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) return user.photoURL ?? '';
    return 'assets/images/personalization/profile/user_profile.webp'; // Fallback
  }

  ReviewModel? get currentUserReview {
    try {
      final name = currentUserName;
      return _reviews.firstWhere((r) => r.userName == name);
    } catch (_) {
      return null;
    }
  }

  void addReview(ReviewModel review) {
    // Check if user already has a review - if so, update instead of add
    final index = _reviews.indexWhere((r) => r.userName == review.userName);
    if (index != -1) {
      _reviews[index] = review;
    } else {
      _reviews.insert(0, review);
    }
    notifyListeners();
  }

  void updateReview(String comment, double rating) {
    final index = _reviews.indexWhere((r) => r.userName == currentUserName);
    if (index != -1) {
      final oldReview = _reviews[index];
      _reviews[index] = ReviewModel(
        id: oldReview.id,
        productId: oldReview.productId,
        userName: oldReview.userName,
        userImage: oldReview.userImage,
        rating: rating,
        comment: comment,
        date: 'Edited Today', 
      );
      notifyListeners();
    }
  }

  void deleteReview() {
    _reviews.removeWhere((r) => r.userName == currentUserName);
    notifyListeners();
  }
}
