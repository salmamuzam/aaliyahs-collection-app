import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class CheckoutAddressField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;

  const CheckoutAddressField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color darkGrey = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final Color focusColor = isDarkMode ? const Color(0xFFE5EDEF) : aaliyahPrimaryColor;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: darkGrey),
        floatingLabelStyle: TextStyle(color: focusColor),
        prefixIcon: Icon(icon, color: focusColor),
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
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }
}
