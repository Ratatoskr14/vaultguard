import 'package:local_auth/local_auth.dart';

/// Biometric authentication helper
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometrics (fingerprint/face)
  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompt the user for biometric auth (fingerprint or device credentials)
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: false,    // allow fallback to device PIN/pattern
          stickyAuth: true,
        ),
      );
    } catch (e) {
      // log or handle authentication errors
      print('Biometric authentication error: \$e');
      return false;
    }
  }
}