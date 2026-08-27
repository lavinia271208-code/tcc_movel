import '../model/LoginModel.dart';

class AuthService {

  //simula a chamada de login à API (web service de autenticação)
  Future<LoginModel> realizarLogin(
      String usuario,
      String senha
      ) async{

    //simula o retorno que viria do servidor (usuário autenticado + token)
    return LoginModel(
      email: usuario,
      token: "TOKEN_123456",
      dataHora: DateTime.now().toString(),
    );
  }
}