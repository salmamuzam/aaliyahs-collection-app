import 'package:aaliyahs_collection_estore/data/models/user_model.dart';
import 'package:aaliyahs_collection_estore/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Manages user profile data, session tokens, and account-related operations.
class UserController extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
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
      
      final response = await _userRepository.getUserProfile();
      debugPrint("Profile Fetch Result: ${response.data}");
      
      if (response.success && response.data != null) {
        _token = await _userRepository.getStoredToken();
        
        final dynamic rawData = response.data!;
        // Robust parsing: Check for nested 'data' or 'user' keys common in Laravel Resources
        final Map<String, dynamic> userMap;
        if (rawData['data'] != null && rawData['data'] is Map) {
             userMap = rawData['data'];
        } else if (rawData['user'] != null && rawData['user'] is Map) {
             userMap = rawData['user'];
        } else {
             userMap = rawData;
        }
        
        _user = UserModel.fromJson(userMap);
        await _cacheUser(userMap);
        notifyListeners();
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
      await prefs.setString('user_email', data['email'] ?? ''); // Save email for offline lookup
    } catch (e) {
       debugPrint("Cache User Error: $e");
    }
  }

  Future<void> _loadUserFromCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userStr = prefs.getString('user_cache');
      
      if (userStr != null) {
        final Map<String, dynamic> data = json.decode(userStr);
        final user = UserModel.fromJson(data);
        
        // STALE DATA CHECK: If cache has old 'salma.jpg' path, ignore it and reload from JSON
        if (user.profilePhotoUrl.contains('salma.jpg') || user.profilePhotoUrl.contains('fathima.jpg')) {
           debugPrint("⚠️ Stale image path found in cache, reloading from local user.json...");
           await _loadUserFromLocalJSON();
           return;
        }

        _user = user;
        _token = await _userRepository.getStoredToken();
        notifyListeners();
        debugPrint("✅ Loaded User from SharedPreferences Cache");
        return;
      }
      
      // If no cache, try to load from local JSON (Offline Fallback)
      debugPrint("📦 No cache found, attempting to load from local user.json...");
      await _loadUserFromLocalJSON();
      
    } catch (e) {
       debugPrint("Cache Load Error: $e");
       // Final fallback: Try local JSON
       await _loadUserFromLocalJSON();
    }
  }

  /// Load user from local JSON file (assets/data/user.json)
  /// Used for offline support when no cache is available
  Future<void> _loadUserFromLocalJSON() async {
    try {
      final String response = await rootBundle.loadString('assets/data/user.json');
      final List<dynamic> users = json.decode(response);
      
      // Matched with stored email from cache if available
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String storedEmail = prefs.getString('user_email') ?? 'salma@gmail.com'; // Default for test
      
      if (users.isNotEmpty) {
        // Find user by email
        final userJson = users.firstWhere(
          (u) => u['email'] == storedEmail,
          orElse: () => users.first, 
        );
        _user = UserModel.fromJson(userJson);
        
        // IMPORTANT: Update cache with the fresh local data so we don't keep hitting this fallback
        await _cacheUser(userJson);
        
        debugPrint("✅ Loaded User from local user.json: ${_user?.email}");
        notifyListeners();
      }
    } catch (e) {
       debugPrint("❌ Error loading user from local JSON: $e");
    }
  }

  /// Updates user profile details.
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    try {
      final response = await _userRepository.updateProfile(firstName: firstName, lastName: lastName);
      if (response.success) {
        // Refresh profile to update local state
        await fetchUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      return false;
    } finally {
      _setLoading(false);
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
      final response = await _userRepository.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // Map ApiResponse to the expected return type if needed, 
      // but for now let's just return a map if the consumer expects it, 
      // or better, change the consumer to expect ApiResponse.
      // The diagnostic said "A value of type 'ApiResponse<Map<String, dynamic>>' can't be assigned to a variable of type 'Map<String, dynamic>'."
      // Let's return the response object or its map representation.
      return {
        'status': response.success ? 'success' : 'error',
        'message': response.statusMessage,
        'data': response.data,
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes the current user's account.
  Future<Map<String, dynamic>> deleteAccount() async {
    _setLoading(true);
    try {
      final response = await _userRepository.deleteAccount();
      if (response.success) {
        _user = null;
      }
      return {
        'status': response.success ? 'success' : 'error',
        'message': response.statusMessage,
        'data': response.data,
      };
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
