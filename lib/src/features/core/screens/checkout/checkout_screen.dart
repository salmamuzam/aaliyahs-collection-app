


import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/services/order_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:toastification/toastification.dart';
import 'package:aaliyahs_collection_estore/provider/notification_provider.dart';
import 'package:aaliyahs_collection_estore/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
// import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/order_success_screen.dart'; // No longer needed
import 'package:quickalert/quickalert.dart';
import 'package:aaliyahs_collection_estore/bottom_nav.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Delivery Details Controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: "Sri Lanka");

  int _currentStep = 0; // 0: Address, 1: Payment, 2: Summary
  int _selectedPaymentIndex = 0; // 0: COD, 1: Stripe/Card
  bool _isLocating = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final CartProvider cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AppBar(
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildProgressBar(context, isDarkMode),
          Expanded(
            child: _buildStepContent(context, cartProvider, isDarkMode),
          ),
          _buildBottomButton(context, cartProvider, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, bool isDarkMode) {
    final activeColor = aaliyahPrimaryColor;
    final inactiveColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      child: Row(
        children: [
          _buildProgressNode(0, Icons.location_on_outlined, "Address", activeColor, inactiveColor),
          _buildProgressLine(0, activeColor, inactiveColor),
          _buildProgressNode(1, Icons.credit_card_outlined, "Payment", activeColor, inactiveColor),
          _buildProgressLine(1, activeColor, inactiveColor),
          _buildProgressNode(2, Icons.assignment_outlined, "Summary", activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildProgressNode(int index, IconData icon, String label, Color active, Color inactive) {
    bool isActive = _currentStep >= index;
    Color color = isActive ? active : inactive;

    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildProgressLine(int index, Color active, Color inactive) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          height: 2,
          color: _currentStep > index ? active : inactive,
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, CartProvider cartProvider, bool isDarkMode) {
    switch (_currentStep) {
      case 0:
        return _buildAddressStep(context, isDarkMode);
      case 1:
        return _buildPaymentStep(context, isDarkMode);
      case 2:
        return _buildSummaryStep(context, cartProvider, isDarkMode);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddressStep(BuildContext context, bool isDarkMode) {
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildAddressField("Street Address", _streetController, Icons.home_outlined, isDarkMode),
          const SizedBox(height: 16),
          _buildAddressField("City", _cityController, Icons.location_city_outlined, isDarkMode),
          const SizedBox(height: 16),
          _buildAddressField("Province", _provinceController, Icons.map_outlined, isDarkMode),
          const SizedBox(height: 16),
          _buildAddressField("Country", _countryController, Icons.flag_outlined, isDarkMode, enabled: false),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLocating ? null : _getCurrentLocation,
              icon: _isLocating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: Text(_isLocating ? "Locating..." : "Use Current Location"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: aaliyahPrimaryColor),
                foregroundColor: aaliyahPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField(String label, TextEditingController controller, IconData icon, bool isDarkMode, {bool enabled = true}) {
    final darkGrey = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkGrey),
        prefixIcon: Icon(icon, color: aaliyahPrimaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: aaliyahPrimaryColor),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _streetController.text = "${place.street ?? ''} ${place.subLocality ?? ''}".trim();
          _cityController.text = place.locality ?? '';
          _provinceController.text = place.administrativeArea?? '';
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

  Widget _buildPaymentStep(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Methods",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildPaymentCard(0, "Cash on Delivery", "Pay when you receive", Icons.payments_outlined, isDarkMode),
          _buildPaymentCard(1, "Credit/Debit Card", "Pay securely with Stripe", Icons.credit_card_outlined, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(int index, String title, String subtitle, IconData icon, bool isDarkMode) {
    bool isSelected = _selectedPaymentIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedPaymentIndex = index;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? aaliyahPrimaryColor : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? aaliyahPrimaryColor : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off,
              color: isSelected ? aaliyahPrimaryColor : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStep(BuildContext context, CartProvider cartProvider, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Item Details",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          ...cartProvider.cart.map((item) => _buildSummaryItemCard(item, isDarkMode)),
          const SizedBox(height: 24),
          Text(
            "Delivery Address",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Shipping to:", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text("${_streetController.text}, ${_cityController.text}", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
                Text("${_provinceController.text}, ${_countryController.text}", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Price Summary (Total Only)
          _buildPriceRow("Total", cartProvider.formattedTotalPrice, isDarkMode, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryItemCard(Product item, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image.startsWith('http')
                ? CachedNetworkImage(imageUrl: item.image, width: 60, height: 60, fit: BoxFit.cover, alignment: Alignment.topCenter)
                : Image.asset(item.image, width: 60, height: 60, fit: BoxFit.cover, alignment: Alignment.topCenter),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.displayName, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text("QTY: ${item.quantity}", style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text("Rs. ${item.price}", style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDarkMode, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, CartProvider cartProvider, bool isDarkMode) {
    String label = "";
    switch (_currentStep) {
      case 0:
        label = "Next: Payment";
        break;
      case 1:
        label = "Next: Summary";
        break;
      case 2:
        label = _selectedPaymentIndex == 0 ? "Place Order" : "Pay Now";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? aaliyahDarkColor : Colors.white,
        border: Border(top: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _placeOrder(context, cartProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: aaliyahPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  // --- Logic Functionality ---

  void _placeOrder(BuildContext context, CartProvider cartProvider) {
    // For simplicity in this UI redesign, we use the values from the controllers
    
    if (_selectedPaymentIndex == 1) {
      // Stripe Payment Logic
      _makePayment(cartProvider.totalPrice());
      return;
    }
    // COD Logic
    final orderId = await _storeOrder("Cash on Delivery", cartProvider.totalPrice());
    
    // Notifications
    // NotificationService.showOrderNotification(...) // Keeping local notification simpler or updated
    
    if (mounted) {
      final notifItems = cartProvider.cart.map((e) => NotificationOrderItem(
        productName: e.displayName,
        productImage: e.image,
        quantity: e.quantity,
        price: double.tryParse(e.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      )).toList();

      final now = DateTime.now();
      final dateStr = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      Provider.of<NotificationProvider>(context, listen: false).addNotification(
        "Your Order ${orderId ?? '#001'} has been placed successfully!",
        "Placed on $dateStr",
        orderId: orderId,
        totalAmount: cartProvider.totalPrice(),
        paymentMethod: "Cash on Delivery",
        orderItems: notifItems,
      );
    }

    _showSuccessAndNavigate(cartProvider, "Order Placed Successfully!");
  }

  Future<void> _makePayment(double amount) async {
    await OrderService().processStripePayment(
        amount: amount,
        currency: 'LKR',
        onSuccess: () async {
          final cartProvider = Provider.of<CartProvider>(context, listen: false);
          final orderId = await _storeOrder("Stripe (Paid)", cartProvider.totalPrice());

          /* NotificationService.showOrderNotification(
            title: "Your Order ${orderId ?? ''} has been placed successfully!",
            body: "Order is being processed.",
          ); */

          if (mounted) {
             final notifItems = cartProvider.cart.map((e) => NotificationOrderItem(
                productName: e.displayName,
                productImage: e.image,
                quantity: e.quantity,
                price: double.tryParse(e.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
              )).toList();

            final now = DateTime.now();
            final dateStr = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

            Provider.of<NotificationProvider>(context, listen: false).addNotification(
              "Your Order ${orderId ?? '#001'} has been placed successfully!", 
              "Placed on $dateStr",
              orderId: orderId,
              totalAmount: cartProvider.totalPrice(),
              paymentMethod: "Stripe (Paid)",
              orderItems: notifItems,
            );
          }

          if (!mounted) return;
          _showSuccessAndNavigate(cartProvider, aaliyahPaymentSuccess);
        },
        onError: (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error: $err")));
          }
        });
  }

  Future<String?> _storeOrder(String paymentMethod, double amount) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderData = {
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'status': 'Pending',
      'customer': {
        'address': _streetController.text,
        'city': _cityController.text,
        'state': _provinceController.text,
        'country': _countryController.text,
      },
      'items': cartProvider.cart
          .map((item) => {
                'productId': item.id,
                'title': item.displayName,
                'quantity': item.quantity,
                'price': item.price,
                'image': item.image,
                'category': item.categoryName,
              })
          .toList(),
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
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? aaliyahDarkColor : Colors.white,
      titleColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      textColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      onConfirmBtnTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
          (route) => false,
        );
      },
    );
  }
}
