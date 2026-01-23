import 'package:aaliyahs_collection_estore/src/features/authentication/models/user_model.dart';
import 'package:aaliyahs_collection_estore/services/user_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    _setLoading(true);
    try {
      final result = await _userService.getUserProfile();
      debugPrint("Profile Fetch Result: $result");
      if (result['status'] == 'success') {
        _token = await _userService.getStoredToken();
        _user = UserModel.fromJson(result['data']);
        debugPrint("Photo URL: ${_user?.profilePhotoUrl}");
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    try {
      final result = await _userService.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return result;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    _setLoading(true);
    try {
      final result = await _userService.deleteAccount();
      if (result['status'] == 'success') {
        _user = null;
      }
      return result;
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
