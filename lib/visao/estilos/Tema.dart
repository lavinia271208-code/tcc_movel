import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta única do app (mesma do web)
class AppCores {
  static const Color fundo = Color(0xFFFAF5F0);
  static const Color cartao = Colors.white;
  static const Color acento = Color(0xFFC9847A);       // ações e seleção
  static const Color acentoTexto = Color(0xFFA9645A);  // texto/ícone de acento sobre branco (mais contraste)
  static const Color acentoMarca = Color(0xFFE5B0A3);  // o rosa original
  static const Color acentoPalido = Color(0xFFF6E3DD);
  static const Color texto = Color(0xFF3A2E2E);
  static const Color textoSuave = Color(0xFF7A6A68);
  static const Color borda = Color(0xFFF0E1DC);
  static const Color desabilitado = Color(0xFFE9DFDB);
  static const Color indisponivel = Color(0xFFF1EBE7);
  static const Color perigo = Color(0xFFB3473F);
}

class AppEstilos {
  static const double raio = 14;
  static const List<BoxShadow> sombra = [
    BoxShadow(color: Color(0x0F3A2E2E), blurRadius: 10, offset: Offset(0, 2)),
  ];
}

ThemeData temaApp() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppCores.acento,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppCores.acento,
      onPrimary: Colors.white,
      surface: AppCores.fundo,
      onSurface: AppCores.texto,
      error: AppCores.perigo,
    ),
  );

  final textoBase = GoogleFonts.latoTextTheme(base.textTheme)
      .apply(bodyColor: AppCores.texto, displayColor: AppCores.texto);

  return base.copyWith(
    scaffoldBackgroundColor: AppCores.fundo,
    primaryColor: AppCores.acento,
    primaryColorLight: AppCores.acentoMarca,
    textTheme: textoBase.copyWith(
      headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 30, fontWeight: FontWeight.w600, color: AppCores.texto),
      titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 21, fontWeight: FontWeight.w600, color: AppCores.texto),
      titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 17, fontWeight: FontWeight.w600, color: AppCores.texto),
    ),
    progressIndicatorTheme:
    const ProgressIndicatorThemeData(color: AppCores.acento),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.lato(color: AppCores.textoSuave.withOpacity(0.7)),
      prefixIconColor: AppCores.textoSuave,
      suffixIconColor: AppCores.textoSuave,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppCores.borda),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppCores.borda),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppCores.acento, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppCores.perigo),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppCores.perigo, width: 1.6),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppCores.acentoPalido,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((estados) {
        final sel = estados.contains(WidgetState.selected);
        return GoogleFonts.lato(
          fontSize: 12,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
          color: sel ? AppCores.acentoTexto : AppCores.textoSuave,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((estados) {
        final sel = estados.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: sel ? AppCores.acento : AppCores.textoSuave,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppCores.texto,
      contentTextStyle: GoogleFonts.lato(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}