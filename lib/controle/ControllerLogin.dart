import 'package:dio/dio.dart';
import 'package:login/controle/ControllerSplash.dart';
import 'package:login/model/Objects/DadosLogin.dart';
import 'package:login/model/api/Sincroniza.dart';
import 'package:login/model/bancoDeDados/PersistenciaShared.dart';

class CLogin {
  /**
   * Faz o login na API.
   * Retorna null quando deu certo, ou a mensagem de erro para mostrar na tela.
   */
  static Future<String?> realizaLogin(String email, String password) async {
    try {
      Response response = await Sincroniza().requestLogin(email, password);
      return await _guardaLogin(response);
    } catch (e) {
      print(e.toString());
      return Sincroniza.mensagemErro(e);
    }
  }

  /**
   * Cria a conta de cliente na API (já devolve o token, então a cliente
   * fica logada logo em seguida).
   * Retorna null quando deu certo, ou a mensagem de erro para mostrar na tela.
   */
  static Future<String?> criaLogin(String nome, String email, String password, String confirmacao) async {
    try {
      Response response = await Sincroniza().requestCadastro(nome, email, password, confirmacao);
      return await _guardaLogin(response);
    } catch (e) {
      print(e.toString());
      return Sincroniza.mensagemErro(e);
    }
  }

  /**
   * Persiste o retorno do login/cadastro e define o login global.
   * Resposta da API: { data: { id, name, email, is_admin, token } }
   */
  static Future<String?> _guardaLogin(Response response) async {
    final dados = response.data['data'];

    if (dados == null || dados['token'] == null) {
      return 'Resposta inesperada do servidor.';
    }

    final login = Dadoslogin(
        usuario: dados['email'],
        nome: dados['name'],
        token: dados['token'],
        id: dados['id']
    );

    //persiste o retorno em formato json, no login mesmo
    await PersistenciaShared().saveJson(PersistenciaShared.KEY_LOGIN, login.toMap());

    //DEFININDO A VARIÁVEL DE LOGIN GLOBAL, VISÍVEL EM TODA A APP
    loginGlobal = login;
    return null;
  }

  static Future<bool> logoff() async {
    try {
      //avisa o servidor para apagar o token; se não conseguir (sem internet,
      //token já inválido), segue em frente e limpa os dados locais mesmo assim
      try {
        await Sincroniza().requestLogout(loginGlobal.token);
      } catch (_) {}

      await PersistenciaShared().removeShared(PersistenciaShared.KEY_LOGIN);
      await PersistenciaShared().removeShared(PersistenciaShared.KEY_AGENDAMENTOS);

      //DEFININDO A VARIÁVEL DE LOGIN GLOBAL, VISÍVEL EM TODA A APP
      loginGlobal = Dadoslogin(usuario: '', nome: '', token: '', id: -1);
      return true;
    } catch (e) {
      return false;
    }
  }
}