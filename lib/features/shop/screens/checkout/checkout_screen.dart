import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_item_model.dart';

import 'package:aaliyahs_collection_estore/data/repositories/order_repository.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/order_success_screen.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

// Checkout Feature Widgets
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_progress_bar.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_address_step.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_payment_step.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_summary_step.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_bottom_button.dart';

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
  final TextEditingController _countryController = TextEditingController(text: 'Sri Lanka');
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  int _selectedPaymentIndex = 0;
  bool _isLocating = false;
  DateTime? _selectedDeliveryDate;
  TimeOfDay? _selectedDeliveryTime;

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
    final cartController = Provider.of<CartController>(context);
    final isCompact = DeviceUtils.isCompact;
    final isMedium = DeviceUtils.isMedium;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        child: (isCompact || isMedium)
            ? Column(
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
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Pane: Checkout Steps (Flexible)
                  Expanded(
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
                  
                  // Divider
                  VerticalDivider(
                    width: DeviceUtils.paneSpacer,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  
                  // Supporting Pane: Order Summary (Fixed 360dp for expanded)
                  Container(
                    width: DeviceUtils.paneStandardWidth, // 360dp for expanded
                    padding: EdgeInsets.all(DeviceUtils.m3Margin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: DeviceUtils.m3Padding(4)),
                        Expanded(
                          child: CheckoutSummaryStep(
                            cartController: cartController,
                            street: _streetController.text,
                            city: _cityController.text,
                            postalCode: _postalCodeController.text,
                            province: _provinceController.text,
                            country: _countryController.text,
                            isInPane: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final stepNames = ['Address', 'Payment', 'Review'];
    
    return AaliyahSmallAppBar(
      title: 'Checkout',
      subtitle: 'Step ${_currentStep + 1} of 3: ${stepNames[_currentStep]}',
      leading: IconButton(
        onPressed: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
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
          selectedDate: _selectedDeliveryDate,
          onDateSelected: (date) => setState(() => _selectedDeliveryDate = date),
          selectedTime: _selectedDeliveryTime,
          onTimeSelected: (time) => setState(() => _selectedDeliveryTime = time),
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
          title: const Text('Location Error'),
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

    final String? orderId = await _storeOrder('Cash on Delivery', cartController.totalPrice());
    _notifyOrderSuccess(cartController, orderId, 'Cash on Delivery');
    _showSuccessAndNavigate(cartController, orderId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> _makePayment(double amount) async {
    final orderRepository = OrderRepository();
    await orderRepository.processStripePayment(
      amount: amount,
      currency: 'LKR',
      onSuccess: () async {
        if (!mounted) return;
        final cartController = Provider.of<CartController>(context, listen: false);
        final orderId = await _storeOrder('Stripe (Paid)', cartController.totalPrice());
        _notifyOrderSuccess(cartController, orderId, 'Stripe (Paid)');
        _showSuccessAndNavigate(cartController, orderId ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}');
      },
      onError: (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Error: $err')));
        }
      },
    );
  }

  void _notifyOrderSuccess(CartController cartController, String? orderId, String method) {
    if (!mounted) return;
    

    final String displayOrderId = orderId ?? '00000';

    final List<NotificationOrderItem> notifItems = cartController.cart.map((e) => NotificationOrderItem(
      categoryName: e.categoryName ?? e.displayName,
      productImage: e.image,
      quantity: e.quantity,
      price: e.priceDouble,
    )).toList();

    Provider.of<NotificationController>(context, listen: false).addNotification(
      "Aaliyah's Collection", // Brand Name as Title
      'Order #$displayOrderId placed successfully. Shipping details to follow.', // Concise & Useful
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
      'preferred_delivery_date': _selectedDeliveryDate?.toIso8601String() ?? 'As soon as possible',
      'preferred_delivery_time': _selectedDeliveryTime != null 
          ? "${_selectedDeliveryTime!.hour}:${_selectedDeliveryTime!.minute.toString().padLeft(2, '0')}" 
          : 'As soon as possible',
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
          deliveryDate: _selectedDeliveryDate,
          deliveryTime: _selectedDeliveryTime,
        ),
      ),
      (route) => false,
    );
  }
}
