import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/validators/validator.dart';
import 'package:flutter/material.dart';

// Personal Information needed to checkout

class PersonalInfoFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final CheckoutColors colors;
  final bool isDesktop;

  const PersonalInfoFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.colors,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildFirstNameField()),
          const SizedBox(width: 12),
          Expanded(child: _buildLastNameField()),
        ],
      );
    } else {
      return Column(
        children: [
          _buildFirstNameField(),
          const SizedBox(height: 12),
          _buildLastNameField(),
        ],
      );
    }
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: firstNameController,
      style: TextStyle(color: colors.textColor),
      decoration: _buildInputDecoration(
        "First Name",
        Icons.person_outline,
        colors,
      ),
      validator: AaliyahValidator.validateFirstName,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: lastNameController,
      style: TextStyle(color: colors.textColor),
      decoration: _buildInputDecoration(
        "Last Name",
        Icons.person_outline,
        colors,
      ),
      validator: AaliyahValidator.validateLastName,
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
