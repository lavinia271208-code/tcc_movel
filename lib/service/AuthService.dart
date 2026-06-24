import '../model/LoginModel.dart';

class AuthService {

  Future<LoginModel> realizarLogin(
      String usuario,
      String senha
      ) async {

    await Future.delayed(
      const Duration(seconds: 2),
    );

    return LoginModel(
      usuario: usuario,
      token: "TOKEN_123456",
      dataHora: DateTime.now().toString(),
    );
  }
}