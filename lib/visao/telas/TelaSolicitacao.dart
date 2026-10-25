import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login/controle/ControllerAgendamento.dart';
import 'package:login/controle/ControllerSplash.dart';
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/model/Objects/Servico.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/util/Componentes.dart';
import 'TelaHorarios.dart';

// TELA DE SOLICITAÇÃO

const String _numeroWhatsApp = '5537998072287';

// Tem três modos:
// - criação: chega da tela de Horários com [servico] e [dataHora] escolhidos.
//   A cliente pede o horário pelo WhatsApp e, depois que a administradora
//   confirmar, adiciona o agendamento aos "Meus agendamentos" (API);
// - edição: chega da tela "Meus agendamentos" com [agendamentoOriginal].
//   A cliente escolhe um novo horário (remarcar) ou pede o cancelamento
//   pelo WhatsApp e, depois que a administradora confirmar, cancela na API;
// - remarcação: chega da tela de Horários (modo remarcar) com
//   [agendamentoOriginal] + [servico] + [dataHora] (o NOVO horário).
//   A cliente pede a remarcação pelo WhatsApp e, depois que a
//   administradora confirmar, remarca na API.
class TelaDois extends StatefulWidget {
  const TelaDois({
    super.key,
    required this.title,
    this.servico,
    this.dataHora,
    this.agendamentoOriginal,
  });

  final String title;

  // Serviço, dia e horário escolhidos na tela de Horários
  final Servico? servico;
  final DateTime? dataHora;

  // Preenchido quando o cliente veio da tela "Meus agendamentos"
  // pedindo para desmarcar ou editar um agendamento já existente
  final Agendamento? agendamentoOriginal;

  @override
  State<TelaDois> createState() => _TelaDoisState();
}

