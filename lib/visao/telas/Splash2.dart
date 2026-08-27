import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Login.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import '../../service/DadosService.dart';

//classe inicial da tela
// Splash2 é a segunda tela de carregamento: aparece logo após o login
// (ou logo após a Splash1, se o usuário já estava logado). Sua função
// é usar o token salvo para "baixar" os agendamentos do usuário (hoje
// é uma simulação, sem API real) e só então liberar o acesso ao app.
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

  //baixa os dados do usuário (simulação de API/web service) usando o
  //token gravado no shared preferences e grava o resultado localmente
  Future<void> _carregarDados() async {
    // Recupera o token salvo no login; se não existir, usa string vazia
    // (DadosService trata token vazio como inválido)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('tokenAutenticacao') ?? '';

    try {
      // dispara a "chamada à API" e, em paralelo, garante um tempo mínimo
      // de exibição da splash mesmo que a resposta seja rápida
      //
      // As duas linhas abaixo apenas CRIAM os Futures (começam a rodar em
      // paralelo); nada é aguardado ainda nesse ponto
      final futureAgendamentos = DadosService().baixarAgendamentos(token);
      final futureTempoMinimo = Future.delayed(const Duration(seconds: 3));

      // Espera a "API" responder com os agendamentos
      final agendamentos = await futureAgendamentos;
      // Espera o tempo mínimo de splash terminar (caso a API tenha
      // respondido rápido demais, isso evita uma splash "piscando")
      await futureTempoMinimo;

      // converte a lista de agendamentos em JSON e grava no shared preferences
      // (transforma cada AgendamentoModel em Map via toMap(), depois tudo
      // em uma única string JSON, para poder ser salvo no SharedPreferences)
      final String agendamentosJson = jsonEncode(
        agendamentos.map((agendamento) => agendamento.toMap()).toList(),
      );
      await prefs.setString('agendamentos', agendamentosJson);

      // Garante que a tela ainda está montada antes de navegar
      if (!mounted) return;

      // Deu tudo certo: vai para a tela Principal já com os dados
      // baixados disponíveis (substituindo a Splash2 na pilha de rotas,
      // então o usuário não volta pra splash com o botão "voltar")
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Principal()),
      );
    } catch (erro) {
      // Se algo der errado ao baixar os dados (ex: DadosService lança
      // exceção quando o token está vazio/inválido), trata como sessão
      // expirada: remove o token salvo...
      // se o token estiver inválido/expirado, remove os dados e volta ao login
      await prefs.remove('tokenAutenticacao');

      if (!mounted) return;

      // ...e manda o usuário de volta para a tela de Login,
      // já que ele precisa se autenticar novamente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login(title: 'Aplicativo')),
      );
    }
  }

  //método de construção da interface da tela
  // Interface simples de carregamento: mensagem de boas-vindas e um
  // spinner, enquanto _carregarDados() roda em segundo plano
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: Color(0xFFE5B0A3), // mesma cor de fundo usada nas outras telas
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