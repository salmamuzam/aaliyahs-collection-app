import 'package:aaliyahs_collection_estore/bottom_nav.dart';
import 'package:aaliyahs_collection_estore/provider/cart_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/address_fields.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/delivery_preferences.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/order_summary.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/payment_method.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/personal_info.dart';
import 'package:aaliyahs_collection_estore/src/features/core/screens/checkout/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This is the main checkout screen
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? _selectedProvince;
  TimeOfDay? _selectedTime;
  bool _cashOnDelivery = true;

  final List<String> _provinces = [
    'Western Province',
    'Central Province',
    'Southern Province',
    'Northern Province',
    'Eastern Province',
    'North Western Province',
    'North Central Province',
    'Uva Province',
    'Sabaragamuwa Province',
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    final cartProvider = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    final colors = CheckoutColors(isDarkMode);

    return Scaffold(
      appBar: _buildAppBar(context, colors),
      backgroundColor: colors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderSummarySection(cartProvider: cartProvider, colors: colors),
              const SizedBox(height: 24),
              _buildCheckoutForm(cartProvider, colors, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, CheckoutColors colors) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: colors.textColor),
      ),
      title: Text(
        "Checkout",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: colors.textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: colors.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textColor),
    );
  }

  Widget _buildCheckoutForm(
    CartProvider cartProvider,
    CheckoutColors colors,
    bool isDesktop,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalInfoSection(colors, isDesktop),
          const SizedBox(height: 24),
          _buildAddressInfoSection(colors, isDesktop),
          const SizedBox(height: 24),
          _buildDeliveryPreferencesSection(colors),
          const SizedBox(height: 24),
          _buildPaymentMethodSection(colors),
          const SizedBox(height: 40),
          _buildPlaceOrderButton(cartProvider, colors),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(CheckoutColors colors, bool isDesktop) {
    return _buildFormSection(
      title: "Personal Information",
      colors: colors,
      child: PersonalInfoFields(
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        colors: colors,
        isDesktop: isDesktop,
      ),
    );
  }

  Widget _buildAddressInfoSection(CheckoutColors colors, bool isDesktop) {
    return _buildFormSection(
      title: "Address Information",
      colors: colors,
      child: AddressInfoFields(
        addressController: _addressController,
        cityController: _cityController,
        postalCodeController: _postalCodeController,
        selectedProvince: _selectedProvince,
        provinces: _provinces,
        colors: colors,
        isDesktop: isDesktop,
        onProvinceChanged: (value) => setState(() => _selectedProvince = value),
      ),
    );
  }

  Widget _buildDeliveryPreferencesSection(CheckoutColors colors) {
    return _buildFormSection(
      title: "Delivery Preferences",
      colors: colors,
      child: DeliveryPreferencesSection(
        selectedTime: _selectedTime,
        colors: colors,
        onTimeSelected: () => _selectTime(context),
      ),
    );
  }

  Widget _buildPaymentMethodSection(CheckoutColors colors) {
    return _buildFormSection(
      title: "Payment Method",
      colors: colors,
      child: PaymentMethodSection(
        cashOnDelivery: _cashOnDelivery,
        colors: colors,
        onChanged: (value) => setState(() => _cashOnDelivery = value ?? true),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required CheckoutColors colors,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, colors: colors),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildPlaceOrderButton(
    CartProvider cartProvider,
    CheckoutColors colors,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _placeOrder(context, cartProvider);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: colors.primaryColor.withValues(alpha: 0.3),
        ),
        child: Text(
          "PLACE ORDER - Rs. ${cartProvider.totalPrice()}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;

        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: aaliyahPrimaryColor,
              onPrimary: Colors.white,
              surface: isDarkMode ? aaliyahDarkColor : aaliyahLightColor,
              onSurface: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDarkMode
                  ? aaliyahDarkColor
                  : aaliyahLightColor,
              hourMinuteTextColor: isDarkMode
                  ? aaliyahLightColor
                  : aaliyahDarkColor,
              hourMinuteColor: aaliyahPrimaryColor.withValues(alpha: 0.1),
              dayPeriodTextColor: isDarkMode
                  ? aaliyahLightColor
                  : aaliyahDarkColor,
              dayPeriodColor: aaliyahSecondaryColor.withValues(alpha: 0.1),
              dialBackgroundColor: isDarkMode
                  ? Color(0xFF2A2A2A)
                  : Color(0xFFF8F5F2),
              dialHandColor: aaliyahPrimaryColor,
              dialTextColor: isDarkMode ? aaliyahLightColor : aaliyahDarkColor,
              entryModeIconColor: aaliyahPrimaryColor,
              dayPeriodBorderSide: BorderSide(color: aaliyahSecondaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _placeOrder(BuildContext context, CartProvider cartProvider) {
    final snackBar = SnackBar(
      content: Text(
        "Order Placed Successfully! You will pay Rs. ${cartProvider.totalPrice()} on delivery.",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: aaliyahPrimaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    cartProvider.clearCart();

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
        (route) => false,
      );
    });
  }
}
