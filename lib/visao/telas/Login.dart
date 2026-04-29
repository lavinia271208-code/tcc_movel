import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/telas/Splash2.dart';
import 'package:login/visao/estilos/EstilosBotoes.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';

bool _entrarActive = false;
bool _cadastrarActive = true;

TextEditingController _emailController = TextEditingController();
TextEditingController _passwordController = TextEditingController();
TextEditingController _newEmailController = TextEditingController();
TextEditingController _newPasswordController = TextEditingController();

class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;
  @protected
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  telaPrincipal(context){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Principal()),
    );
  }

  telaSplash2(context){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Splash2()),
    );
  }
  Widget _showEntrar(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              style: TextStyle(color: Theme
                  .of(context)
                  .highlightColor
              ),
              controller: _emailController,
              decoration: InputDecoration(
                hintText: Internacionalizacao.hintTextEmail,
                hintStyle: EstilosTextosCustomizado.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme
                            .of(context)
                            .highlightColor, width: 1.0
                    )
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).highlightColor, width: 1.0
                    )
                ),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.white,
                ),
              ),
              obscureText: false,
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(50),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: TextStyle(color: Color(0xFFFFC0CB),
              ),
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: Internacionalizacao.hintTextPassword,
                hintStyle: EstilosTextosCustomizado.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: EstilosBotoes().borderSideFino(context)
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide:EstilosBotoes().borderSideFino(context)
                ),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF7D4CC),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              telaSplash2(context);
            },
            child: Text('Acessar'),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(15),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                WidgetsUteis().horizontalLine(),
                Text('-',style: EstilosTextosCustomizado.body(context)),
                WidgetsUteis().horizontalLine()
              ],
            ),
          ),
        ),
        WidgetsUteis().espacoHorizontal15,
      ],
    );
  }
  Widget _showCadastrar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: ScreenUtil().setHeight(30),
        ),
        Container(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            obscureText: false,
            style: EstilosTextosCustomizado.formField(context),
            controller: _newEmailController,
            decoration: InputDecoration(
              hintText: Internacionalizacao.hintTextNewEmail,
              hintStyle: EstilosTextosCustomizado.formField(context),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1.0,
                ),
              ),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(50),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: TextField(
              obscureText: true,
              style: EstilosTextosCustomizado.formField(context),
              controller: _newPasswordController,
              decoration: InputDecoration(
                hintText: Internacionalizacao.hintTextNewPassword,
                hintStyle: EstilosTextosCustomizado.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).highlightColor, width: 1.0
                    )
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme
                            .of(context)
                            .highlightColor, width: 1.0
                    )
                ),
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        Container(
          child: Padding(
            padding: EdgeInsets.only(),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF7D4CC),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                telaSplash2(context);
              },
              child: Text(
                Internacionalizacao.signUpMenuButton,
                style: EstilosTextosCustomizado.button(context),
              ),
            ),
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

    return
      Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5B0A3),
            child: Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Column(
                children: <Widget>[
                    Container(
                      child: Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                  Internacionalizacao.logoTitle,
                                  style: EstilosTextosCustomizado.title(context)
                              ),
                              Text(
                                Internacionalizacao.logoSubTitle,
                                style: EstilosTextosCustomizado.subTitle(context),
                              ),
                            ],
                          )),
                      width: ScreenUtil().setWidth(750),
                      height: ScreenUtil().setHeight(190),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(60),
                    ),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: () => setState(() => _alterarParaEntrar()),
                                child: new Text(Internacionalizacao.signInMenuButton,
                                    style: _cadastrarActive
                                        ? TextStyle(
                                        fontSize: 22,
                                        color: Theme.of(context).highlightColor,
                                        fontWeight: FontWeight.bold
                                    )
                                        : TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).highlightColor,
                                        fontWeight: FontWeight.normal)
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () =>
                                    setState(() => _alterarParaCadastrar()),
                                child: Text(Internacionalizacao.signUpMenuButton,
                                    style: _entrarActive
                                        ? TextStyle(
                                        fontSize: 22,
                                        color: Theme
                                            .of(context)
                                            .highlightColor,
                                        fontWeight: FontWeight.bold
                                    )
                                        : TextStyle(
                                        fontSize: 16,
                                        color: Theme
                                            .of(context)
                                            .highlightColor,
                                        fontWeight: FontWeight.normal
                                    )
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      width: ScreenUtil().setWidth(750),
                      height: ScreenUtil().setHeight(170),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(5),
                    ),
                    Container(
                      child: Padding(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: _cadastrarActive ? _showEntrar(context) : _showCadastrar()
                      ),
                      width: ScreenUtil().setWidth(750),
                      height: ScreenUtil().setHeight(778),
                    ),
                  ],
                ),
              ),
          )
      );
  }

  static void _alterarParaCadastrar() {
    _entrarActive = true;
    _cadastrarActive = false;
  }

  static void _alterarParaEntrar() {
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