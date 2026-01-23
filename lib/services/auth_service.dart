import 'dart:convert';
import 'package:aaliyahs_collection_estore/src/constants/api_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Register
  static Future<http.Response> register(
    String firstname,
    String lastname,
    String username,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    Map data = {
      "first_name": firstname,
      "last_name": lastname,
      "username": username,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
    var body = json.encode(data);
    var url = Uri.parse('$baseURL/register');
    http.Response response = await http.post(url, headers: headers, body: body);
    return response;
  }

  // Login (Handles both Step 1 and Step 2)
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
    String? twoFactorCode,
  }) async {
    Map<String, dynamic> data = {
      "login": login,
      "password": password,
    };

    if (twoFactorCode != null) {
      data["two_factor_code"] = twoFactorCode;
    }

    var body = json.encode(data);
    var url = Uri.parse('$baseURL/login');
    
    debugPrint("Attempting login at: $url");
    debugPrint("Login Data: $data");

    http.Response response = await http.post(url, headers: headers, body: body);
    debugPrint("Login Response Status: ${response.statusCode}");
    debugPrint("Login Response Body: ${response.body}");

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      // Success: 2FA is OFF or Code was correct
      if (responseData['data'] != null && responseData['data']['token'] != null) {
        await _storage.write(key: 'token', value: responseData['data']['token']);
      }
      return {"status": "success", "data": responseData['data']};
    } else if (response.statusCode == 422) {
      // Validation error or 2FA required
      if (responseData['data'] != null && responseData['data']['two_factor_required'] == true) {
        return {"status": "2fa_required", "message": "Two factor authentication required"};
      }
      return {"status": "error", "message": responseData['message'] ?? "Validation Error"};
    } else {
      return {"status": "error", "message": responseData['message'] ?? "Something went wrong"};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      var url = Uri.parse('$baseURL/logout');
      var token = await _storage.read(key: 'token');
      if (token != null) {
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      await _storage.delete(key: 'token');
    }
  }

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
}
