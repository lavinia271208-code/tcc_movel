import 'package:url_launcher/url_launcher.dart';

/**
 * Abre links fora do app (WhatsApp, Telegram, telefone, e-mail, mapas).
 *
 * Segue o tutorial do url_launcher: confere com canLaunchUrl e abre com
 * LaunchMode.externalApplication (fora do app Flutter).
 *
 * Todos os métodos devolvem true quando abriram e false quando não foi
 * possível abrir (quem chama decide a mensagem para a usuária).
 *
 * Requisitos nativos (já configurados no projeto):
 * - Android: bloco <queries> em android/app/src/main/AndroidManifest.xml
 * - iOS: chave LSApplicationQueriesSchemes em ios/Runner/Info.plist
 */
class Launcher {

  //função genérica: abre qualquer URL no aplicativo nativo correspondente
  static Future<bool> abrirUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erro ao abrir $url: $e');
    }
    return false;
  }

  //https://wa.me/5511999999999?text=Mensagem
  static Future<bool> abrirWhatsApp(String numero, String mensagem) {
    return abrirUrl(
        'https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}');
  }

  //tel:+5511999999999
  static Future<bool> ligar(String numero) {
    return abrirUrl('tel:$numero');
  }
}