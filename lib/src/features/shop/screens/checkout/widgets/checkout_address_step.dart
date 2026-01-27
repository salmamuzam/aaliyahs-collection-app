import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/screens/checkout/widgets/checkout_address_field.dart';

class CheckoutAddressStep extends StatelessWidget {
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final bool isLocating;
  final VoidCallback onLocateMe;

  const CheckoutAddressStep({
    super.key,
    required this.streetController,
    required this.cityController,
    required this.provinceController,
    required this.postalCodeController,
    required this.countryController,
    required this.isLocating,
    required this.onLocateMe,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color highlightColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

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
          CheckoutAddressField(label: "Street Address", controller: streetController, icon: Icons.home_outlined),
          const SizedBox(height: 16),
          CheckoutAddressField(label: "City", controller: cityController, icon: Icons.location_city_outlined),
          const SizedBox(height: 16),
          CheckoutAddressField(label: "Postal Code", controller: postalCodeController, icon: Icons.markunread_mailbox_outlined),
          const SizedBox(height: 16),
          CheckoutAddressField(label: "Province", controller: provinceController, icon: Icons.map_outlined),
          const SizedBox(height: 16),
          CheckoutAddressField(label: "Country", controller: countryController, icon: Icons.flag_outlined, enabled: false),
          const SizedBox(height: 24),
          _buildLocateButton(highlightColor),
        ],
      ),
    );
  }

  Widget _buildLocateButton(Color highlightColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLocating ? null : onLocateMe,
        icon: isLocating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.my_location, color: highlightColor),
        label: Text(
          isLocating ? "Locating..." : "Use Current Location",
          style: TextStyle(color: highlightColor),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: highlightColor),
          foregroundColor: highlightColor,
        ),
      ),
    );
  }
}
