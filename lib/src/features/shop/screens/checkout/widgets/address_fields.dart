import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/utils/validators/validator.dart';
import 'package:flutter/material.dart';

// Address Fields for Checkout

class AddressInfoFields extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final String? selectedProvince;
  final List<String> provinces;
  final CheckoutColors colors;
  final bool isDesktop;
  final Function(String?) onProvinceChanged;
  final VoidCallback onUseLocation;
  final bool isLocationLoading;

  const AddressInfoFields({
    super.key,
    required this.addressController,
    required this.cityController,
    required this.postalCodeController,
    required this.selectedProvince,
    required this.provinces,
    required this.colors,
    required this.isDesktop,
    required this.onProvinceChanged,
    required this.onUseLocation,
    required this.isLocationLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: isLocationLoading ? null : onUseLocation,
            icon: isLocationLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.my_location),
            label: const Text("Use Current Location"),
            style: TextButton.styleFrom(
              foregroundColor: colors.primaryColor,
            ),
          ),
        ),
        TextFormField(
          controller: addressController,
          maxLines: 2,
          style: TextStyle(color: colors.textColor),
          decoration: _buildInputDecoration(
            "Street Address",
            Icons.home_outlined,
            colors,
          ),
          validator: AaliyahValidator.validateRequiredField,
        ),
        const SizedBox(height: 12),

        if (isDesktop)
          Row(
            children: [
              Expanded(child: _buildCityField()),
              const SizedBox(width: 12),
              Expanded(child: _buildPostalCodeField()),
            ],
          )
        else
          Column(
            children: [
              _buildCityField(),
              const SizedBox(height: 12),
              _buildPostalCodeField(),
            ],
          ),
        const SizedBox(height: 12),

        _buildProvinceDropdown(),
      ],
    );
  }

  Widget _buildCityField() {
    return TextFormField(
      controller: cityController,
      style: TextStyle(color: colors.textColor),
      decoration: _buildInputDecoration(
        "City",
        Icons.location_city_outlined,
        colors,
      ),
      validator: AaliyahValidator.validateRequiredField,
    );
  }

  Widget _buildPostalCodeField() {
    return TextFormField(
      controller: postalCodeController,
      keyboardType: TextInputType.number,
      style: TextStyle(color: colors.textColor),
      decoration: _buildInputDecoration(
        "Postal Code",
        Icons.numbers_outlined,
        colors,
      ),
      validator: AaliyahValidator.validatePostalCode,
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedProvince,
      style: TextStyle(color: colors.textColor),
      decoration: InputDecoration(
        labelText: "Select Province",
        labelStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.7)),
        prefixIcon: Icon(
          Icons.map_outlined,
          color: colors.textColor.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: colors.surfaceColor,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      dropdownColor: colors.surfaceColor,
      icon: Icon(Icons.arrow_drop_down, color: colors.textColor),
      items: provinces.map((String province) {
        return DropdownMenuItem<String>(
          value: province,
          child: Text(province, style: TextStyle(color: colors.textColor)),
        );
      }).toList(),
      onChanged: onProvinceChanged,
      validator: (value) => value == null ? 'Please select a province' : null,
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    CheckoutColors colors,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.textColor.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: colors.textColor.withValues(alpha: 0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primaryColor, width: 2),
      ),
      filled: true,
      fillColor: colors.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.red),
    );
  }
}
