// This file contains validations for login, signup, and checkout screen
class AaliyahValidator {
  // First Name

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return "First Name is required!";
    }

    if (value.contains(RegExp(r'[0-9]'))) {
      return "First Name must contain only letters!";
    }
    return null;
  }

  // Last name

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return "Last Name is required!";
    }

    if (value.contains(RegExp(r'[0-9]'))) {
      return "Last Name must contain only letters!";
    }
    return null;
  }

  // Email

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required!";
    }

    // Standard email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return "Invalid email address!";
    }

    return null;
  }

  // Password

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required!";
    }

    // Check for minimum password length
    if (value.length < 6) {
      return "Password must be at least 6 characters long!";
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return "Password must contain at least one uppercase letter!";
    }

    // Check for number
    if (!value.contains(RegExp(r'\d'))) {
      return "Password must contain at least one number!";
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}<>]'))) {
      return "Password must contain at least one special character!";
    }

    return null;
  }

  // Phone Number

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only numbers';
    }
    return null;
  }

  // For the provinces (Drop Down)

  static String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Postal Code

  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Postal code must contain only numbers';
    }
    return null;
  }
}
