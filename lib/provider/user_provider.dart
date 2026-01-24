import 'package:aaliyahs_collection_estore/src/features/authentication/models/user_model.dart';
import 'package:aaliyahs_collection_estore/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Manages user profile data, session tokens, and account-related operations.
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  /// The current logged-in user profile.
  UserModel? get user => _user;

  /// The active session token for API requests.
  String? get token => _token;

  /// Indicates if an authentication or profile operation is in progress.
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Fetches the current user's profile from the API with local caching.
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    try {
      // Try to load from Cache first (Offline Support)
      await _loadUserFromCache();
      
      final Map<String, dynamic> result = await _userService.getUserProfile();
      debugPrint("Profile Fetch Result: $result");
      
      if (result['status'] == 'success') {
        _token = await _userService.getStoredToken();
        _user = UserModel.fromJson(result['data']);
        await _cacheUser(result['data']);
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _cacheUser(Map<String, dynamic> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_cache', json.encode(data));
    } catch (e) {
       debugPrint("Cache User Error: $e");
    }
  }

  Future<void> _loadUserFromCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userStr = prefs.getString('user_cache');
      if (userStr != null) {
        _user = UserModel.fromJson(json.decode(userStr));
        _token = await _userService.getStoredToken();
        notifyListeners();
        debugPrint("Loaded User from Local Cache for Offline usage");
      }
    } catch (e) {
       debugPrint("Cache Load Error: $e");
    }
  }

  /// Updates the user's password.
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> result = await _userService.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes the current user's account.
  Future<Map<String, dynamic>> deleteAccount() async {
    _setLoading(true);
    try {
      final Map<String, dynamic> result = await _userService.deleteAccount();
      if (result['status'] == 'success') {
        _user = null;
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  /// Clears user data and token from local storage (Log out).
  Future<void> clearUser() async {
    _user = null;
    _token = null;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_cache');
    } catch (_) {}
    notifyListeners();
  }
}
