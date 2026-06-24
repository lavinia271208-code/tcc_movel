import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';

//classe inicial da tela
class Splash2 extends StatefulWidget {
  @override
  _Splash2State createState() => _Splash2State();
}
//classe altualizavel da tela
class _Splash2State extends State<Splash2> {

  //método de inicialização da tela
  //método de inicialização da tela
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      // Abre o SharedPreferences apenas para simular a leitura do token/dados da API
      // Certifique-se de ter importado: import 'package:shared_preferences/shared_preferences.dart';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('tokenAutenticacao') ?? '';

      if (!mounted) return;

      // Vai para a tela Principal após processar os dados em segundo plano
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Principal()),
      );
    });
  }

  //método de construção da interface da tela
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
            Text('Bem-vinda!', style: EstilosTextosCustomizado.title(context),),
            WidgetsUteis().espacoHorizontal15,
            WidgetsUteis().barraCircularProgresso(),
          ],
        ),
      ),
    );
  }
}