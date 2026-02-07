import 'package:aaliyahs_collection_estore/utils/http/dio_client.dart';
import 'package:aaliyahs_collection_estore/utils/http/http_method.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_client.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_endpoints.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  UserRepository({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? DioClient(baseUrl: baseURL);

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Public getter for token
  Future<String?> getStoredToken() async {
    return await _getToken();
  }

  // Get User Profile
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    String? token = await _getToken();

    if (token == null) {
      return ApiResponse.fromError('No token found', '401');
    }

    _apiClient.setToken(token);

    return await _apiClient.request(
      path: ApiEndpoints.userProfile,
      method: MethodType.get,
    );
  }

  // Update Profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      return ApiResponse.fromError('No token found', '401');
    }

    _apiClient.setToken(token);

    final data = {
      'first_name': firstName,
      'last_name': lastName,
    };

    return await _apiClient.request(
      path: ApiEndpoints.updateProfile,
      method: MethodType.put,
      payload: data,
    );
  }

  // Change Password
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    String? token = await _getToken();

    if (token == null) {
      return ApiResponse.fromError('No token found', '401');
    }

    _apiClient.setToken(token);

    final data = {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    return await _apiClient.request(
      path: ApiEndpoints.changePassword,
      method: MethodType.post,
      payload: data,
    );
  }

  // Delete Account
  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    String? token = await _getToken();

    if (token == null) {
      return ApiResponse.fromError('No token found', '401');
    }

    _apiClient.setToken(token);

    final response = await _apiClient.request<Map<String, dynamic>>(
      path: ApiEndpoints.deleteAccount,
      method: MethodType.delete,
    );

    if (response.success) {
      await _storage.delete(key: 'token');
      _apiClient.removeToken();
    }
    
    return response;
  }
}
