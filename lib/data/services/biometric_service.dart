import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

/// Biometric Authentication Service
/// Following the pattern from flutter_biometric_auth_jetstream reference
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on this device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      debugPrint('🔐 [BIOMETRIC]: canCheckBiometrics: $canAuthenticateWithBiometrics');
      debugPrint('🔐 [BIOMETRIC]: isDeviceSupported: ${await _localAuth.isDeviceSupported()}');
      debugPrint('🔐 [BIOMETRIC]: canAuthenticate: $canAuthenticate');
      
      return canAuthenticate;
    } catch (e) {
      debugPrint('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if user has enrolled biometric data (fingerprint/face)
  Future<bool> isBiometricEnrolled() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        debugPrint('🔐 [BIOMETRIC]: Device cannot check biometrics');
        return false;
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('🔐 [BIOMETRIC]: Available biometrics: $availableBiometrics');
      
      if (availableBiometrics.isEmpty) {
        debugPrint('🔐 [BIOMETRIC]: No biometrics enrolled. Please go to Settings > Security to enroll fingerprint or face recognition');
      }
      
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get list of available biometric types on this device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('🔐 [BIOMETRIC]: Available biometric types: $biometrics');
      return biometrics;
    } catch (e) {
      debugPrint('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics
  /// Returns true if authenticated successfully, false otherwise
  Future<bool> authenticate() async {
    bool isAuthorized = false;
    try {
      // Check if biometrics are available first
      final bool canAuthenticate = await isBiometricAvailable();
      if (!canAuthenticate) {
        debugPrint('🔐 [BIOMETRIC]: Biometric authentication not available on this device');
        return false;
      }

      // Check if biometrics are enrolled
      final bool isEnrolled = await isBiometricEnrolled();
      if (!isEnrolled) {
        debugPrint('🔐 [BIOMETRIC]: No biometrics enrolled. Please add a fingerprint or face in device settings');
        return false;
      }

      isAuthorized = await _localAuth.authenticate(
        localizedReason: "Please authenticate to log into Aaliyah's Collection",
      );
      debugPrint('🔐 Biometric authentication result: $isAuthorized');
    } on PlatformException catch (e) {
      debugPrint('🔐 Biometric Authentication Platform Error: ${e.code} - ${e.message}');
      
      // Provide more helpful error messages
      switch (e.code) {
        case 'NotAvailable':
          debugPrint('🔐 Biometric authentication is not available on this device');
          break;
        case 'NotEnrolled':
          debugPrint('🔐 No biometrics enrolled. Go to Settings > Security to add fingerprint/face');
          break;
        case 'LockedOut':
          debugPrint('🔐 Too many failed attempts. Biometrics temporarily locked');
          break;
        case 'PermanentlyLockedOut':
          debugPrint('🔐 Biometrics permanently locked. Use device password to unlock');
          break;
        default:
          debugPrint('🔐 Biometric error: ${e.code}');
      }
      return false;
    } catch (exception) {
      debugPrint('❌ Biometric Authentication Error: $exception');
      return false;
    }
    return isAuthorized;
  }

  /// Get user-friendly message for biometric status
  Future<String> getBiometricStatusMessage() async {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      return 'Biometric authentication is not supported on this device';
    }

    final isEnrolled = await isBiometricEnrolled();
    if (!isEnrolled) {
      return 'No biometrics enrolled. Please go to Settings > Security > Fingerprint/Face to add biometric authentication';
    }

    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint authentication is available';
    } else if (biometrics.contains(BiometricType.face)) {
      return 'Face recognition is available';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris scan is available';
    }

    return 'Biometric authentication is available';
  }
}

