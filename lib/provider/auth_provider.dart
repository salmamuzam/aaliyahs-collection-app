import 'package:aaliyahs_collection_estore/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String login, String password) async {
    setLoading(true);
    try {
      final result = await _authService.login(login: login, password: password);
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<http.Response> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setLoading(true);
    try {
      final response = await AuthService.register(
        firstName,
        lastName,
        username,
        email,
        password,
        passwordConfirmation,
      );
      setLoading(false);
      return response;
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyTwoFactor({
    required String login,
    required String password,
    required String code,
  }) async {
    setLoading(true);
    try {
      final result = await _authService.login(
        login: login,
        password: password,
        twoFactorCode: code,
      );
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
