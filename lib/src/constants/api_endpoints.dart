class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = 'login';
  static const String register = 'register';
  static const String logout = 'logout';
  static const String changePassword = 'change-password';

  // User
  static const String userProfile = 'user';
  static const String updateProfile = 'user/update-profile';
  static const String deleteAccount = 'user/delete-account';

  // Products
  static const String home = 'home';
  static const String bestSelling = 'products/best-selling';
  static const String categories = 'categories';
  static const String shop = 'shop';

  // Addresses
  static const String addresses = 'addresses';
}
