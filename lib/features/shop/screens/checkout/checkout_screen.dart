import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_item_model.dart';

import 'package:aaliyahs_collection_estore/features/shop/controllers/checkout_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/order_success_screen.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/validators/validator.dart';
import 'package:aaliyahs_collection_estore/utils/constants/text_strings.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Ensure controller is reset when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CheckoutController>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final checkoutController = context.watch<CheckoutController>();
    final isCompact = DeviceUtils.isCompact;
    final isMedium = DeviceUtils.isMedium;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(context, checkoutController),
      body: Form(
        key: _formKey,
        child: (isCompact || isMedium)
            ? Column(
                children: [
                   CheckoutProgressBar(currentStep: checkoutController.currentStep),
                  Expanded(
                    child: _buildStepContent(cartController, checkoutController),
                  ),
                  CheckoutBottomButton(
                    currentStep: checkoutController.currentStep,
                    selectedPaymentIndex: checkoutController.selectedPaymentIndex,
                    isLoading: checkoutController.isLoading,
                    onPressed: () => _handleNextAction(cartController, checkoutController),
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
                        CheckoutProgressBar(currentStep: checkoutController.currentStep),
                        Expanded(
                          child: _buildStepContent(cartController, checkoutController),
                        ),
                        CheckoutBottomButton(
                          currentStep: checkoutController.currentStep,
                          selectedPaymentIndex: checkoutController.selectedPaymentIndex,
                          isLoading: checkoutController.isLoading,
                          onPressed: () => _handleNextAction(cartController, checkoutController),
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
                    width: DeviceUtils.paneStandardWidth, 
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
                            street: checkoutController.streetController.text,
                            city: checkoutController.cityController.text,
                            postalCode: checkoutController.postalCodeController.text,
                            province: checkoutController.provinceController.text,
                            country: checkoutController.countryController.text,
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

  PreferredSizeWidget _buildAppBar(BuildContext context, CheckoutController controller) {
    return AaliyahSmallAppBar(
      title: 'Checkout',
      leading: IconButton(
        onPressed: () {
          if (controller.currentStep > 0) {
            controller.previousStep();
          } else {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    );
  }

  Widget _buildStepContent(CartController cart, CheckoutController checkout) {
    switch (checkout.currentStep) {
      case 0:
        return CheckoutAddressStep(
          streetController: checkout.streetController,
          cityController: checkout.cityController,
          provinceController: checkout.provinceController,
          postalCodeController: checkout.postalCodeController,
          countryController: checkout.countryController,
          isLocating: checkout.isLocating,
          onLocateMe: () => checkout.getCurrentLocation((t, m) => _showToast(t, m)),
          selectedDate: checkout.selectedDeliveryDate,
          onDateSelected: (date) => checkout.setSelectedDate(date),
          selectedTime: checkout.selectedDeliveryTime,
          onTimeSelected: (time) => checkout.setSelectedTime(time),
          streetHasError: checkout.streetHasError,
          cityHasError: checkout.cityHasError,
          postalHasError: checkout.postalHasError,
          provinceHasError: checkout.provinceHasError,
          dateHasError: checkout.dateHasError,
          timeHasError: checkout.timeHasError,
        );
      case 1:
        return CheckoutPaymentStep(
          selectedPaymentIndex: checkout.selectedPaymentIndex,
          onPaymentSelected: (index) => checkout.setPaymentIndex(index),
        );
      case 2:
        return CheckoutSummaryStep(
          cartController: cart,
          street: checkout.streetController.text,
          city: checkout.cityController.text,
          postalCode: checkout.postalCodeController.text,
          province: checkout.provinceController.text,
          country: checkout.countryController.text,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleNextAction(CartController cart, CheckoutController checkout) {
    if (checkout.currentStep == 0) {
      _validateAndProceed(checkout);
    } else if (checkout.currentStep < 2) {
      checkout.nextStep();
    } else {
      _finalizeOrder(cart, checkout);
    }
  }

  void _validateAndProceed(CheckoutController checkout) {
    checkout.resetErrors();

    // 1. Street
    final streetErr = AaliyahValidator.validateStreetAddress(checkout.streetController.text);
    if (streetErr != null) {
      checkout.setStreetError(true);
      _showToastFromError(streetErr);
      return;
    }

    // 2. City
    final cityErr = AaliyahValidator.validateCity(checkout.cityController.text);
    if (cityErr != null) {
      checkout.setCityError(true);
      _showToastFromError(cityErr);
      return;
    }

    // 3. Postal Code
    final postalErr = AaliyahValidator.validatePostalCode(checkout.postalCodeController.text);
    if (postalErr != null) {
      checkout.setPostalError(true);
      _showToastFromError(postalErr);
      return;
    }

    // 4. Province
    final provinceErr = AaliyahValidator.validateProvince(checkout.provinceController.text);
    if (provinceErr != null) {
      checkout.setProvinceError(true);
      _showToastFromError(provinceErr);
      return;
    }

    // 5. Delivery Date
    if (checkout.selectedDeliveryDate == null) {
      checkout.setDateError(true);
      _showToast(aaliyahEmptyFieldTitle, 'Please select Preferred Delivery Date!');
      return;
    }

    // 6. Delivery Time
    if (checkout.selectedDeliveryTime == null) {
      checkout.setTimeError(true);
      _showToast(aaliyahEmptyFieldTitle, 'Please select Preferred Delivery Time!');
      return;
    }

    checkout.nextStep();
  }

  void _showToastFromError(String errorMsg) {
    String errorMessage = errorMsg;
    String title = 'Validation Error';

    if (errorMessage.contains('! ')) {
      final List<String> parts = errorMessage.split('! ');
      title = '${parts[0]}!';
      errorMessage = parts.sublist(1).join('! ');
      if (title == 'Empty Field!') title = aaliyahEmptyFieldTitle;
    }
    _showToast(title, errorMessage);
  }

  void _showToast(String title, String message, {bool isError = true}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(title),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  Future<void> _finalizeOrder(CartController cart, CheckoutController checkout) async {
    final user = context.read<UserController>().user;
    
    // 1. Place order via controller
    final orderId = await checkout.placeOrder(
      items: cart.cart,
      totalAmount: cart.totalPrice(),
      userInfo: {
        'firstName': user?.firstName ?? 'Customer',
        'lastName': user?.lastName ?? '',
        'email': (user?.email ?? 'anonymous').toLowerCase(),
      },
      showToast: (t, m, e) => _showToast(t, m, isError: e),
    );

    if (orderId != null) {
      // 2. Notify Success
      _notifySuccess(cart, orderId, checkout.selectedPaymentIndex == 0 ? 'Cash on Delivery' : 'Stripe');
      
      // 3. Navigate
      _navigateSuccess(cart, checkout, orderId);
    }
  }

  void _notifySuccess(CartController cart, String orderId, String method) {
    final List<NotificationOrderItem> notifItems = cart.cart.map((e) => NotificationOrderItem(
      categoryName: e.categoryName ?? e.displayName,
      productImage: e.image,
      quantity: e.quantity,
      price: e.priceDouble,
    )).toList();

    context.read<NotificationController>().addNotification(
      "Aaliyah's Collection",
      'Your order #$orderId has been placed successfully!', 
      orderId: orderId,
      totalAmount: cart.totalPrice(),
      paymentMethod: method,
      orderItems: notifItems,
    );
  }

  void _navigateSuccess(CartController cart, CheckoutController checkout, String orderId) {
    final String amount = cart.formattedTotalPrice;
    final List<dynamic> items = cart.cart.map((item) => {
      'title': item.displayName,
      'quantity': item.quantity,
      'price': item.price,
    }).toList();
    final String email = context.read<UserController>().user?.email ?? 'customer@example.com';
    final paymentMethod = checkout.selectedPaymentIndex == 0 ? 'Cash on Delivery' : 'Stripe';
    
    // Store variables before clearing
    final address = checkout.streetController.text;
    final city = checkout.cityController.text;
    final state = checkout.provinceController.text;
    final date = checkout.selectedDeliveryDate;
    final time = checkout.selectedDeliveryTime;

    cart.clearCart();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          orderAmount: amount,
          orderId: orderId,
          items: items,
          email: email,
          paymentMethod: paymentMethod,
          address: address,
          city: city,
          state: state,
          deliveryDate: date,
          deliveryTime: time,
        ),
      ),
      (route) => false,
    );
  }
}
