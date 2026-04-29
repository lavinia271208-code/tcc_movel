import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Splash1.dart';

class WidgetsUteis{
  //organizadores
  SizedBox espacoHorizontal15 = SizedBox(
    height: ScreenUtil().setHeight(15),
  );
  SizedBox espacoHorizontal5 = SizedBox(
    height: ScreenUtil().setHeight(5),
  );
  Widget horizontalLine() =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          height: 1.0,
          color: Colors.white.withOpacity(0.6),
        ),
  );

  Widget barraCircularProgresso() {
    return Stack(
    alignment: Alignment.center,
      children: [
        Container(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              strokeWidth: 8.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            )
        ),
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