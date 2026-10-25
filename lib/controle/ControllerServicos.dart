import 'package:dio/dio.dart';
import 'package:login/controle/ControllerSplash.dart';
import 'package:login/model/Objects/Servico.dart';
import 'package:login/model/api/Sincroniza.dart';

/**
 * Classe usada em algumas telas, com responsabilidades sobre os serviços
 */
class CServicos {

  /**
   * Baixa a listagem de serviços direto da API.
   * Usado na tela:
   * -TelaHorarios
   */
  static Future<List<Servico>> listagemServicos() async {
    try {
      //faz o download
      Response response = await Sincroniza().requestServicos(loginGlobal.token);

      if (response.data['data'] != null) {
        List<dynamic> jsonList = response.data['data'];
        return jsonList.map((json) => Servico.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}