import 'package:supabase_flutter/supabase_flutter.dart';

///Queria separar as funções

class RegisterService {
  final supabase = Supabase.instance.client;

  //Função para verificar no BD se já existe uma conta com aquele cpf
  Future<bool> verifyCpf(String value) async {
    final result = await supabase.rpc('verify_cpf', params: {'value': value});

    return result as bool;
  }

  //Função Assícrona
  Future<void> register({
    required String name,
    required String cpf,
    required String password,
    required DateTime date,
    required String email,
  }) async {
    //verifica se já ta cadastrado
    final result = await verifyCpf(cpf);

    //se existir
    if (result) {
      throw Exception('CPF já cadastrado.');
    }

    //se não existir
    if (!result) {
      try {
        final response = await supabase.auth.signUp(
          password: password,
          email: email,
        );

        final user = response.user;

        if (user == null) {
          throw Exception('Erro ao criar usuário');
        }

        await supabase.from('users').insert({
          'id': user.id,
          'name': name,
          'cpf': cpf,
          'date': date.toIso8601String(),
          'type': 'seller',
        });
      } on AuthException catch (e) {
        if (e.message.contains('User already registered')) {
          throw AuthException('Email já cadastrado');
        }

        rethrow;
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          throw Exception('CPF já cadastrado.');
        }

        throw Exception(e.message);
      }
    }
  }
}
