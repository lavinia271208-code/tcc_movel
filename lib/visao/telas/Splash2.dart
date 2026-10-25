import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Login.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import 'package:login/controle/ControllerLogin.dart';
import 'package:login/controle/ControllerSplash.dart';

//classe inicial da tela
// Splash2 é a segunda tela de carregamento: aparece logo após o login
// (ou logo após a Splash1, se o usuário já estava logado). Sua função
// é usar o token salvo para baixar os agendamentos do usuário da API
// e só então liberar o acesso ao app.
class Splash2 extends StatefulWidget {
  @override
  _Splash2State createState() => _Splash2State();
}
//classe altualizavel da tela
class _Splash2State extends State<Splash2> {

  //método de inicialização da tela
  // Assim que a tela é criada, já dispara o carregamento dos dados
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  //baixa os dados do usuário usando o token do login global e grava o
  //resultado localmente (shared preferences)
  Future<void> _carregarDados() async {
    final futureSync = CSplash.baixaDados();
    final futureTempoMinimo = Future.delayed(const Duration(seconds: 3));

    final StatusSync status = await futureSync;
    await futureTempoMinimo;

    // Garante que a tela ainda está montada antes de navegar
    if (!mounted) return;

    // Token recusado pelo servidor: apaga o login salvo e volta para o Login
    if (status == StatusSync.naoAutorizado) {
      await CLogin.logoff();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login(title: 'Aplicativo')),
      );
      return;
    }

    // Sem conexão com o servidor: abre o app mesmo assim, com os
    // agendamentos que já estavam salvos no aparelho
    if (status == StatusSync.semConexao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão com o servidor. Exibindo os dados salvos.')),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Principal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Color(0xFFE5B0A3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bem-vinda!',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            WidgetsUteis().espacoHorizontal15,
            WidgetsUteis().barraCircularProgresso(),
          ],
        ),
      ),
    );
  }
}