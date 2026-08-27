import '../model/AgendamentoModel.dart';

//serviço responsável por simular a busca (download) dos dados do usuário
//na API, utilizando o token de autenticação gravado no shared preferences
class DadosService {
  //simula uma chamada de web service autenticada pelo token
  //em uma aplicação real, aqui seria feita uma requisição HTTP (GET)
  //enviando o token no header "Authorization: Bearer $token"
  Future<List<AgendamentoModel>> baixarAgendamentos(String token) async {
    //simula o tempo de resposta da API
    await Future.delayed(const Duration(seconds: 2));

    //simula uma falha de autenticação caso o token não seja válido
    if (token.isEmpty) {
      throw Exception('Token inválido, não foi possível baixar os dados.');
    }

    //dados simulados que "viriam" da API
    return [
      AgendamentoModel(
        dia: 'Segunda-feira',
        hora: '14:00',
        servico: 'Maquiagem',
        status: 'Confirmado',
      ),
      AgendamentoModel(
        dia: 'Quarta-feira',
        hora: '10:00',
        servico: 'Penteado',
        status: 'Pendente',
      ),
      AgendamentoModel(
        dia: 'Sexta-feira',
        hora: '16:00',
        servico: 'Maquiagem',
        status: 'Confirmado',
      ),
    ];
  }
}