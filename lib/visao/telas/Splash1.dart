import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import 'Login.dart';
import 'Splash2.dart';

//classe inicial da tela
class Splash1 extends StatefulWidget {
  @override
  _Splash1State createState() => _Splash1State();
}
//classe altualizavel da tela
class _Splash1State extends State<Splash1> {

  //método de inicialização da tela
  //método de inicialização da tela
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      // Importe o pacote shared_preferences no topo do arquivo se necessário
      // import 'package:shared_preferences/shared_preferences.dart';
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenAutenticacao');

      if (!mounted) return;

      if (token != null) {
        // Se o token existir, vai para a Splash2 que simula o carregamento
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Splash2()), // Lembre de importar o Splash2.dart
        );
      } else {
        // Se não existir, vai para a tela de Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login(title: 'Aplicativo')),
        );
      }
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
            Image.asset('assets/logo.png', //img logo
              width: 150,
            ),
            Text('makeup studio', style: TextStyle(fontWeight: FontWeight.bold,
              color: Colors.white, fontSize: 26),
            ),
            WidgetsUteis().espacoHorizontal15,
            WidgetsUteis().barraCircularProgresso(),
          ],
        ),
      ),
    );
  }
}