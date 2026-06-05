import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  final supabase = Supabase.instance.client;

  Future<void> login({required String email, required String password})
  //usar async(assicrona) para usar o await(espere) porque vai demorar a requisição http
  async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Email ou senha inválido.');
      }
    } on AuthException {
      throw Exception('Email ou senha inválido.');
    }
  }
}
