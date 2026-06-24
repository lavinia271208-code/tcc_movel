import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/visao/telas/Splash2.dart';
import 'package:login/visao/estilos/EstilosBotoes.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import '../../service/AuthService.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _entrarActive = false;
  bool _cadastrarActive = true;
  bool _carregando = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void telaPrincipal(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Principal()),
    );
  }

  void telaSplash2(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Splash2()),
    );
  }

  Future<void> _processarLogin(BuildContext context) async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      final authService = AuthService();

      final loginModel = await authService.realizarLogin(
        _emailController.text,
        _passwordController.text,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nomeUsuario', loginModel.usuario);
      await prefs.setString('dataHoraLogin', loginModel.dataHora);
      await prefs.setString('tokenAutenticacao', loginModel.token);

      if (!mounted) return;
      setState(() => _carregando = false);

      telaSplash2(context);

    } catch (erro) {
      setState(() => _carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na autenticação: $erro')),
      );
    }
  }

  Widget _showEntrar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: ScreenUtil().setHeight(30)),
        TextField(
          style: TextStyle(color: Theme.of(context).highlightColor),
          controller: _emailController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextEmail,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            prefixIcon: const Icon(Icons.email, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(50)),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Color(0xFFFFC0CB)),
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextPassword,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(borderSide: EstilosBotoes().borderSideFino(context)),
            focusedBorder: UnderlineInputBorder(borderSide: EstilosBotoes().borderSideFino(context)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(80)),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: _carregando
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7D4CC),
              foregroundColor: Colors.black,
            ),
            onPressed: () => _processarLogin(context),
            child: const Text('Acessar'),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WidgetsUteis().horizontalLine(),
            Text('-', style: EstilosTextosCustomizado.body(context)),
            WidgetsUteis().horizontalLine()
          ],
        ),
        WidgetsUteis().espacoHorizontal15,
      ],
    );
  }

  Widget _showCadastrar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: ScreenUtil().setHeight(30)),
        TextField(
          style: EstilosTextosCustomizado.formField(context),
          controller: _newEmailController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextNewEmail,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(50)),
        TextField(
          obscureText: true,
          style: EstilosTextosCustomizado.formField(context),
          controller: _newPasswordController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextNewPassword,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(80)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7D4CC),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: () {
            telaSplash2(context);
          },
          child: Text(
            Internacionalizacao.signUpMenuButton,
            style: EstilosTextosCustomizado.button(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ScreenUtil.init(context, designSize: const Size(750, 1304));

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE5B0A3),
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(190),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(Internacionalizacao.logoTitle,
                                style: EstilosTextosCustomizado.title(context)),
                            Text(Internacionalizacao.logoSubTitle,
                                style: EstilosTextosCustomizado.subTitle(context)),
                          ],
                        )),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(60)),
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(170),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            OutlinedButton(
                              onPressed: () => setState(() => _alterarParaEntrar()),
                              child: Text(Internacionalizacao.signInMenuButton,
                                  style: _cadastrarActive
                                      ? TextStyle(
                                      fontSize: 22,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.bold)
                                      : TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.normal)),
                            ),
                            OutlinedButton(
                              onPressed: () => setState(() => _alterarParaCadastrar()),
                              child: Text(Internacionalizacao.signUpMenuButton,
                                  style: _entrarActive
                                      ? TextStyle(
                                      fontSize: 22,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.bold)
                                      : TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.normal)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(5)),
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(778),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: _cadastrarActive ? _showEntrar(context) : _showCadastrar()),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _alterarParaCadastrar() {
    _entrarActive = true;
    _cadastrarActive = false;
  }

  void _alterarParaEntrar() {
    _entrarActive = false;
    _cadastrarActive = true;
  }
}

class Internacionalizacao {
  static String logoTitle = "Entre na sua conta";
  static String logoSubTitle = "Digite seus dados para acessar";
  static String signInMenuButton = "ACESSAR";
  static String signUpMenuButton = "CADASTRAR";
  static String hintTextEmail = "Email";
  static String hintTextPassword = "Senha";
  static String hintTextNewEmail = "Entre com seu Email";
  static String hintTextNewPassword = "Crie uma senha";
}