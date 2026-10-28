import 'package:flutter/material.dart';
import 'package:login/controle/ControllerLogin.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/telas/Login.dart';
import 'package:login/visao/util/Componentes.dart';

// Tela de SAÍDA da conta (independente da tela de Login).
// Ao abrir, encerra a sessão: avisa a API (revoga o token) e apaga o login
// e os agendamentos salvos no aparelho. Só depois mostra "Você saiu da
// conta", com um botão para voltar à tela de Login.
class TelaSaida extends StatefulWidget {
  const TelaSaida({super.key});

  @override
  State<TelaSaida> createState() => _TelaSaidaState();
}

class _TelaSaidaState extends State<TelaSaida> {
  bool _saindo = true;

  @override
  void initState() {
    super.initState();
    _encerrarSessao();
  }

  Future<void> _encerrarSessao() async {
    // tempo mínimo para a pessoa perceber que algo aconteceu
    await Future.wait([
      CLogin.logoff(),
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
    setState(() => _saindo = false);
  }

  void _voltarAoLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Login(title: 'Aplicativo')),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // o botão "voltar" do aparelho não volta para dentro do app
      child: Scaffold(
        backgroundColor: AppCores.fundo,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset('assets/logo.png',
                        width: 96, height: 96, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 28),
                  if (_saindo) ...[
                    const CircularProgressIndicator(color: AppCores.acento),
                    const SizedBox(height: 20),
                    Text('Saindo da conta...',
                        style: Theme.of(context).textTheme.titleLarge),
                  ] else ...[
                    const Icon(Icons.check_circle_rounded,
                        size: 56, color: AppCores.acento),
                    const SizedBox(height: 14),
                    Text('Você saiu da conta',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Seus dados foram removidos deste aparelho.\nAté logo!',
                      textAlign: TextAlign.center,
                      style: EstilosTextosCustomizado.apoio(context),
                    ),
                    const SizedBox(height: 32),
                    BotaoPrincipal(
                      texto: 'Entrar novamente',
                      icone: Icons.login_rounded,
                      onPressed: _voltarAoLogin,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}