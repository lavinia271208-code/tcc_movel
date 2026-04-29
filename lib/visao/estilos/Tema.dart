import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData temaEscuro() {
  final baseTheme = ThemeData(
    fontFamily: "Open Sans",
  );
  return baseTheme.copyWith(
    brightness: Brightness.dark,
    primaryColor: Color(0xFFE5B0A3),
    primaryColorLight: Color(0xFFE5B0A3),
    primaryColorDark: Colors.black,
    highlightColor: Colors.white,
  );
}