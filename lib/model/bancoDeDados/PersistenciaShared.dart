import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenciaShared {

  //constantes criadas para definir chaves de persistências
  static String KEY_LOGIN = "login";
  static String KEY_AGENDAMENTOS = "AGENDAMENTOS";
  static String KEY_ATUALIZACAO = "ATUALIZACAO";

  /**
   * Método usado para salvar dados em shared_preferences
   */
  Future<void> saveJson(String chave, Map<dynamic, dynamic> jsonValor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(jsonValor);
    await prefs.setString(chave, jsonString);
  }

  /**
   * Método usado para salvar dados em shared_preferences
   */
  Future<void> saveString(String chave, String jsonString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(chave, jsonString);
  }

  /**
   * zera shared
   */
  Future<void> removeShared(String chave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(chave);
  }

  /**
   * método usado para leitura de um json dentro de uma chave
   */
  Future<Map<dynamic, dynamic>?> readJson(String chave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(chave);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  /**
   * método usado para leitura de uma string dentro de uma chave
   */
  Future<String?> readString(String chave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(chave);
    if (jsonString != null) {
      return jsonString;
    }
    return null;
  }
}