import 'package:flutter/material.dart';
import 'package:login/visao/telas/TelaSolicitaçao.dart';
import 'package:login/visao/telas/TelaHorarios.dart';
import 'package:login/visao/telas/TelaMeusAgendamentos.dart';

// Tela "Principal" do app: é o container que fica visível depois do
// login, contendo a barra de navegação inferior e trocando entre as
// 3 telas principais (Horários, Solicitar, Meus agendamentos)
class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {

  // Índice da aba/tela atualmente selecionada na barra inferior
  // (0 = Início, 1 = Solicitar, 2 = Agendados)
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TelaUm(title: 'Primeira tela'),   // Tela de Horários disponíveis
    TelaDois(title: 'Segunda tela'),  // Tela de Solicitar horário
    TelaTres(title: 'Terceira tela'), // Tela de Meus agendamentos
  ];

  // Garante que o app sempre abra mostrando a primeira aba (Início)
  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
  }

  // Monta a interface: exibe a tela correspondente ao índice atual e,
  // embaixo, a barra de navegação
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mostra apenas a tela cujo índice bate com _currentIndex
      body: _screens[_currentIndex],
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  // Constrói a barra de navegação inferior com os 3 ícones/abas
  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      // Marca visualmente qual ícone está selecionado no momento
      currentIndex: _currentIndex,

      // Ao tocar em um item, atualiza o índice e força a tela a
      // reconstruir, o que troca o conteúdo exibido no body
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },

      // Cores do ícone/texto quando selecionado e quando não selecionado
      selectedItemColor: Color(0xFFE5B0A3),
      unselectedItemColor: Colors.grey,

      // Os 3 itens da barra, cada um com ícone e rótulo (texto)
      // vindos da classe Internacionalizacao logo abaixo
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: Internacionalizacao.opt1, // "Início"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: Internacionalizacao.opt2, // "Solicitar"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: Internacionalizacao.opt3, // "Agendados"
        ),
      ],
    );
  }
}

// Classe simples para centralizar os textos usados na barra de
// navegação (mesmo padrão usado em outras telas do app)
class Internacionalizacao {
  static String opt1 = "Início";
  static String opt2 = "Solicitar";
  static String opt3 = "Agendados";
}