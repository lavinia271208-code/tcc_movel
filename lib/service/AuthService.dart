import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login/model/Objects/DadosLogin.dart';
import 'package:login/model/api/Sincroniza.dart';

class AuthService {
  // Resposta da API: { data: { id, name, email, is_admin, token } }
  Dadoslogin _dadosDaResposta(Map<String, dynamic> body) {
    final d = body['data'];
    return Dadoslogin(
      id: d['id'],
      usuario: d['email'],
      nome: d['name'],
      token: d['token'],
    );
  }

  // POST /api/login
  Future<Dadoslogin> realizarLogin(String email, String senha) async {
    final response = await http.post(
      Uri.parse('${Sincroniza.BASE_URL}/login'),
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': senha,
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return _dadosDaResposta(body);
    }

    // 422 = validação/credenciais inválidas (Laravel retorna 'message' e 'errors')
    final mensagem = body['message'] ?? 'Não foi possível fazer login.';
    throw Exception(mensagem);
  }

  // POST /api/cadastro
  Future<Dadoslogin> realizarCadastro({
    required String name,
    required String email,
    required String senha,
    required String senhaConfirmacao,
  }) async {
    final response = await http.post(
      Uri.parse('${Sincroniza.BASE_URL}/cadastro'),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': senha,
        'password_confirmation': senhaConfirmacao,
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return _dadosDaResposta(body);
    }

    final mensagem = body['message'] ?? 'Não foi possível concluir o cadastro.';
    throw Exception(mensagem);
  }

  // POST /api/logout
  Future<void> realizarLogout(String token) async {
    await http.post(
      Uri.parse('${Sincroniza.BASE_URL}/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}