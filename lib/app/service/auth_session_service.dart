import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionService {
  static const ownerRole = 'OWNER';
  static const adminRole = 'ADMIN';
  static const managerRole = 'MANAGER';
  static const sellerRole = 'SELLER';

  final supabase = Supabase.instance.client;

  Future<bool> hasValidSession() async {
    return supabase.auth.currentSession != null;
  }

  Future<void> loadCompanySession() async {
    final user = supabase.auth.currentUser;

    print("==============");
    print("USER ID:");
    print(user?.id);
    print("==============");
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    // 🌟 QUERY ATUALIZADA: Buscando a coluna 'name' (em minúsculas) de company_user
    final response = await supabase
        .from('company_user')
        .select('''
        company_id,
        role,
        name,
        company:company_id (
          id,
          name
        )
      ''')
        .eq('user_id', user.id)
        .single();

    print('==============================');
    print('COMPANY SESSION');
    print(response.toString());
    print('==============================');
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('companyId', response['company_id']);
    await prefs.setString('role', response['role']);
    await prefs.setString('companyName', response['company']?['name'] ?? '');
    
    // 💾 Salvando o nome do vendedor/utilizador localmente
    await prefs.setString('userName', response['name'] ?? 'Vendedor Sem Nome');
  }

  Future<String> getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');

    if (companyId == null || companyId.isEmpty) {
      throw Exception('Empresa não encontrada na sessão.');
    }

    return companyId;
  }

  Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');

    if (role == null || role.isEmpty) {
      throw Exception('Tipo de usuário não encontrado na sessão.');
    }

    return role;
  }

  Future<bool> hasAnyRole(Iterable<String> allowedRoles) async {
    final role = _normalizeRole(await getRole());
    final normalizedAllowedRoles = allowedRoles.map(_normalizeRole).toSet();

    return normalizedAllowedRoles.contains(role);
  }

  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('companyName');
  }

  // 📝 Método adicionado para conseguires resgatar o Nome do Vendedor na interface!
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<bool> canManageProducts() async {
    return hasAnyRole([ownerRole, adminRole, managerRole]);
  }

  Future<bool> canSell() async {
    return hasAnyRole([ownerRole, adminRole, managerRole, sellerRole]);
  }

  Future<bool> canViewReports() async {
    return hasAnyRole([ownerRole, adminRole, managerRole]);
  }

  Future<void> clearCompanySession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('companyId');
    await prefs.remove('role');
    await prefs.remove('companyName');
    await prefs.remove('userName'); // Limpa também o nome do vendedor
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

  String _normalizeRole(Object? role) {
    return role?.toString().trim().toUpperCase() ?? '';
  }
}