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

  // ProductModels
  static const String home = 'home';
  static const String bestSelling = 'products/best-selling';
  static const String categories = 'categories';
  static const String shop = 'shop';

  // GitHub Hosted API
  static const String githubApiBase = 'https://salmamuzam.github.io/ecommerce_api/';
  static const String githubProductModels = 'product.json';
  static const String githubCategories = 'category.json';
  static const String githubUsers = 'user.json';
  static const String githubReviews = 'review.json';

  // Addresses
  static const String addresses = 'addresses';
}
