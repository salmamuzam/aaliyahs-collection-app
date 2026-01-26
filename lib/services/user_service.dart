import 'dart:convert';
import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Public getter for token
  Future<String?> getStoredToken() async {
    return await _getToken();
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    var url = Uri.parse('$baseURL/user');
    String? token = await _getToken();

    if (token == null) {
      return {"status": "error", "message": "No token found"};
    }

    Map<String, String> authHeaders = Map.from(headers);
    authHeaders['Authorization'] = 'Bearer $token';

    try {
      http.Response response = await http.get(url, headers: authHeaders);
      debugPrint("Raw User Profile Response: ${response.body}");
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {"status": "success", "data": responseData['data']};
      } else {
        return {"status": "error", "message": responseData['message'] ?? "Failed to fetch profile"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    var url = Uri.parse('$baseURL/user/update-profile');
    String? token = await _getToken();

    if (token == null) {
      return {"status": "error", "message": "No token found"};
    }

    Map<String, String> authHeaders = Map.from(headers);
    authHeaders['Authorization'] = 'Bearer $token';

    Map data = {
      "first_name": firstName,
      "last_name": lastName,
    };

    try {
      http.Response response = await http.put( // Or POST depending on API
        url,
        headers: authHeaders,
        body: json.encode(data),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {"status": "success", "data": responseData['data'], "message": responseData['message']};
      } else {
        return {"status": "error", "message": responseData['message'] ?? "Failed to update profile"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Change Password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    var url = Uri.parse('$baseURL/change-password');
    String? token = await _getToken();

    if (token == null) {
      return {"status": "error", "message": "No token found"};
    }

    Map<String, String> authHeaders = Map.from(headers);
    authHeaders['Authorization'] = 'Bearer $token';

    Map data = {
      "current_password": currentPassword,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    try {
      http.Response response = await http.post(
        url,
        headers: authHeaders,
        body: json.encode(data),
      );
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {"status": "success", "message": responseData['message'] ?? "Password changed successfully"};
      } else {
        return {"status": "error", "message": responseData['message'] ?? "Failed to change password"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount() async {
    var url = Uri.parse('$baseURL/user/delete-account');
    String? token = await _getToken();

    if (token == null) {
      return {"status": "error", "message": "No token found"};
    }

    Map<String, String> authHeaders = Map.from(headers);
    authHeaders['Authorization'] = 'Bearer $token';

    try {
      http.Response response = await http.delete(url, headers: authHeaders);
      if (response.statusCode == 200) {
        await _storage.delete(key: 'token');
        return {"status": "success", "message": "Account deleted successfully"};
      } else {
        var responseData = json.decode(response.body);
        return {"status": "error", "message": responseData['message'] ?? "Failed to delete account"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