class _TelaDoisState extends State<TelaDois> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _servicoController = TextEditingController();

  bool _enviando = false;

  bool get _temOriginal => widget.agendamentoOriginal != null;

  // Remarcação: tem o agendamento original E o novo horário escolhido
  bool get _modoRemarcacao => _temOriginal && widget.dataHora != null;

  // Edição: tem o agendamento original, mas ainda sem novo horário
  bool get _modoEdicao => _temOriginal && !_modoRemarcacao;

  String? get _diaExibido {
    if (_modoEdicao) return widget.agendamentoOriginal!.diaFormatado;
    final dataHora = widget.dataHora;
    return dataHora == null ? null : Agendamento.formataDia(dataHora);
  }

  String? get _horaExibido {
    if (_modoEdicao) return widget.agendamentoOriginal!.horaFormatada;
    final dataHora = widget.dataHora;
    return dataHora == null ? null : Agendamento.formataHora(dataHora);
  }

  @override
  void initState() {
    super.initState();

    // O nome já é conhecido pelo login (só é usado na mensagem do WhatsApp)
    _nomeController.text = loginGlobal.nome;

    // Mostra o serviço do agendamento original (edição) ou o serviço
    // escolhido na tela de Horários (criação e remarcação)
    if (_modoEdicao) {
      _servicoController.text = widget.agendamentoOriginal!.servicoNome;
    } else {
      _servicoController.text = widget.servico?.nome ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _servicoController.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // ADICIONA O AGENDAMENTO AOS "MEUS AGENDAMENTOS" (API)
  // Só deve ser usado depois que a administradora confirmar o horário

  // Primeiro pergunta se a administradora já confirmou, para evitar
  // que a cliente adicione sem querer
  Future<void> _perguntarEAdicionar() async {
    if (widget.servico == null || widget.dataHora == null) {
      _mostrarMensagem('Selecione um horário na aba "Horários" antes de adicionar.');
      return;
    }

    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (contextDialogo) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Adicionar aos meus agendamentos',
          style: Theme.of(contextDialogo).textTheme.titleLarge,
        ),
        content: Text(
          'A administradora já confirmou o horário das $_horaExibido '
              'do dia $_diaExibido?\n\n'
              'Se ainda não confirmou, aguarde a resposta dela no WhatsApp '
              'antes de adicionar.',
          style: EstilosTextosCustomizado.body(contextDialogo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, false),
            child: Text(
              'Ainda não',
              style: GoogleFonts.lato(
                color: AppCores.textoSuave,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, true),
            child: Text(
              'Sim, adicionar',
              style: GoogleFonts.lato(
                color: AppCores.acentoTexto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _confirmarAgendamento();
    }
  }

  // Cria o agendamento na API e atualiza os dados salvos no aparelho
  Future<void> _confirmarAgendamento() async {
    final servico = widget.servico;
    final dataHora = widget.dataHora;

    if (servico == null || dataHora == null) {
      _mostrarMensagem('Selecione um horário na aba "Horários" antes de adicionar.');
      return;
    }

    // Mostra o carregamento
    setState(() {
      _enviando = true;
    });

    final erro = await CAgendamentos.criaAgendamento(
      servicoId: servico.id,
      dataHora: dataHora,
    );

    if (!mounted) return;

    // Para o carregamento
    setState(() {
      _enviando = false;
    });

    // Ex: "O horário selecionado está indisponível."
    // (acontece se outra cliente já adicionou esse horário antes)
    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _mostrarMensagem('Horário adicionado! Veja na aba "Agendados".');

    // Volta para a tela de Horários (true = adicionou, ela atualiza a grade)
    Navigator.pop(context, true);
  }

  // REMARCA O AGENDAMENTO NA API (modo remarcação)
  // Só deve ser usado depois que a administradora confirmar o novo horário

  Future<void> _perguntarERemarcar() async {
    if (!_modoRemarcacao || widget.servico == null) {
      _mostrarMensagem('Não foi possível identificar o novo horário.');
      return;
    }

    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (contextDialogo) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remarcar agendamento',
          style: Theme.of(contextDialogo).textTheme.titleLarge,
        ),
        content: Text(
          'A administradora já confirmou a remarcação para o dia '
              '$_diaExibido às $_horaExibido?\n\n'
              'Se ainda não confirmou, aguarde a resposta dela no WhatsApp '
              'antes de remarcar.',
          style: EstilosTextosCustomizado.body(contextDialogo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, false),
            child: Text(
              'Ainda não',
              style: GoogleFonts.lato(
                color: AppCores.textoSuave,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, true),
            child: Text(
              'Sim, remarcar',
              style: GoogleFonts.lato(
                color: AppCores.acentoTexto,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await _confirmarRemarcacao();
    }
  }

  Future<void> _confirmarRemarcacao() async {
    final original = widget.agendamentoOriginal;
    final servico = widget.servico;
    final dataHora = widget.dataHora;

    if (original == null || servico == null || dataHora == null) return;

    setState(() {
      _enviando = true;
    });

    final erro = await CAgendamentos.remarcaAgendamento(
      id: original.id,
      dataHora: dataHora,
      servicoId: servico.id,
    );

    if (!mounted) return;

    setState(() {
      _enviando = false;
    });

    // Ex: horário ocupado por outra cliente enquanto esperava a confirmação
    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _mostrarMensagem('Agendamento remarcado com sucesso!');

    // true = remarcou (as telas anteriores fecham e a lista é atualizada)
    Navigator.pop(context, true);
  }

  // CANCELA O AGENDAMENTO NA API
  // Só deve ser usado depois que a administradora confirmar o cancelamento

  Future<void> _cancelarAgendamento() async {
    final original = widget.agendamentoOriginal;
    if (original == null) return;

    final bool? confirmou = await showDialog<bool>(
      context: context,
      builder: (contextDialogo) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancelar agendamento',
          style: Theme.of(contextDialogo).textTheme.titleLarge,
        ),
        content: Text(
          'A administradora já confirmou o cancelamento de '
              '${original.servicoNome} em ${original.diaFormatado} '
              'às ${original.horaFormatada}?\n\n'
              'Se ainda não confirmou, aguarde a resposta dela no WhatsApp '
              'antes de cancelar.',
          style: EstilosTextosCustomizado.body(contextDialogo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, false),
            child: Text(
              'Ainda não',
              style: GoogleFonts.lato(
                color: AppCores.textoSuave,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contextDialogo, true),
            child: Text(
              'Sim, cancelar',
              style: GoogleFonts.lato(
                color: AppCores.perigo,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    setState(() {
      _enviando = true;
    });

    final erro = await CAgendamentos.cancelaAgendamento(original.id);

    if (!mounted) return;

    setState(() {
      _enviando = false;
    });

    if (erro != null) {
      _mostrarMensagem(erro);
      return;
    }

    _mostrarMensagem('Agendamento cancelado com sucesso!');
    Navigator.pop(context, true);
  }

  // ESCOLHER NOVO HORÁRIO: abre a tela de Horários em modo "remarcar".
  // Lá a cliente escolhe o novo dia/hora e segue para a solicitação.

  Future<void> _remarcarAgendamento() async {
    final original = widget.agendamentoOriginal;
    if (original == null) return;

    final bool? remarcou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaUm(
          title: 'Remarcar horário',
          agendamentoParaRemarcar: original,
        ),
      ),
    );

    if (!mounted) return;

    // Já remarcou: volta para a lista de agendamentos
    if (remarcou == true) {
      Navigator.pop(context, true);
    }
  }

  // ABRE O WHATSAPP

  Future<void> _abrirWhatsApp() async {
    if (_diaExibido == null || _horaExibido == null) {
      _mostrarMensagem(
        _temOriginal
            ? 'Não foi possível identificar o agendamento selecionado.'
            : 'Selecione um horário na aba "Horários" antes de conversar.',
      );

      return;
    }

    // Verifica se o nome foi preenchido
    if (_nomeController.text.trim().isEmpty) {
      _mostrarMensagem('Preencha seu nome antes de conversar.');

      return;
    }

    // CRIA A MENSAGEM DO WHATSAPP

    final String nome = _nomeController.text.trim();
    final String servico = _servicoController.text.trim();

    final String mensagem;

    if (_modoRemarcacao) {
      // Remarcação: informa o horário atual e o novo horário desejado
      final original = widget.agendamentoOriginal!;
      mensagem = 'Oi, tudo bem? Eu sou $nome '
          'e gostaria de remarcar meu agendamento de '
          '${original.servicoNome} '
          'do dia ${original.diaFormatado} '
          'às ${original.horaFormatada} '
          'para o dia $_diaExibido '
          'às $_horaExibido, '
          'com o serviço $servico. '
          'Você consegue me confirmar? '
          'Obrigada(o)!';
    } else if (_modoEdicao) {
      // Edição: nesta tela o pedido por WhatsApp é de cancelamento
      mensagem = 'Oi, tudo bem? Eu sou $nome '
          'e gostaria de cancelar meu agendamento de '
          '$servico '
          'no dia $_diaExibido '
          'às $_horaExibido. '
          'Obrigada(o)!';
    } else {
      // Criação: pedido de um horário novo
      mensagem = 'Oi, tudo bem? Eu sou $nome '
          'e gostaria de solicitar o horário para '
          '$servico '
          'no dia $_diaExibido '
          'às $_horaExibido. '
          'Você consegue me confirmar? '
          'Obrigada(o)!';
    }

    // CRIA O LINK DO WHATSAPP

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$_numeroWhatsApp'
          '?text=${Uri.encodeComponent(mensagem)}',
    );

    // ABRE O WHATSAPP

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        _mostrarMensagem('Não foi possível abrir o WhatsApp.');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem('Não foi possível abrir o WhatsApp.');
    }
  }

  // INTERFACE

  @override
  Widget build(BuildContext context) {
    final bool temHorarioSelecionado =
        _diaExibido != null && _horaExibido != null;

    return Scaffold(
      // Cabeçalho claro com logo, título em serifada e seta de voltar
      appBar: appBarBelle(
        context,
        _modoEdicao
            ? 'Desmarcar ou editar'
            : _modoRemarcacao
            ? 'Remarcar horário'
            : 'Solicitar horário',
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HORÁRIO ESCOLHIDO ----------
            CartaoBelle(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppCores.acentoPalido,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: AppCores.acento,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _modoEdicao
                              ? 'Seu agendamento'
                              : _modoRemarcacao
                              ? 'Novo horário escolhido'
                              : 'Horário escolhido',
                          style: EstilosTextosCustomizado.rotulo(context),
                        ),
                        const SizedBox(height: 4),
                        if (temHorarioSelecionado) ...[
                          Text(
                            '$_horaExibido',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppCores.texto,
                            ),
                          ),
                          Text(
                            '$_diaExibido',
                            style: EstilosTextosCustomizado.apoio(context),
                          ),

                          // Na remarcação, lembra qual era o horário antigo
                          if (_modoRemarcacao) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Antes: ${widget.agendamentoOriginal!.diaFormatado} '
                                  'às ${widget.agendamentoOriginal!.horaFormatada}',
                              style: EstilosTextosCustomizado.apoio(context),
                            ),
                          ],
                        ] else
                          Text(
                            'Nenhum horário selecionado ainda',
                            style: EstilosTextosCustomizado.apoio(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- SEU NOME ----------
            Text('Seu nome', style: EstilosTextosCustomizado.rotulo(context)),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              style: EstilosTextosCustomizado.formField(context),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- SERVIÇO (escolhido na tela de Horários; não é editável aqui) ----------
            Text(
              _modoEdicao ? 'Serviço agendado' : 'Serviço desejado',
              style: EstilosTextosCustomizado.rotulo(context),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _servicoController,
              readOnly: true,
              style: EstilosTextosCustomizado.formField(context),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.spa_outlined),
                fillColor: AppCores.acentoPalido,
              ),
            ),

            const SizedBox(height: 32),

            // ---------- BOTÕES ----------
            if (_modoEdicao) ...[
              // REMARCAR: escolhe o novo dia/horário e, na tela seguinte,
              // pede a remarcação pelo WhatsApp
              Text(
                'Quer outro dia ou horário?',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoPrincipal(
                texto: 'Escolher novo horário',
                icone: Icons.event_repeat_rounded,
                onPressed: _enviando ? null : _remarcarAgendamento,
              ),

              const SizedBox(height: 28),

              // CANCELAR: pede pelo WhatsApp e, depois da confirmação, cancela
              Text(
                'Quer cancelar?',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoSecundario(
                texto: 'Pedir cancelamento no WhatsApp',
                icone: Icons.chat_bubble_outline_rounded,
                onPressed: _enviando ? null : _abrirWhatsApp,
              ),

              const SizedBox(height: 16),

              Text(
                'Depois que ela confirmar',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoSecundario(
                texto: _enviando ? 'Cancelando...' : 'Cancelar agendamento',
                icone: Icons.event_busy_rounded,
                cor: AppCores.perigo,
                onPressed: _enviando ? null : _cancelarAgendamento,
              ),
            ] else if (_modoRemarcacao) ...[
              // Remarcação, em dois passos

              // Passo 1: pedir a remarcação à administradora
              Text(
                '1. Peça a remarcação à administradora',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoPrincipal(
                texto: 'Conversar no WhatsApp',
                icone: Icons.chat_bubble_outline_rounded,
                onPressed: _enviando ? null : _abrirWhatsApp,
              ),

              const SizedBox(height: 28),

              // Passo 2: depois da confirmação, remarcar de verdade
              Text(
                '2. Depois que ela confirmar',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoSecundario(
                texto: _enviando ? 'Remarcando...' : 'Remarcar meu agendamento',
                icone: Icons.event_repeat_rounded,
                onPressed: _enviando ? null : _perguntarERemarcar,
              ),
            ] else ...[
              // Novo pedido, em dois passos

              // Passo 1: pedir o horário à administradora
              Text(
                '1. Peça o horário à administradora',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoPrincipal(
                texto: 'Conversar no WhatsApp',
                icone: Icons.chat_bubble_outline_rounded,
                onPressed: _enviando ? null : _abrirWhatsApp,
              ),

              const SizedBox(height: 28),

              // Passo 2: depois da confirmação, adicionar aos agendamentos
              Text(
                '2. Depois que ela confirmar',
                style: EstilosTextosCustomizado.rotulo(context),
              ),
              const SizedBox(height: 8),
              BotaoSecundario(
                texto: _enviando
                    ? 'Adicionando...'
                    : 'Adicionar aos meus agendamentos',
                icone: Icons.event_available_rounded,
                onPressed: _enviando ? null : _perguntarEAdicionar,
              ),
            ],
          ],
        ),
      ),
    );
  }
}