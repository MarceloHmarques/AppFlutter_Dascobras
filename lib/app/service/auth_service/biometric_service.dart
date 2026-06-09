import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    final isSupported = await _auth.isDeviceSupported();
    final canCheck = await _auth.canCheckBiometrics;

    if (!isSupported || !canCheck) {
      return true;
    }

    try {
      return await _auth.authenticate(
        localizedReason: 'Confirme sua identidade',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return true; // fallback
    }
  }
}
