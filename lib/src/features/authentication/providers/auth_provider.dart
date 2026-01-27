import 'package:aaliyahs_collection_estore/src/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

/// Manages authentication flows including Login, Registration, 2FA, and Social Sign-In.
/// Follows "From Zero to Hero" best practices: Logic abstraction, Error mapping, and Identity monitoring.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
  bool get isLoading => _isLoading;
  bool get isAuthenticated => currentUser != null;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Authenticates a user using email/username and password via Laravel API.
  Future<Map<String, dynamic>> login(String login, String password) async {
    setLoading(true);
    try {
      final response = await _authService.login(login: login, password: password);
      setLoading(false);
      
      if (response.success && response.data != null) {
        return {"status": "success", "data": response.data!['data']};
      } else {
        if (response.statusCode == "422" && response.data != null) {
          if (response.data!['data'] != null && response.data!['data']['two_factor_required'] == true) {
             return {"status": "2fa_required", "message": "Two factor authentication required"};
          }
        }
        return {"status": "error", "message": response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }

  /// Registers a new user account via Laravel API.
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setLoading(true);
    try {
      final response = await _authService.register(
        firstName,
        lastName,
        username,
        email,
        password,
        passwordConfirmation,
      );
      setLoading(false);
      
      if (response.success) {
        return {'status': 'success', 'message': response.data?['message'] ?? 'Account created'};
      } else {
        return {'status': 'error', 'message': response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Initiates a Google Sign-In flow via Firebase.
  /// Logic abstracted to AuthService for modularity.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    setLoading(true);
    final result = await _authService.signInWithGoogle();
    setLoading(false);
    notifyListeners();
    return result;
  }

  /// Verifies the 2FA code via Laravel API.
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String login,
    required String password,
    required String code,
  }) async {
    setLoading(true);
    try {
      final response = await _authService.login(
        login: login,
        password: password,
        twoFactorCode: code,
      );
      setLoading(false);
      
      if (response.success && response.data != null) {
        return {"status": "success", "data": response.data!['data']};
      } else {
        return {"status": "error", "message": response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Initiate Anonymous Sign-In to allow guest interactions.
  Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      notifyListeners();
    } catch (e) {
      debugPrint("Anonymous Auth Error: $e");
    }
  }

  /// Signs the user out of all authentication services.
  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
