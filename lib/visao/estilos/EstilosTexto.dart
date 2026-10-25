import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/visao/estilos/Tema.dart';

class EstilosTextosCustomizado {
  // Texto digitado nos campos
  static TextStyle formField(BuildContext context) =>
      GoogleFonts.lato(fontSize: 16, color: AppCores.texto);

  // Título grande (serifada)
  static TextStyle title(BuildContext context) => GoogleFonts.playfairDisplay(
      fontSize: 30, fontWeight: FontWeight.w600, color: AppCores.texto);

  static TextStyle subTitle(BuildContext context) =>
      GoogleFonts.lato(fontSize: 14, color: AppCores.textoSuave);

  static TextStyle button(BuildContext context) => GoogleFonts.lato(
      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white);

  static TextStyle body(BuildContext context) =>
      GoogleFonts.lato(fontSize: 14, color: AppCores.texto);

  // NOVOS
  // Título de seção (serifada)
  static TextStyle secao(BuildContext context) => GoogleFonts.playfairDisplay(
      fontSize: 19, fontWeight: FontWeight.w600, color: AppCores.texto);

  // Rótulo pequeno acima dos campos
  static TextStyle rotulo(BuildContext context) => GoogleFonts.lato(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: AppCores.textoSuave);

  // Texto de apoio (datas, descrições)
  static TextStyle apoio(BuildContext context) =>
      GoogleFonts.lato(fontSize: 13.5, color: AppCores.textoSuave);
}