import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool isOutlined;


  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.isOutlined = false,
    this.textInputAction,
    this.onFieldSubmitted,
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
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: iconColor),
        suffixIcon: suffixIcon,
        filled: !isOutlined,
        fillColor: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        border: isOutlined
            ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey))
            : OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: isOutlined
            ? OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400))
            : OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFFE5EDEF) : const Color(0xFF0F172A), // Slate-900 or Primary
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
