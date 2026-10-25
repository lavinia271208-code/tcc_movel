import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:login/model/Objects/DadosLogin.dart';
import 'package:login/model/api/Sincroniza.dart';
import 'package:login/model/bancoDeDados/PersistenciaShared.dart';

/**
 * Resultado do download de dados feito na Splash2:
 * - ok: dados baixados e salvos
 * - naoAutorizado: o servidor recusou o token (401), é preciso logar de novo
 * - semConexao: servidor fora do ar / sem internet (o app abre com o que já estiver salvo)
 */
enum StatusSync { ok, naoAutorizado, semConexao }

class CSplash {
  /**
   * Splash1:
   *
   * Função que retorna se o usuário está logado, verificando se existe
   * registro gravado no shared_preferences.
   * Retorna um valor boleano de true para logado e false para não logado,
   * pode ser executada de foma assincrona.
   */
  static Future<bool> seLogado() async {
    try {
      Map<dynamic, dynamic>? jsonLogin = await PersistenciaShared().readJson(PersistenciaShared.KEY_LOGIN);
      if (jsonLogin == null) return false;

      loginGlobal = Dadoslogin.fromJson(jsonLogin);
      return loginGlobal.token.isNotEmpty;
    } catch (x) {
      //caso houver erro, retorna não conectado, pois pode ter havido um
      //erro de acesso à memória interna
      print("ERRO AO ACESSAR SHARED, DEVIDO: ${x.toString()}");
      return false;
    }
  }

  /**
   * Splash2:
   *
   * Baixa os agendamentos da cliente e persiste no shared_preferences.
   * As telas leem desse "banco local" (CAgendamentos.resgataAgendamentos).
   */
  static Future<StatusSync> baixaDados() async {
    try {
      //|-------------------------------------------------------
      //faz o download e persiste os dados de agendamentos
      Response response = await Sincroniza().requestAgendamentos(loginGlobal.token);

      if (response.data['data'] != null) {
        final json = jsonEncode(response.data['data']);

        await PersistenciaShared().saveString(
            PersistenciaShared.KEY_AGENDAMENTOS,
            json
        );
        //|-------------------------------------------------------
        //persiste a data e hora da ultima atualização de dados
        await PersistenciaShared().saveString(
            PersistenciaShared.KEY_ATUALIZACAO,
            DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())
        );
      }
      return StatusSync.ok;
    } on DioException catch (e) {
      print(e.toString());
      if (e.response?.statusCode == 401) {
        return StatusSync.naoAutorizado;
      }
      return StatusSync.semConexao;
    } catch (e) {
      print(e.toString());
      return StatusSync.semConexao;
    }
  }
}

//De onde o usuário estiver no sistema vai conseguir visualizar o valor
//dessa variável
late Dadoslogin loginGlobal;