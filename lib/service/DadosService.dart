import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/model/api/Sincroniza.dart';

class DadosService {
  // GET /api/meus-agendamentos -> { data: [ ... ] }
  Future<List<Agendamento>> baixarAgendamentos(String token) async {
    if (token.isEmpty) {
      throw Exception('Token inválido, não foi possível baixar os dados.');
    }

    final response = await http.get(
      Uri.parse('${Sincroniza.BASE_URL}/meus-agendamentos'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body)['data'];
      return lista.map((json) => Agendamento.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada, faça login novamente.');
    }

    throw Exception('Não foi possível carregar seus agendamentos.');
  }

  // POST /api/agendamentos -> 201 { data: {...} }
  Future<Agendamento> criarAgendamento({
    required String token,
    required int servicoId,
    required DateTime dataHora,
  }) async {
    final response = await http.post(
      Uri.parse('${Sincroniza.BASE_URL}/agendamentos'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'servico_id': servicoId.toString(),
        // a API exige "Y-m-d H:i:s"; toIso8601String() (com "T") dá 422
        'data_hora': Agendamento.formataParaApi(dataHora),
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Agendamento.fromJson(body['data']);
    }

    // 422 = horário bloqueado ou já ocupado (mensagem vem pronta do backend)
    final mensagem = body['message'] ?? 'Não foi possível criar o agendamento.';
    throw Exception(mensagem);
  }

  // DELETE /api/agendamentos/{id}
  Future<void> cancelarAgendamento({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('${Sincroniza.BASE_URL}/agendamentos/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Não foi possível cancelar o agendamento.');
    }
  }
}