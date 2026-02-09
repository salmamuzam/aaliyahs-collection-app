import 'package:aaliyahs_collection_estore/utils/http/dio_client.dart';
import 'package:aaliyahs_collection_estore/utils/http/http_method.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_client.dart';
import 'package:aaliyahs_collection_estore/utils/http/api_response.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_strings.dart';
import 'package:aaliyahs_collection_estore/utils/constants/api_endpoints.dart';
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
      'first_name': firstname,
      'last_name': lastname,
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
    
    final response = await _apiClient.request<Map<String, dynamic>>(
      path: ApiEndpoints.register,
      method: MethodType.post,
      payload: data,
    );

    if (response.success && response.data != null) {
      final responseData = response.data!;
      // Extract token from nested 'data' or root
      final Map<String, dynamic> body = responseData['data'] ?? responseData;
      
      if (body['token'] != null) {
        final token = body['token'];
        await _storage.write(key: 'token', value: token);
        
        // Save credentials for biometrics immediately after register
        try {
          await _storage.write(key: 'bio_email', value: email);
          await _storage.write(key: 'bio_password', value: password);
          debugPrint(' [AUTH REPO]: Biometric credentials saved after registration');
        } catch (e) {
          debugPrint(' [AUTH REPO]: Error saving bio credentials: $e');
        }
        
        _apiClient.setToken(token);
      }
    }

    return response;
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String login,
    required String password,
    String? twoFactorCode,
  }) async {
    final Map<String, dynamic> data = {
      'login': login,
      'password': password,
    };

    if (twoFactorCode != null) {
      data['two_factor_code'] = twoFactorCode;
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
        
        // Save credentials for biometrics
        try {
          debugPrint(' [AUTH REPO]: Saving biometric credentials...');
          debugPrint(' [AUTH REPO]: Email to save: $login');
          
          await _storage.write(key: 'bio_email', value: login);
          await _storage.write(key: 'bio_password', value: password);
          
          // Verify the credentials were saved correctly
          final verifyEmail = await _storage.read(key: 'bio_email');
          final verifyPassword = await _storage.read(key: 'bio_password');
          
          if (verifyEmail == login && verifyPassword == password) {
            debugPrint(' [AUTH REPO]: Biometric credentials saved and verified successfully!');
            debugPrint(' [AUTH REPO]: Stored email: $verifyEmail');
          } else {
            debugPrint(' [AUTH REPO]:  Warning: Credential verification failed!');
            debugPrint(' [AUTH REPO]: Expected email: $login, Got: $verifyEmail');
          }
        } catch (e) {
          debugPrint(' [AUTH REPO]:  Error saving biometric credentials: $e');
        }
        
        _apiClient.setToken(token);
      }
    }

    return response;
  }

  Future<String?> getBioEmail() async => await _storage.read(key: 'bio_email');
  Future<String?> getBioPassword() async => await _storage.read(key: 'bio_password');

  // --- GOOGLE AUTH (FIREBASE) ---

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
  Future<void> _syncUserProfileToDatabase(User user) async {
    try {
      final dbUrl = dotenv.env['FIREBASE_DB_URL'];
      if (dbUrl == null) return;

      final url = '${dbUrl}users/${user.uid}.json';
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
        path: url, 
        method: MethodType.patch,
        payload: data,
      );
    } catch (e) {
      debugPrint('User Sync Error: $e');
    }
  }

  // --- ACCOUNT UTILITIES ---

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        _apiClient.setToken(token);
        await _apiClient.request(path: ApiEndpoints.logout, method: MethodType.get);
      }
      
      if (_googleSignIn.currentUser != null) await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      
      return ApiResponse();
    } finally {
      await _storage.delete(key: 'token');
      _apiClient.removeToken();
    }
  }

  /// Map Firebase and API error codes 
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
