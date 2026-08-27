import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Splash1.dart';

// Classe utilitária com widgets reutilizáveis usados em várias telas
// do app (splashs, login, etc). Não é uma tela em si, apenas um
// "kit" de peças visuais prontas, para não repetir o mesmo código
// em cada arquivo.
class WidgetsUteis{
  //organizadores
  // Espaçamentos verticais prontos (apesar do nome "Horizontal", o
  // SizedBox aqui define apenas a ALTURA, então na prática funciona
  // como um espaçamento vertical entre widgets em uma Column)
  SizedBox espacoHorizontal15 = SizedBox(
    height: ScreenUtil().setHeight(15),
  );
  SizedBox espacoHorizontal5 = SizedBox(
    height: ScreenUtil().setHeight(5),
  );

  // Uma linha horizontal fina e semitransparente, usada como
  // elemento decorativo (por exemplo, ao lado do "-" na tela de Login,
  // separando visualmente o formulário de outra seção)
  Widget horizontalLine() =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 1.0,
          color: Colors.white.withOpacity(0.6),
        ),
      );

  // Indicador de carregamento "customizado": em vez de um único
  // CircularProgressIndicator, sobrepõe DOIS círculos de tamanhos
  // diferentes (100 e 150) e opacidades diferentes (branco 70% e
  // branco 100%), criando um efeito visual de "anéis duplos"
  // girando. Usado nas telas de Splash enquanto os dados carregam.
  Widget barraCircularProgresso() {
    return Stack(
      alignment: Alignment.center, // centraliza os dois círculos um sobre o outro
      children: [
        // Círculo menor, mais transparente (fica "atrás")
        Container(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              strokeWidth: 8.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            )
        ),
        // Círculo maior, branco sólido (fica "na frente"/por cima)
        Container(
            height: 150,
            width: 150,
            child: CircularProgressIndicator(
              strokeWidth: 8.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
        ),
      ],
    );
  }
}