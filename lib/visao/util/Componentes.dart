import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/estilos/Tema.dart';

// Cabeçalho claro: logo redondo + título em serifada.
// Mostra a seta de voltar automaticamente quando a tela foi "empurrada".
AppBar appBarBelle(BuildContext context, String titulo) {
  return AppBar(
    toolbarHeight: 68,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    shape: const Border(bottom: BorderSide(color: AppCores.borda)),
    iconTheme: const IconThemeData(color: AppCores.texto),
    title: Row(
      children: [
        ClipOval(
          child: Image.asset('assets/logo.png',
              width: 40, height: 40, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    ),
  );
}

// Cartão branco com borda sutil e sombra leve
class CartaoBelle extends StatelessWidget {
  const CartaoBelle({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppCores.cartao,
        borderRadius: BorderRadius.circular(AppEstilos.raio + 2),
        border: Border.all(color: AppCores.borda),
        boxShadow: AppEstilos.sombra,
      ),
      child: child,
    );
  }
}

// Título de seção (serifada) com subtítulo opcional
class TituloSecao extends StatelessWidget {
  const TituloSecao(this.texto, {super.key, this.subtitulo});

  final String texto;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto, style: EstilosTextosCustomizado.secao(context)),
        if (subtitulo != null) ...[
          const SizedBox(height: 2),
          Text(subtitulo!, style: EstilosTextosCustomizado.apoio(context)),
        ],
      ],
    );
  }
}

// Botão principal (preenchido). onPressed null = desabilitado (cinza).
class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppCores.acento,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          carregando ? AppCores.acento : AppCores.desabilitado,
          disabledForegroundColor:
          carregando ? Colors.white : AppCores.textoSuave,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEstilos.raio)),
          textStyle:
          GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: carregando
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2.4, color: Colors.white),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(texto)),
          ],
        ),
      ),
    );
  }
}

// Botão secundário (com borda)
class BotaoSecundario extends StatelessWidget {
  const BotaoSecundario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.cor = AppCores.acentoTexto,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cor,
          side: BorderSide(color: cor.withOpacity(0.45)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppEstilos.raio)),
          textStyle:
          GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[
              Icon(icone, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(texto)),
          ],
        ),
      ),
    );
  }
}

// Faixa fixa no rodapé da tela (para o botão de ação principal)
class RodapeFixo extends StatelessWidget {
  const RodapeFixo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppCores.fundo,
        border: Border(top: BorderSide(color: AppCores.borda)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}