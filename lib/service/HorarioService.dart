import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/model/api/Sincroniza.dart';

class HorarioService {
  // GET /api/horarios-disponiveis?data=YYYY-MM-DD&servico_id=1
  // Resposta da API: { data: [ { hora: '08:00', ativo: true }, ... ] }
  // Retorna a mesma forma que a tela já espera: [{ 'hora': '08:00', 'ativo': true }, ...]
  Future<List<Map<String, dynamic>>> buscarHorarios({
    required String token,
    required DateTime data,
    required int servicoId,
  }) async {
    final uri = Uri.parse('${Sincroniza.BASE_URL}/horarios-disponiveis').replace(
      queryParameters: {
        'data': Agendamento.formataDataParaApi(data),
        'servico_id': servicoId.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> lista = jsonDecode(response.body)['data'];
      return lista.cast<Map<String, dynamic>>();
    }

    throw Exception('Não foi possível carregar os horários disponíveis.');
  }
}