import 'package:aaliyahs_collection_estore/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Manages authentication flows including Login, Registration, 2FA, and Social Sign-In.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  /// Indicates if an authentication operation (login/register/google) is in progress.
  bool get isLoading => _isLoading;

  /// Updates the loading state and notifies listeners.
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Authenticates a user using email/username and password.
  Future<Map<String, dynamic>> login(String login, String password) async {
    setLoading(true);
    try {
      final Map<String, dynamic> result = await _authService.login(login: login, password: password);
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }

  /// Registers a new user account.
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
      final http.Response response = await AuthService.register(
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

  /// Verifies a 2FA code during the login process.
  Future<Map<String, dynamic>> verifyTwoFactor({
    required String login,
    required String password,
    required String code,
  }) async {
    setLoading(true);
    try {
      final Map<String, dynamic> result = await _authService.login(
        login: login,
        password: password,
        twoFactorCode: code,
      );
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }

  /// Signs the user out of all authentication services.
  Future<void> logout() async {
    await _authService.logout();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  /// Initiates a Google Sign-In flow.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setLoading(false);
        return <String, dynamic>{'status': 'cancelled'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      setLoading(false);

      if (user != null) {
        return <String, dynamic>{
          'status': 'success',
          'email': user.email,
          'name': user.displayName,
          'photo': user.photoURL,
          'firebase_uid': user.uid
        };
      } else {
        return <String, dynamic>{'status': 'error', 'message': 'Google Sign In Failed'};
      }
    } catch (e) {
      setLoading(false);
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }
}
