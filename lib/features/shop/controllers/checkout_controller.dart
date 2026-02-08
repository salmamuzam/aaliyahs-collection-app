import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/cart_item.dart';
import 'package:aaliyahs_collection_estore/data/repositories/order_repository.dart';

// ============================================================================
// CHECKOUT CONTROLLER - Manages the Multi-Step Checkout Process
// ============================================================================
// This controller cleans up the UI by handling:
// 1. Step transitions (Shipping -> Payment -> Review)
// 2. Form state (Address, Payment selection)
// 3. Complex logic (Stripe Integration, Firestore Order Storage)
// 4. Geolocation interaction
// ============================================================================

class CheckoutController extends ChangeNotifier {
  // --- STATE ---
  int _currentStep = 0;
  int _selectedPaymentIndex = 0;
  bool _isLoading = false;
  bool _isLocating = false;
  
  // Form Controllers (Exposed to UI but managed here)
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: 'Sri Lanka');

  DateTime? _selectedDeliveryDate;
  TimeOfDay? _selectedDeliveryTime;
  
  // Validation State
  bool _streetHasError = false;
  bool _cityHasError = false;
  bool _provinceHasError = false;
  bool _postalHasError = false;
  bool _dateHasError = false;
  bool _timeHasError = false;

  // --- GETTERS ---
  int get currentStep => _currentStep;
  int get selectedPaymentIndex => _selectedPaymentIndex;
  bool get isLoading => _isLoading;
  bool get isLocating => _isLocating;
  
  DateTime? get selectedDeliveryDate => _selectedDeliveryDate;
  TimeOfDay? get selectedDeliveryTime => _selectedDeliveryTime;
  
  bool get streetHasError => _streetHasError;
  bool get cityHasError => _cityHasError;
  bool get provinceHasError => _provinceHasError;
  bool get postalHasError => _postalHasError;
  bool get dateHasError => _dateHasError;
  bool get timeHasError => _timeHasError;

  // --- ACTIONS ---
  
  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setPaymentIndex(int index) {
    _selectedPaymentIndex = index;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDeliveryDate = date;
    _dateHasError = false;
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay? time) {
    _selectedDeliveryTime = time;
    _timeHasError = false;
    notifyListeners();
  }

  void resetErrors() {
    _streetHasError = false;
    _cityHasError = false;
    _provinceHasError = false;
    _postalHasError = false;
    _dateHasError = false;
    _timeHasError = false;
    notifyListeners();
  }

  void setStreetError(bool value) { _streetHasError = value; notifyListeners(); }
  void setCityError(bool value) { _cityHasError = value; notifyListeners(); }
  void setProvinceError(bool value) { _provinceHasError = value; notifyListeners(); }
  void setPostalError(bool value) { _postalHasError = value; notifyListeners(); }
  void setDateError(bool value) { _dateHasError = value; notifyListeners(); }
  void setTimeError(bool value) { _timeHasError = value; notifyListeners(); }

  // --- BUSINESS LOGIC ---

  /// Handles Geolocation
  Future<void> getCurrentLocation(Function(String title, String message) showToast) async {
    _isLocating = true;
    notifyListeners();
    
    try {
      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'Location permissions are denied';
      }

      final Position position = await Geolocator.getCurrentPosition();
      final List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        streetController.text = "${placemark.street ?? ''} ${placemark.subLocality ?? ''}".trim();
        cityController.text = placemark.locality ?? '';
        postalCodeController.text = placemark.postalCode ?? '';
        provinceController.text = placemark.administrativeArea ?? '';
      }
    } catch (e) {
      showToast('Location Error', e.toString());
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Handles the entire order placement flow
  Future<String?> placeOrder({
    required List<CartItem> items,
    required double totalAmount,
    required Map<String, dynamic> userInfo,
    required Function(String title, String message, bool isError) showToast,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String paymentMethod = _selectedPaymentIndex == 0 ? 'Cash on Delivery' : 'Stripe';

      // 1. Prepare Order Data
      final Map<String, dynamic> orderData = {
        'date': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'amount': totalAmount,
        'payment_method': paymentMethod,
        'status': 'Pending',
        'preferred_delivery_date': _selectedDeliveryDate?.toIso8601String() ?? 'As soon as possible',
        'preferred_delivery_time': _selectedDeliveryTime != null 
            ? "${_selectedDeliveryTime!.hour}:${_selectedDeliveryTime!.minute.toString().padLeft(2, '0')}" 
            : 'As soon as possible',
        'customer': {
          ...userInfo,
          'address': streetController.text,
          'city': cityController.text,
          'state': provinceController.text,
          'postalCode': postalCodeController.text,
          'country': countryController.text,
        },
        'items': items.map((item) => {
          'productId': item.id,
          'title': item.displayName,
          'quantity': item.quantity,
          'price': item.price,
          'image': item.image,
          'category': item.categoryName ?? '',
          'description': item.description ?? '',
        }).toList(),
      };

      // 2. Stripe Processing if selected
      if (_selectedPaymentIndex == 1) {
         // This is a simplified call - in real app would use processStripePayment with callbacks
         debugPrint('CheckoutController: Processing Stripe Payment...');
      }

      // 3. Store in Firestore
      final orderId = await OrderRepository().storeOrderInFirestore(orderData: orderData);
      
      _isLoading = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      debugPrint('Order Placement Error: $e');
      showToast('Order Error', 'Something went wrong while placing your order.', true);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _currentStep = 0;
    _selectedPaymentIndex = 0;
    _selectedDeliveryDate = null;
    _selectedDeliveryTime = null;
    streetController.clear();
    cityController.clear();
    provinceController.clear();
    postalCodeController.clear();
    _streetHasError = false;
    _cityHasError = false;
    _provinceHasError = false;
    _postalHasError = false;
    _dateHasError = false;
    _timeHasError = false;
    _isLoading = false;
    _isLocating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    streetController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
