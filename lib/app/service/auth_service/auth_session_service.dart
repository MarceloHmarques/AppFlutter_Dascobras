import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionService {
  final supabase = Supabase.instance.client;

  Future<bool> hasValidSession() async {
    return supabase.auth.currentSession != null;
  }

  Future<void> saveLoginDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFullLogin', DateTime.now().toIso8601String());
  }

  Future<bool> isLoginExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginString = prefs.getString('lastFullLogin');

    if (lastLoginString == null) return true;

    final lastLogin = DateTime.parse(lastLoginString);
    return DateTime.now().difference(lastLogin).inDays >= 30;
  }

  Future<bool> shouldCheckSession() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckString = prefs.getString('lastSessionCheck');

    if (lastCheckString == null) return true;

    final lastCheck = DateTime.parse(lastCheckString);
    return DateTime.now().difference(lastCheck).inMinutes >= 2;
  }

  Future<void> saveSessionCheckDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSessionCheck', DateTime.now().toIso8601String());
  }
}
