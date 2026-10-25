import 'package:flutter/material.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/telas/TelaSolicitacao.dart';
import 'package:login/visao/telas/TelaHorarios.dart';
import 'package:login/visao/telas/TelaMeusAgendamentos.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  // 0 = Início, 1 = Solicitar, 2 = Agendados
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TelaUm(title: 'Primeira tela'),
    TelaDois(title: 'Segunda tela'),
    TelaTres(title: 'Terceira tela'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _barraInferior(),
    );
  }

  // Barra inferior: ícones da mesma família (outline/preenchido),
  // item ativo com cor de acento e "pílula" suave atrás do ícone
  Widget _barraInferior() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppCores.borda)),
        boxShadow: [
          BoxShadow(
              color: Color(0x143A2E2E), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: Internacionalizacao.opt1,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: Internacionalizacao.opt2,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline_rounded),
            selectedIcon: const Icon(Icons.check_circle_rounded),
            label: Internacionalizacao.opt3,
          ),
        ],
      ),
    );
  }
}

class Internacionalizacao {
  static String opt1 = "Início";
  static String opt2 = "Solicitar";
  static String opt3 = "Agendados";
}