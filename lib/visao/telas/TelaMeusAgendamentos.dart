import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/controle/ControllerAgendamento.dart';
import 'package:login/controle/ControllerSplash.dart';
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/util/Componentes.dart';
import 'TelaSolicitacao.dart';

class TelaTres extends StatefulWidget {
  const TelaTres({super.key, required this.title});

  final String title;

  @override
  State<TelaTres> createState() => _TelaTresState();
}

class _TelaTresState extends State<TelaTres> {
  // Lista de agendamentos carregada do armazenamento local
  // (baixados da API na Splash2 e atualizados a cada alteração)
  List<Agendamento> agendamentos = [];

  // Controla a exibição do spinner enquanto os agendamentos
  // ainda estão sendo lidos do SharedPreferences
  bool _carregando = true;

  // Índice do agendamento selecionado pelo cliente (para
  // desmarcar ou editar). Nulo quando nenhum está selecionado.
  int? _indiceSelecionado;

  // Ao abrir a tela, já dispara a leitura dos agendamentos salvos
  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  // Abre a tela de desmarcar/remarcar e, ao voltar, recarrega a lista
  // (o agendamento pode ter sido cancelado ou remarcado)
  Future<void> _irParaDesmarcarOuEditar() async {
    if (_indiceSelecionado == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDois(
          title: 'Solicitar horário',
          agendamentoOriginal: agendamentos[_indiceSelecionado!],
        ),
      ),
    );

    if (!mounted) return;
    _indiceSelecionado = null;
    _carregarAgendamentos();
  }

  // Lê os agendamentos gravados no shared preferences (baixados na Splash2)
  Future<void> _carregarAgendamentos() async {
    final lista = await CAgendamentos.resgataAgendamentos();

    // Garante que a tela ainda está montada antes de atualizar o estado
    if (!mounted) return;
    setState(() {
      agendamentos = lista;
      _carregando = false;
    });
  }

  // Puxar a lista para baixo: baixa os agendamentos da API de novo
  Future<void> _atualizar() async {
    final status = await CSplash.baixaDados();

    if (!mounted) return;

    if (status != StatusSync.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == StatusSync.naoAutorizado
                ? 'Sessão expirada, faça login novamente.'
                : 'Não foi possível atualizar. Verifique sua conexão.',
          ),
        ),
      );
    }

    _indiceSelecionado = null;
    await _carregarAgendamentos();
  }

  // Estado vazio: ícone, título em serifada e uma frase de apoio
  Widget _estadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.event_available_rounded,
              size: 56,
              color: AppCores.acentoMarca,
            ),
            const SizedBox(height: 14),
            Text(
              'Nenhum agendamento ainda',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Quando você solicitar um horário, ele aparece aqui.',
              textAlign: TextAlign.center,
              style: EstilosTextosCustomizado.apoio(context),
            ),
          ],
        ),
      ),
    );
  }

  // Selo de situação: "Confirmado" para os próximos e "Realizado" para
  // os que já passaram (a API não tem um campo de status)
  Widget _selo(Agendamento item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: item.jaPassou ? AppCores.indisponivel : AppCores.acentoPalido,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.jaPassou ? 'Realizado' : 'Confirmado',
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: item.jaPassou ? AppCores.textoSuave : AppCores.acentoTexto,
        ),
      ),
    );
  }

  // Cartão de um agendamento
  Widget _cartaoAgendamento(Agendamento item, int indice) {
    // Verifica se este é o card selecionado
    final bool selecionado = _indiceSelecionado == indice;

    // GestureDetector torna o card inteiro clicável
    return GestureDetector(
      onTap: () {
        setState(() {
          _indiceSelecionado = selecionado ? null : indice;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          // Borda destacada na cor do app somente quando selecionado
          border: Border.all(
            color: selecionado ? AppCores.acento : AppCores.borda,
            width: selecionado ? 2 : 1,
          ),

          // Sombra leve para dar profundidade
          boxShadow: AppEstilos.sombra,
        ),
        child: Row(
          children: [
            // Ícone em "bolha" (cinza quando já passou)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.jaPassou
                    ? AppCores.indisponivel
                    : AppCores.acentoPalido,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: item.jaPassou ? AppCores.textoSuave : AppCores.acento,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // dia
                  Text(
                    item.diaFormatado,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppCores.texto,
                    ),
                  ),

                  const SizedBox(height: 2),

                  // hora e serviço
                  Text(
                    '${item.horaFormatada}  •  ${item.servicoNome}',
                    style: EstilosTextosCustomizado.apoio(context),
                  ),

                  const SizedBox(height: 10),

                  // situação
                  _selo(item),
                ],
              ),
            ),

            // Marca de selecionado
            if (selecionado)
              const Icon(Icons.check_circle_rounded, color: AppCores.acento),
          ],
        ),
      ),
    );
  }

  // INTERFACE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBelle(context, 'Meus agendamentos'),

      // Três estados possíveis do corpo da tela:
      // carregando -> spinner; lista vazia -> mensagem;
      // lista com itens -> lista + botão fixo no rodapé
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : agendamentos.isEmpty
          ? _estadoVazio()
          : Column(
        children: [
          // LISTA DE AGENDAMENTOS
          Expanded(
            child: RefreshIndicator(
              color: AppCores.acento,
              onRefresh: _atualizar,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                // +1 por causa do texto de dica no começo da lista
                itemCount: agendamentos.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Toque em um agendamento para desmarcar ou remarcar.',
                        style: EstilosTextosCustomizado.apoio(context),
                      ),
                    );
                  }

                  final int i = index - 1;
                  return _cartaoAgendamento(agendamentos[i], i);
                },
              ),
            ),
          ),

          // BOTÃO "DESMARCAR OU EDITAR HORÁRIO"
          // Fixo no rodapé; fica cinza até selecionar um agendamento
          RodapeFixo(
            child: BotaoPrincipal(
              texto: 'Desmarcar ou editar horário',
              icone: Icons.edit_calendar_rounded,
              onPressed: _indiceSelecionado == null
                  ? null
                  : _irParaDesmarcarOuEditar,
            ),
          ),
        ],
      ),
    );
  }
}