import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:toastification/toastification.dart';
import 'package:quickalert/quickalert.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/providers/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/providers/notification_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/src/data/services/order_service.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/dashboard/navigation_menu.dart';

// Checkout Feature Widgets
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_progress_bar.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_address_step.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_payment_step.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_summary_step.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_bottom_button.dart';

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
    final CartProvider cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: _buildAppBar(isDarkMode),
      body: Column(
        children: [
          CheckoutProgressBar(currentStep: _currentStep),
          Expanded(
            child: _buildStepContent(cartProvider),
          ),
          CheckoutBottomButton(
            currentStep: _currentStep,
            selectedPaymentIndex: _selectedPaymentIndex,
            onPressed: () => _handleNextAction(cartProvider),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        "Checkout",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStepContent(CartProvider cartProvider) {
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
          cartProvider: cartProvider,
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

  void _handleNextAction(CartProvider cartProvider) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _placeOrder(cartProvider);
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

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (_selectedPaymentIndex == 1) {
      _makePayment(cartProvider.totalPrice());
      return;
    }

    final String? orderId = await _storeOrder("Cash on Delivery", cartProvider.totalPrice());
    _notifyOrderSuccess(cartProvider, orderId, "Cash on Delivery");
    _showSuccessAndNavigate(cartProvider, "Order Placed Successfully!");
  }

  Future<void> _makePayment(double amount) async {
    final OrderService orderService = OrderService();
    await orderService.processStripePayment(
      amount: amount,
      currency: 'LKR',
      onSuccess: () async {
        if (!mounted) return;
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final orderId = await _storeOrder("Stripe (Paid)", cartProvider.totalPrice());
        _notifyOrderSuccess(cartProvider, orderId, "Stripe (Paid)");
        _showSuccessAndNavigate(cartProvider, aaliyahPaymentSuccess);
      },
      onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error: $err")));
        }
      },
    );
  }

  void _notifyOrderSuccess(CartProvider cartProvider, String? orderId, String method) {
    if (!mounted) return;
    
    final List<NotificationOrderItem> notifItems = cartProvider.cart.map((e) => NotificationOrderItem(
      productName: e.displayName,
      productImage: e.image,
      quantity: e.quantity,
      price: e.priceDouble,
    )).toList();

    final DateTime now = DateTime.now();
    final String dateStr = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    Provider.of<NotificationProvider>(context, listen: false).addNotification(
      "Your Order ${orderId ?? '#001'} has been placed successfully!",
      "Placed on $dateStr",
      orderId: orderId,
      totalAmount: cartProvider.totalPrice(),
      paymentMethod: method,
      orderItems: notifItems,
    );
  }

  Future<String?> _storeOrder(String paymentMethod, double amount) async {
    final CartProvider cartProvider = Provider.of<CartProvider>(context, listen: false);
    final Map<String, dynamic> orderData = {
      'date': DateTime.now().toIso8601String(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': 'Pending',
      'customer': {
        'email': FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
        'address': _streetController.text,
        'city': _cityController.text,
        'state': _provinceController.text,
        'country': _countryController.text,
      },
      'items': cartProvider.cart.map((item) => {
            'productId': item.id,
            'title': item.displayName,
            'quantity': item.quantity,
            'price': item.price,
            'image': item.image,
            'category': item.categoryName,
            'description': item.description,
          }).toList(),
    };
    return await OrderService().storeOrderInFirebase(orderData: orderData);
  }

  void _showSuccessAndNavigate(CartProvider cartProvider, String message) async {
    final String amount = cartProvider.formattedTotalPrice;
    cartProvider.clearCart();

    if (!mounted) return;

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Success',
      text: 'Order Placed Successfully!\nAmount: $amount',
      confirmBtnText: 'Ok',
      confirmBtnColor: aaliyahPrimaryColor,
      onConfirmBtnTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
          (route) => false,
        );
      },
    );
  }
}
