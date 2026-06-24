import 'package:flutter/material.dart';
import 'package:login/visao/telas/TelaSolicitaçao.dart';
import 'package:login/visao/telas/TelaHorarios.dart';
import 'package:login/visao/telas/TelaMeusAgendamentos.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

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
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: Color(0xFFE5B0A3),
      unselectedItemColor: Colors.grey,

      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: Internacionalizacao.opt1,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: Internacionalizacao.opt2,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: Internacionalizacao.opt3,
        ),
      ],
    );
  }
}

class Internacionalizacao {
  static String opt1 = "Início";
  static String opt2 = "Solicitar";
  static String opt3 = "Agendados";
}