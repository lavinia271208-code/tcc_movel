import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/Tema.dart';

// Classe utilitária com widgets reutilizáveis usados em várias telas
// do app (splashs, login, etc). Não é uma tela em si, apenas um
// "kit" de peças visuais prontas, para não repetir o mesmo código
// em cada arquivo.
class WidgetsUteis {
  // Espaçamentos verticais prontos (apesar do nome "Horizontal", o
  // SizedBox aqui define apenas a ALTURA, então na prática funciona
  // como um espaçamento vertical entre widgets em uma Column)
  SizedBox espacoHorizontal15 = SizedBox(
    height: ScreenUtil().setHeight(15),
  );
  SizedBox espacoHorizontal5 = SizedBox(
    height: ScreenUtil().setHeight(5),
  );

  // Linha fina decorativa
  Widget horizontalLine() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(height: 1.0, color: AppCores.borda),
  );

  // Indicador de carregamento: um anel só, discreto, na cor de acento
  Widget barraCircularProgresso() {
    return const SizedBox(
      height: 36,
      width: 36,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppCores.acento),
      ),
    );
  }
}