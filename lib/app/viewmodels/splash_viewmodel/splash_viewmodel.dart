import 'package:DasCobras/app/service/auth_service/auth_session_service.dart';
import 'package:DasCobras/app/service/auth_service/biometric_service.dart';

class SplashViewmodel {
  final AuthSessionService _sessionService = AuthSessionService();
  final BiometricService _biometricService = BiometricService();

  Future<bool> canEnterApp() async {
    final hasSession = await _sessionService.hasValidSession();

    if (!hasSession) return false;

    final expired = await _sessionService.isLoginExpired();

    if (expired) return false;

    final shouldCheck = await _sessionService.shouldCheckSession();

    if (shouldCheck) {
      final stillValid = await _sessionService.hasValidSession();
      await _sessionService.saveSessionCheckDate();

      if (!stillValid) return false;
    }

    final biometricOk = await _biometricService.authenticate();

    return biometricOk;
  }
}
