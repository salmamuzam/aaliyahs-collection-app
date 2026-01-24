
import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/custom_text_field.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/order_summary.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:aaliyahs_collection_estore/services/order_service.dart';
import 'package:aaliyahs_collection_estore/src/constants/text_strings.dart';
import 'package:aaliyahs_collection_estore/provider/notification_provider.dart';
import 'package:aaliyahs_collection_estore/provider/address_provider.dart';
import 'package:aaliyahs_collection_estore/utils/helpers/responsive_helper.dart';
import 'package:aaliyahs_collection_estore/services/notification_service.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  // Delivery Details Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  // Card Controllers (Visual Only for now, but wired up)
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _cashOnDelivery = true; // Default to Card (false) or COD (true)? snippet has card checked. I'll default to Card (false) to match snippet, but current app default was COD. I'll stick to snippet default: Card.
  // Actually snippet: id="card" checked.
  // But I'll default to COD (true) for safety/ease, or check snippet. Snippet has card checked.
  // I will default to false (Card) to match visual, but since strip logic is heavy, maybe COD is safer? 
  // User asked "LIKE THIS". I will default to Card (false).

  bool _isLocationLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cashOnDelivery = false; 
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final CartProvider cartProvider = Provider.of<CartProvider>(context);
    final CheckoutColors colors = CheckoutColors(isDarkMode);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), // Slate 900 or Slate 50
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Checkout",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.getPadding(context)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (Responsive.isMobile(context)) ...[
                OrderSummarySection(cartProvider: cartProvider, colors: colors),
                const SizedBox(height: 32),
                _buildDeliveryDetails(context, isDarkMode),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3, child: _buildDeliveryDetails(context, isDarkMode)),
                    const SizedBox(width: 32),
                    Expanded(
                        flex: 2,
                        child: OrderSummarySection(
                            cartProvider: cartProvider, colors: colors)),
                  ],
                ),
              ],
              const SizedBox(height: 32),

               // Payment Section
               PaymentMethodSection(
                 cashOnDelivery: _cashOnDelivery,
                 colors: colors,
                 onChanged: (val) {
                   setState(() {
                     if (val != null) _cashOnDelivery = val;
                   });
                 },
                 cardNameController: _cardNameController,
                 cardNumberController: _cardNumberController,
                 expiryController: _expiryController,
                 cvvController: _cvvController,
               ),
               const SizedBox(height: 32),

               // Action Buttons
               _buildActionButtons(context, cartProvider),
               const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Delivery Details",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                ),
              ),
            ),
             // Saved Address Button
            TextButton(
              onPressed: () => _showSavedAddressesPicker(context),
              child: const Text("Saved", style: TextStyle(fontSize: 12)),
            ),
             // Location Button
            TextButton.icon(
              onPressed: _isLocationLoading ? null : _useCurrentLocation,
              icon: _isLocationLoading 
                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location, size: 16),
              label: const Text("GPS", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(child: CustomTextField(label: "First Name", placeholder: "Enter First Name", controller: _firstNameController)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: "Last Name", placeholder: "Enter Last Name", controller: _lastNameController)),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(label: "Email", placeholder: "Enter Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        CustomTextField(label: "Phone No.", placeholder: "Enter Phone No.", controller: _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        CustomTextField(label: "Address Line", placeholder: "Enter Address Line", controller: _addressController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextField(label: "City", placeholder: "Enter City", controller: _cityController)),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: "State", placeholder: "Enter State", controller: _stateController)),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(label: "Zip Code", placeholder: "Enter Zip Code", controller: _zipController, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
         SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
               if (_formKey.currentState!.validate()) {
                  _placeOrder(context, cartProvider);
               }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB), // Blue-600
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
            child: const Text(
              "Complete Purchase",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const BottomNavBar()),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E7EB), // Gray-200
              foregroundColor: const Color(0xFF0F172A), // Slate-900
              side: const BorderSide(color: Color(0xFFD1D5DB)), // Gray-300
              padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
               elevation: 0,
            ),
            child: const Text(
              "Continue Shopping",
               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  // --- Logic Functionality ---

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Location permissions are denied';
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
           _showPermissionDialog();
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text = "${place.street ?? ''}, ${place.subLocality ?? ''}".replaceAll(RegExp(r'^, |,$'), '');
          if (_addressController.text.isEmpty) _addressController.text = place.thoroughfare ?? "";
          
          _cityController.text = place.locality ?? "";
          _stateController.text = place.administrativeArea ?? "";
          _zipController.text = place.postalCode ?? "";
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("Location permissions are permanently denied. Please open settings to enable them."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            }, 
            child: const Text("Open Settings")
          ),
        ],
      ),
    );
  }

  void _placeOrder(BuildContext context, CartProvider cartProvider) {
    if (!_cashOnDelivery) {
        // Stripe Payment Logic
        // Note: We are using the Stripe Sheet for actual processing, ignoring the visual fields for now to ensure security/functionality.
        _makePayment(cartProvider.totalPrice());
        return;
    }
    // COD Logic
    _storeOrder("Cash on Delivery", cartProvider.totalPrice());
    NotificationService.showOrderNotification(
      title: aaliyahOrderConfirmed,
      body: "Your COD order for Rs. ${cartProvider.totalPrice()} has been placed.",
    );
     if (mounted) {
       Provider.of<NotificationProvider>(context, listen: false).addNotification(
          aaliyahOrderConfirmed,
          "Your COD order for Rs. ${cartProvider.totalPrice()} has been placed.",
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
        await _storeOrder("Stripe (Paid)", cartProvider.totalPrice());
        
        NotificationService.showOrderNotification(
          title: aaliyahPaymentSuccess,
          body: "Your order for Rs. ${cartProvider.totalPrice()} is confirmed.",
        );

        if (mounted) {
          Provider.of<NotificationProvider>(context, listen: false).addNotification(
            aaliyahPaymentSuccess,
            "Your order for Rs. ${cartProvider.totalPrice()} is confirmed.",
          );
        }

        if (!mounted) return;
        _showSuccessAndNavigate(cartProvider, aaliyahPaymentSuccess);
      },
      onError: (err) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Error: $err")));
        }
      }
    );
  }

  Future<void> _storeOrder(String paymentMethod, double amount) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderData = {
      'date': DateTime.now().toIso8601String(),
      'amount': amount,
      'payment_method': paymentMethod,
      'status': 'Pending',
      'customer': {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'postalCode': _zipController.text,
      },
      'items': cartProvider.cart.map((item) => {
          'productId': item.id,
          'title': item.name,
          'quantity': item.quantity,
          'price': item.price,
          'image': item.image,
          'category': item.categoryName,
      }).toList(),
    };
    await OrderService().storeOrderInFirebase(orderData: orderData);
  }

  void _showSuccessAndNavigate(CartProvider cartProvider, String message) async {
    final String amount = cartProvider.formattedTotalPrice;
    cartProvider.clearCart();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(orderAmount: amount),
      ),
      (route) => false,
    );
  }

  void _showSavedAddressesPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<AddressProvider>(
        builder: (context, provider, child) {
          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text("No saved addresses.")),
            );
          }
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return ListTile(
                title: Text(addr['label'] ?? "Address"),
                subtitle: Text("${addr['address']}, ${addr['city']}"),
                onTap: () {
                  setState(() {
                    _addressController.text = addr['address'] ?? "";
                    _cityController.text = addr['city'] ?? "";
                    _stateController.text = addr['state'] ?? "";
                    _zipController.text = addr['zip'] ?? "";
                    _phoneController.text = addr['phone'] ?? "";
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
