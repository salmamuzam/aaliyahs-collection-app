import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDarkMode ? const Color(0xFFE5EDEF) : Colors.grey;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: iconColor),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        focusedBorder: isDarkMode
            ? const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5EDEF), width: 2.0))
            : null,
      ),
    );
  }
}
