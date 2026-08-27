import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import 'Login.dart';
import 'Splash2.dart';

//classe inicial da tela
// Splash1 é a PRIMEIRA tela que aparece quando o app abre (a "splash
// screen" tradicional, com logo e nome do app). Sua única função é
// decidir para onde o usuário deve ir: se ele já estava logado antes
// (token salvo), pula direto para a Splash2 (que baixa os dados);
// se não, manda para a tela de Login.
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

    // Aguarda 3 segundos (tempo mínimo para o usuário ver a splash)
    // e só depois decide para qual tela navegar
    Future.delayed(Duration(seconds: 3), () async {

      // Verifica se existe um token de autenticação salvo localmente
      // de um login anterior (ou seja, se o usuário "já está logado")
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('tokenAutenticacao');

      // Garante que o widget ainda está na tela antes de navegar
      // (evita erro caso o usuário tenha saído do app durante a espera)
      if (!mounted) return;

      if (token != null) {
        // Se o token existir, vai para a Splash2 que simula o carregamento
        // (ela vai baixar/atualizar os agendamentos do usuário)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Splash2()),
        );
      } else {
        // Se não existir, vai para a tela de Login
        // (usuário precisa se autenticar antes de continuar)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login(title: 'Aplicativo')),
        );
      }
    });
  }

//método de construção da interface da tela
  // Monta o visual da splash: fundo colorido, logo, nome do app e um
  // indicador de carregamento circular, tudo centralizado na tela
  @override
  Widget build(BuildContext context) {
    // Inicializa o ScreenUtil (usado para escalonar tamanhos conforme
    // o tamanho da tela do aparelho)
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Color(0xFFE5B0A3), // cor de fundo (rosa/salmão do app)
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
            // Pequeno espaçamento vertical entre o texto e o spinner
            // (função utilitária reaproveitada de WidgetsUteis)
            WidgetsUteis().espacoHorizontal15,

            // Indicador de carregamento circular (spinner), mostrando
            // ao usuário que o app está processando algo em segundo plano
            WidgetsUteis().barraCircularProgresso(),
          ],
        ),
      ),
    );
  }
}