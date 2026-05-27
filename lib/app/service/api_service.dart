import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  //Função Assícrona
  //Vai retornar no futuro uma String
  Future<String> login({required String cpf, required String password})
  //usar async(assicrona) para usar o await(espere) porque vai demorar a requisição http
  async {
    final response = await http.post(
      //endereço onde vai consumir api
      Uri.parse('http://10.0.2.2:3000/login'),
      //diz que vai receber um json
      headers: {'Content-Type': 'application/json'},
      //passa de mapa para json
      body: jsonEncode({'cpf': cpf, 'password': password}),
    );

    if (response.statusCode == 500) {
      throw Exception('Erro interno do servidor!');
    }

    if (response.statusCode == 401) {
      throw Exception('CPF ou Senha inválida');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }

    throw Exception('Erro ao fazer o login');
  }
}
