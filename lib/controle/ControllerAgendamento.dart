import 'dart:convert';
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/model/api/Sincroniza.dart';
import 'package:login/model/bancoDeDados/PersistenciaShared.dart';
import 'package:dio/dio.dart';
import 'package:login/controle/ControllerSplash.dart';

/**
 * Classe usada em algumas telas, com responsabilidades sobre agendamentos
 */
class CAgendamentos {

  /**
   * Método responsável por listar os agendamentos contidos no sharedPreferences
   * (baixados em CSplash.baixaDados).
   * É utilizado nas telas:
   * -TelaMeusAgendamentos
   */
  static Future<List<Agendamento>> resgataAgendamentos() async {
    try {
      //resgata string json
      String? jsonString = await PersistenciaShared().readString(PersistenciaShared.KEY_AGENDAMENTOS);

      if (jsonString != null) {
        //decodifica string em um list
        List<dynamic> jsonList = jsonDecode(jsonString);

        //retorna um List de Agendamento da list acima
        return jsonList.map((json) => Agendamento.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (x) {
      print('Erro ao ler shared: $x');
      return [];
    }
  }

  /**
   * Busca na API os horários de um dia para o serviço escolhido.
   * Retorna uma lista de { 'hora': '08:00', 'ativo': true }, ou null se deu erro.
   * [ignorarAgendamentoId] é usado ao remarcar.
   * Usado na tela:
   * -TelaHorarios
   */
  static Future<List<Map<String, dynamic>>?> buscaHorarios(DateTime dia, int servicoId, {int? ignorarAgendamentoId}) async {
    try {
      Response response = await Sincroniza().requestHorarios(
          loginGlobal.token,
          Agendamento.formataDataParaApi(dia),
          servicoId,
          ignorarAgendamentoId: ignorarAgendamentoId
      );

      List<dynamic> lista = response.data['data'] ?? [];
      return lista.map<Map<String, dynamic>>((h) => {
        'hora': h['hora'].toString(),
        'ativo': h['ativo'] == true,
      }).toList();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /**
   * Cria um agendamento na API e atualiza os dados salvos no aparelho.
   * Retorna null quando deu certo, ou a mensagem de erro para mostrar na tela
   * (ex: "O horário selecionado está indisponível.").
   */
  static Future<String?> criaAgendamento({required int servicoId, required DateTime dataHora}) async {
    try {
      await Sincroniza().requestCriaAgendamento(
          loginGlobal.token,
          servicoId,
          Agendamento.formataParaApi(dataHora)
      );
      await CSplash.baixaDados();
      return null;
    } catch (e) {
      print(e.toString());
      return Sincroniza.mensagemErro(e);
    }
  }

  /**
   * Remarca um agendamento existente (novo dia/hora e, opcionalmente, novo serviço).
   * Retorna null quando deu certo, ou a mensagem de erro para mostrar na tela.
   */
  static Future<String?> remarcaAgendamento({required int id, required DateTime dataHora, int? servicoId}) async {
    try {
      await Sincroniza().requestRemarcaAgendamento(
          loginGlobal.token,
          id,
          Agendamento.formataParaApi(dataHora),
          servicoId: servicoId
      );
      await CSplash.baixaDados();
      return null;
    } catch (e) {
      print(e.toString());
      return Sincroniza.mensagemErro(e);
    }
  }

  /**
   * Cancela um agendamento da cliente.
   * Retorna null quando deu certo, ou a mensagem de erro para mostrar na tela.
   */
  static Future<String?> cancelaAgendamento(int id) async {
    try {
      await Sincroniza().requestCancelaAgendamento(loginGlobal.token, id);
      await CSplash.baixaDados();
      return null;
    } catch (e) {
      print(e.toString());
      return Sincroniza.mensagemErro(e);
    }
  }
}