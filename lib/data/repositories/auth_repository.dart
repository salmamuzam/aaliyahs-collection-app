import 'package:aaliyahs_collection_estore/data/services/api/api_client.dart';
import 'package:aaliyahs_collection_estore/data/services/api/api_response.dart';
import 'package:aaliyahs_collection_estore/util/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/util/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository({ApiClient? apiClient}) 
    : _apiClient = apiClient ?? DioClient(baseUrl: baseURL);

  // --- LARAVEL API AUTH ---

  Future<ApiResponse<Map<String, dynamic>>> register(
    String firstname,
    String lastname,
    String username,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    final data = {
      "first_name": firstname,
      "last_name": lastname,
      "username": username,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    };
    
    return await _apiClient.request(
      path: ApiEndpoints.register,
      method: MethodType.post,
      payload: data,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String login,
    required String password,
    String? twoFactorCode,
  }) async {
    final Map<String, dynamic> data = {
      "login": login,
      "password": password,
    };

    if (twoFactorCode != null) {
      data["two_factor_code"] = twoFactorCode;
    }

    final response = await _apiClient.request<Map<String, dynamic>>(
      path: ApiEndpoints.login,
      method: MethodType.post,
      payload: data,
    );

    if (response.success && response.data != null) {
      final responseData = response.data!;
      if (responseData['data'] != null && responseData['data']['token'] != null) {
        final token = responseData['data']['token'];
        await _storage.write(key: 'token', value: token);
        _apiClient.setToken(token);
      }
    }

    return response;
  }

  // --- GOOGLE AUTH (FIREBASE) ---

  /// Sign in with Google as recommended for mobile devices.
  /// Best practice: Centralize federated identity logic in the service layer.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'status': 'cancelled'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // BEST PRACTICE: Securely Manage User Data
        // Sync user profile to Realtime Database for easier access/association
        await _syncUserProfileToDatabase(user);

        return {
          'status': 'success',
          'email': user.email,
          'name': user.displayName,
          'uid': user.uid
        };
      }
      return {'status': 'error', 'message': 'Firebase user creation failed'};
    } on FirebaseAuthException catch (e) {
      return {'status': 'error', 'message': getErrorMessage(e.code)};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Syncs the authenticated user's profile to the Realtime Database.
  /// Follows the best practice of centralizing user metadata.
  Future<void> _syncUserProfileToDatabase(User user) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) return;

      final url = "${dbUrl}users/${user.uid}.json";
      final data = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
        'isAnonymous': user.isAnonymous,
      };

      // PATCH used to update existing or create new without overwriting other fields
      await _apiClient.request(
        path: url, // Dio handles absolute URLs if provided in path
        method: MethodType.patch,
        payload: data,
      );
    } catch (e) {
      debugPrint("User Sync Error: $e");
    }
  }

  // --- ACCOUNT UTILITIES ---

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        _apiClient.setToken(token);
        await _apiClient.request(path: ApiEndpoints.logout, method: MethodType.post);
      }
      
      // Federated Sign-Out Best Practice
      if (_googleSignIn.currentUser != null) await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      
      return ApiResponse(success: true);
    } finally {
      await _storage.delete(key: 'token');
      _apiClient.removeToken();
    }
  }

  /// Map Firebase and API error codes to User-Friendly messages.
  /// Best Practice from "From Zero to Hero" guide.
  String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'auth/user-not-found':
        return 'No account found with this email.';
      case 'auth/wrong-password':
        return 'Incorrect password. Please try again.';
      case 'auth/email-already-in-use':
        return 'An account with this email already exists.';
      case 'auth/weak-password':
        return 'Password should be at least 6 characters.';
      case 'auth/invalid-email':
        return 'The email address is badly formatted.';
      case 'auth/user-disabled':
        return 'This account has been disabled.';
      case 'auth/operation-not-allowed':
        return 'Sign-in method is not enabled.';
      case 'auth/invalid-credential':
        return 'Invalid credentials provided.';
      default:
        return 'An unexpected authentication error occurred.';
    }
  }

  Future<String?> getToken() async => await _storage.read(key: 'token');
}
