import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/telas/Splash1.dart';

// método que chama a classe inicial da aplicação
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // habilitando o pacote screen_util
  await ScreenUtil.ensureScreenSize();

  runApp(const MyApp());
}

// classe inicial da aplicação
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaApp(), // tema criado em estilos / Tema.dart
      home: Splash1(), // chamando a tela de splash
    );
  }
}