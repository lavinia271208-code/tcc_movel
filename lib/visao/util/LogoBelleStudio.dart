import 'package:flutter/material.dart';

// Logo do app com o nome "Belle Studio" logo abaixo.
// Usada nas barras de título das telas (AppBar com toolbarHeight maior,
// para caber a logo + o texto).
// O texto "Belle Studio" é branco por padrão (dá para mudar em [corTexto]).
class LogoBelleStudio extends StatelessWidget {
  const LogoBelleStudio({super.key, this.altura = 40, this.tamanhoFonte = 11, this.corTexto = Colors.white});

  // altura da imagem da logo
  final double altura;

  // tamanho da fonte do texto "Belle Studio"
  final double tamanhoFonte;

  // cor do texto "Belle Studio"
  final Color corTexto;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo.png', height: altura),
        Text(
          'Belle Studio',
          style: TextStyle(
            fontSize: tamanhoFonte,
            fontWeight: FontWeight.w600,
            color: corTexto,
          ),
        ),
      ],
    );
  }
}