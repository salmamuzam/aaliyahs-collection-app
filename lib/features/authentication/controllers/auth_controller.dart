import 'package:aaliyahs_collection_estore/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This controller handles user authentication using Provider pattern
// Supports multiple authentication methods:
// 1. Email/Username + Password (Laravel API)
// 2. Google Sign-In (Firebase)
// 3. Two-Factor Authentication (2FA)


class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();  
  bool _isLoading = false;  

  // Get current logged-in user from Firebase
  User? get currentUser => FirebaseAuth.instance.currentUser;
  
  // Stream that notifies when user logs in/out
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();
  

  bool get isLoading => _isLoading;
  bool get isAuthenticated => currentUser != null;  // True if user is logged in

  // Update loading state and notify UI
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();  
  }

  // ============================================================================
  // LOGIN - Email/Username + Password
  // ============================================================================
  Future<Map<String, dynamic>> login(String login, String password) async {
    setLoading(true);  // Show loading indicator
    try {
      // Call Laravel API to authenticate user
      final response = await _authRepository.login(login: login, password: password);
      setLoading(false);  // Hide loading indicator
      
      // Check if login was successful
      if (response.success && response.data != null) {
        return {'status': 'success', 'data': response.data!['data']};
      } else {
        // Check if 2FA is required
        if (response.statusCode == '422' && response.data != null) {
          if (response.data!['data'] != null && response.data!['data']['two_factor_required'] == true) {
             return {'status': '2fa_required', 'message': 'Two factor authentication required'};
          }
        }
        // Login failed
        return {'status': 'error', 'message': response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      // Return error if something went wrong 
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }

  // ============================================================================
  // REGISTER - Create New Account
  // ============================================================================
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    setLoading(true);  // Show loading indicator
    try {
      // Call Laravel API to create new user account
      final response = await _authRepository.register(
        firstName,
        lastName,
        username,
        email,
        password,
        passwordConfirmation,
      );
      setLoading(false);  // Hide loading indicator
      
      // Check if registration was successful
      if (response.success) {
        return {'status': 'success', 'message': response.data?['message'] ?? 'Account created'};
      } else {
        // Registration failed 
        return {'status': 'error', 'message': response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // ============================================================================
  // GOOGLE SIGN-IN - Firebase Authentication
  // ============================================================================
  Future<Map<String, dynamic>> signInWithGoogle() async {
    setLoading(true);  // Show loading indicator
    
    // Call repository to handle Google Sign-In flow
    final result = await _authRepository.signInWithGoogle();
    
    setLoading(false);  // Hide loading indicator
    notifyListeners();  // Update UI with new auth state
    return result;
  }

  // ============================================================================
  // TWO-FACTOR AUTHENTICATION (2FA) - Verify Code
  // ============================================================================
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String login,
    required String password,
    required String code,  // The 6-digit code from authenticator app
  }) async {
    setLoading(true);  // Show loading indicator
    try {
      // Call Laravel API with 2FA code
      final response = await _authRepository.login(
        login: login,
        password: password,
        twoFactorCode: code,  // Include the verification code
      );
      setLoading(false);  // Hide loading indicator
      
      // Check if 2FA verification was successful
      if (response.success && response.data != null) {
        return {'status': 'success', 'data': response.data!['data']};
      } else {
        // Wrong code or expired
        return {'status': 'error', 'message': response.statusMessage};
      }
    } catch (e) {
      setLoading(false);
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // ============================================================================
  // ANONYMOUS SIGN-IN - Guest Mode
  // ============================================================================
  // Allows users to browse the app without creating an account
  Future<void> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      notifyListeners();  // Update UI to show user is logged in as guest
    } catch (e) {
      debugPrint('Anonymous Auth Error: $e');
    }
  }

  // ============================================================================
  // LOGOUT - Sign Out User
  // ============================================================================
  // Logs out from both Laravel API and Firebase
  Future<void> logout() async {
    await _authRepository.logout();  // Clear tokens and sign out
    notifyListeners();  // Update UI to show user is logged out
  }

  // Biometric methods
  Future<String?> getBioEmail() => _authRepository.getBioEmail();
  Future<String?> getBioPassword() => _authRepository.getBioPassword();
}
