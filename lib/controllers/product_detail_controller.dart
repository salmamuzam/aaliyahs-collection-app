import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
import 'package:aaliyahs_collection_estore/data/repositories/product_repository.dart';

class ProductDetailController extends ChangeNotifier {
  final ProductRepository _productRepository = ProductRepository();
  
  ProductModel? _product;
  int _selectedImageIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  ProductModel? get product => _product;
  int get selectedImageIndex => _selectedImageIndex;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void initialize(ProductModel initialProduct) {
    _product = initialProduct;
    _selectedImageIndex = 0;
    _isLoading = true;
    _errorMessage = '';
    // We don't notify here because this is usually called in initState or build
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    if (_product?.id == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final detailed = await _productRepository.getProductDetails(_product!.id!);
      if (detailed.success && detailed.data != null) {
        _product = detailed.data;
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
}
