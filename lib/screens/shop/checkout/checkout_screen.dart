import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/data/repositories/order_repository.dart';
import 'package:aaliyahs_collection_estore/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/screens/shop/checkout/order_success_screen.dart';

// Checkout Feature Widgets
import 'package:aaliyahs_collection_estore/screens/shop/checkout/widgets/checkout_progress_bar.dart';
import 'package:aaliyahs_collection_estore/screens/shop/checkout/widgets/checkout_address_step.dart';
import 'package:aaliyahs_collection_estore/screens/shop/checkout/widgets/checkout_payment_step.dart';
import 'package:aaliyahs_collection_estore/screens/shop/checkout/widgets/checkout_summary_step.dart';
import 'package:aaliyahs_collection_estore/screens/shop/checkout/widgets/checkout_bottom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: "Sri Lanka");
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  int _selectedPaymentIndex = 0;
  bool _isLocating = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cartController = Provider.of<CartController>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: _buildAppBar(isDarkMode),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            CheckoutProgressBar(currentStep: _currentStep),
            Expanded(
              child: _buildStepContent(cartController),
            ),
            CheckoutBottomButton(
              currentStep: _currentStep,
              selectedPaymentIndex: _selectedPaymentIndex,
              onPressed: () => _handleNextAction(cartController),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text("Checkout"),
    );
  }

  Widget _buildStepContent(CartController cartController) {
    switch (_currentStep) {
      case 0:
        return CheckoutAddressStep(
          streetController: _streetController,
          cityController: _cityController,
          provinceController: _provinceController,
          postalCodeController: _postalCodeController,
          countryController: _countryController,
          isLocating: _isLocating,
          onLocateMe: _getCurrentLocation,
        );
      case 1:
        return CheckoutPaymentStep(
          selectedPaymentIndex: _selectedPaymentIndex,
          onPaymentSelected: (index) => setState(() => _selectedPaymentIndex = index),
        );
      case 2:
        return CheckoutSummaryStep(
          cartController: cartController,
          street: _streetController.text,
          city: _cityController.text,
          postalCode: _postalCodeController.text,
          province: _provinceController.text,
          country: _countryController.text,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleNextAction(CartController cartController) {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _placeOrder(cartController);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw 'Location permissions are denied';
      }

      final Position position = await Geolocator.getCurrentPosition();
      final List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        setState(() {
          _streetController.text = "${placemark.street ?? ''} ${placemark.subLocality ?? ''}".trim();
          _cityController.text = placemark.locality ?? '';
          _postalCodeController.text = placemark.postalCode ?? '';
          _provinceController.text = placemark.administrativeArea ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text("Location Error"),
          description: Text(e.toString()),
        );
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }

  Future<void> _placeOrder(CartController cartController) async {
    if (_selectedPaymentIndex == 1) {
      _makePayment(cartController.totalPrice());
      return;
    }

    final String? orderId = await _storeOrder("Cash on Delivery", cartController.totalPrice());
    _notifyOrderSuccess(cartController, orderId, "Cash on Delivery");
    _showSuccessAndNavigate(cartController, orderId ?? "ORD-${DateTime.now().millisecondsSinceEpoch}");
  }

  Future<void> _makePayment(double amount) async {
    final orderRepository = OrderRepository();
    await orderRepository.processStripePayment(
      amount: amount,
      currency: 'LKR',
      onSuccess: () async {
        if (!mounted) return;
        final cartController = Provider.of<CartController>(context, listen: false);
        final orderId = await _storeOrder("Stripe (Paid)", cartController.totalPrice());
        _notifyOrderSuccess(cartController, orderId, "Stripe (Paid)");
        _showSuccessAndNavigate(cartController, orderId ?? "ORD-${DateTime.now().millisecondsSinceEpoch}");
      },
      onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error: $err")));
        }
      },
    );
  }

  void _notifyOrderSuccess(CartController cartController, String? orderId, String method) {
    if (!mounted) return;
    
    final List<NotificationOrderItem> notifItems = cartController.cart.map((e) => NotificationOrderItem(
      categoryName: e.categoryName ?? e.displayName,
      productImage: e.image,
      quantity: e.quantity,
      price: e.priceDouble,
    )).toList();

    Provider.of<NotificationController>(context, listen: false).addNotification(
      "Order ${orderId ?? '#001'} placed", // Concise Header
      "Total: ${cartController.formattedTotalPrice}. Confirmation sent to email.", // Vital Info First
      orderId: orderId,
      totalAmount: cartController.totalPrice(),
      paymentMethod: method,
      orderItems: notifItems,
    );
  }


  Future<String?> _storeOrder(String paymentMethod, double amount) async {
    final cartController = Provider.of<CartController>(context, listen: false);
    final user = Provider.of<UserController>(context, listen: false).user;

    final Map<String, dynamic> orderData = {
      'date': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': 'Pending',
      'customer': {
        'firstName': user?.firstName ?? 'Customer',
        'lastName': user?.lastName ?? '',
        'email': (user?.email ?? 'anonymous').toLowerCase(),
        'address': _streetController.text,
        'city': _cityController.text,
        'state': _provinceController.text,
        'postalCode': _postalCodeController.text,
        'country': _countryController.text,
      },
      'items': cartController.cart.map((item) => {
            'productId': item.id,
            'title': item.displayName,
            'quantity': item.quantity,
            'price': item.price,
            'image': item.image,
            'category': item.categoryName ?? '',
            'description': item.description ?? '',
          }).toList(),
    };
    return await OrderRepository().storeOrderInFirestore(orderData: orderData);
  }

  void _showSuccessAndNavigate(CartController cartController, String orderId) {
    final String amount = cartController.formattedTotalPrice;
    final List<dynamic> items = cartController.cart.map((item) => {
      'title': item.displayName,
      'quantity': item.quantity,
      'price': item.price,
    }).toList();
    final String email = Provider.of<UserController>(context, listen: false).user?.email ?? 'customer@example.com';
    
    cartController.clearCart();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          orderAmount: amount,
          orderId: orderId,
          items: items,
          email: email,
        ),
      ),
      (route) => false,
    );
  }
}
