import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:login/controle/ControllerAgendamento.dart';
import 'package:login/controle/ControllerServicos.dart';
import 'package:login/model/Objects/Agendamento.dart';
import 'package:login/model/Objects/Servico.dart';
import 'package:login/visao/util/LogoBelleStudio.dart';
import 'TelaSolicitacao.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login/visao/estilos/Tema.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/util/Componentes.dart';

class TelaUm extends StatefulWidget {
  const TelaUm({super.key, required this.title, this.agendamentoParaRemarcar});

  final String title;

  final Agendamento? agendamentoParaRemarcar;

  @override
  State<TelaUm> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaUm> {
  // Quantos dias (sem contar domingos) aparecem no carrossel
  static const int _quantidadeDias = 12;

  static const List<String> _semana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const List<String> _semanaCompleta = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo',
  ];

  // Próximos dias de funcionamento (o estúdio não abre aos domingos)
  late final List<DateTime> dias;

  // Dia atualmente selecionado no carrossel (começa no primeiro dia)
  DateTime? _diaSelecionado;

  // Serviços vindos da API e o serviço escolhido
  List<Servico> servicos = [];
  Servico? _servicoSelecionado;
  bool _carregandoServicos = true;

  // Horário escolhido pelo usuário dentre os disponíveis do dia
  // (null enquanto nada foi selecionado)
  String? _horarioSelecionado;

  // Lista de horários do dia selecionado, cada item com o campo
  // 'hora' e 'ativo' (indica se está disponível ou já ocupado)
  List<Map<String, dynamic>> horarios = [];

  // Controla a exibição do spinner enquanto os horários do dia
  // estão sendo buscados
  bool _carregandoHorarios = false;

  bool get _modoRemarcar => widget.agendamentoParaRemarcar != null;

  // Junta o dia e a hora escolhidos em um DateTime (null se faltar algum)
  DateTime? get _dataHoraSelecionada {
    final dia = _diaSelecionado;
    final hora = _horarioSelecionado;
    if (dia == null || hora == null) return null;

    final partes = hora.split(':');
    return DateTime(dia.year, dia.month, dia.day, int.parse(partes[0]), int.parse(partes[1]));
  }

  // Ao iniciar a tela, monta os dias e busca os serviços (e, em seguida,
  // os horários do primeiro dia)
  @override
  void initState() {
    super.initState();
    dias = _proximosDias(_quantidadeDias);
    _diaSelecionado = dias.first;
    _carregarServicos();
  }

  List<DateTime> _proximosDias(int quantidade) {
    final hoje = DateTime.now();
    final lista = <DateTime>[];
    var dia = DateTime(hoje.year, hoje.month, hoje.day);

    while (lista.length < quantidade) {
      if (dia.weekday != DateTime.sunday) {
        lista.add(dia);
      }
      dia = DateTime(dia.year, dia.month, dia.day + 1);
    }
    return lista;
  }

  // Baixa a lista de serviços da API e já seleciona um (no modo remarcar,
  // o serviço do agendamento original)
  Future<void> _carregarServicos() async {
    final lista = await CServicos.listagemServicos();

    if (!mounted) return;

    Servico? escolhido;
    if (lista.isNotEmpty) {
      final original = widget.agendamentoParaRemarcar;
      escolhido = original == null
          ? lista.first
          : lista.firstWhere((s) => s.id == original.servicoId, orElse: () => lista.first);
    }

    setState(() {
      servicos = lista;
      _servicoSelecionado = escolhido;
      _carregandoServicos = false;
    });

    if (escolhido != null) {
      _buscarHorarios();
    }
  }

  // Busca na API os horários do dia/serviço selecionados
  Future<void> _buscarHorarios() async {
    final servico = _servicoSelecionado;
    final dia = _diaSelecionado;
    if (servico == null || dia == null) return;

    // Enquanto busca, mostra o spinner e limpa o horário selecionado
    // anteriormente (já que ele era de outro dia/serviço)
    setState(() {
      _carregandoHorarios = true;
      _horarioSelecionado = null;
    });

    final resultado = await CAgendamentos.buscaHorarios(
      dia,
      servico.id,
      ignorarAgendamentoId: widget.agendamentoParaRemarcar?.id,
    );

    // Garante que a tela ainda está montada antes de atualizar o estado
    if (!mounted) return;

    // Se a pessoa já trocou de dia/serviço enquanto esperava, descarta esta
    // resposta (a busca mais nova é quem atualiza a tela)
    if (servico != _servicoSelecionado || dia != _diaSelecionado) return;

    if (resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar os horários.')),
      );
    }

    setState(() {
      horarios = resultado ?? [];
      _carregandoHorarios = false;
    });
  }
  Future<void> _acaoPrincipal() async {
    final dataHora = _dataHoraSelecionada;
    final servico = _servicoSelecionado;

    // Proteção extra: não deveria ser chamado sem horário selecionado
    // (o botão já fica desabilitado nesse caso), mas garante de novo aqui
    if (dataHora == null || servico == null) return;

    if (_modoRemarcar) {
      // Mesma lógica do pedido de horário: abre a tela de solicitação com o
      // novo horário. Volta com true quando a remarcação foi concluída.
      final bool? remarcou = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => TelaDois(
            title: 'Remarcar horário',
            servico: servico,
            dataHora: dataHora,
            agendamentoOriginal: widget.agendamentoParaRemarcar,
          ),
        ),
      );

      if (!mounted) return;

      if (remarcou == true) {
        Navigator.pop(context, true);
      } else {
        // pode ter sido ocupado por outra cliente: atualiza a grade
        _buscarHorarios();
      }
      return;
    }

    // abre a tela de solicitação NOVA por cima (com seta de voltar, sem barra
    // inferior). Volta com true quando o agendamento foi criado.
    final bool? agendou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDois(
          title: 'Solicitar horário',
          servico: servico,
          dataHora: dataHora,
        ),
      ),
    );

    if (!mounted) return;

    // o horário escolhido acabou de ser ocupado: atualiza a grade
    if (agendou == true) {
      _buscarHorarios();
    }
  }

  // Ex: "Segunda-feira, 28/09/2026"
  String _diaPorExtenso(DateTime dia) {
    final dd = dia.day.toString().padLeft(2, '0');
    final mm = dia.month.toString().padLeft(2, '0');
    return '${_semanaCompleta[dia.weekday - 1]}, $dd/$mm/${dia.year}';
  }

  // Bloco de escolha do serviço (chips horizontais + preço em destaque)
  Widget _blocoServicos() {
    if (_carregandoServicos) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (servicos.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text('Não foi possível carregar os serviços.',
                style: EstilosTextosCustomizado.apoio(context)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _carregandoServicos = true);
              _carregarServicos();
            },
            child: Text('Tentar novamente',
                style: GoogleFonts.lato(
                    color: AppCores.acentoTexto, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    }

    final escolhido = _servicoSelecionado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 46,
          // degradê na borda direita indica que a lista rola
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0, 0.93, 1],
            ).createShader(rect),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              children: servicos.map((servico) {
                final bool selecionado = servico.id == escolhido?.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(servico.nome),
                    selected: selecionado,
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    selectedColor: AppCores.acento,
                    side: BorderSide(
                        color: selecionado ? AppCores.acento : AppCores.borda),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    labelStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      color: selecionado ? Colors.white : AppCores.texto,
                    ),
                    onSelected: (_) {
                      if (selecionado) return;
                      setState(() => _servicoSelecionado = servico);
                      _buscarHorarios();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (escolhido != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                escolhido.precoFormatado,
                style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppCores.acentoTexto),
              ),
              const SizedBox(width: 8),
              Text('•  ${escolhido.duracaoMinutos} min',
                  style: EstilosTextosCustomizado.apoio(context)),
            ],
          ),
        ],
      ],
    );
  }

  // Estado vazio da grade de horários
  Widget _mensagemVazia(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.event_busy_rounded,
                size: 36, color: AppCores.acentoMarca),
            const SizedBox(height: 8),
            Text(texto,
                textAlign: TextAlign.center,
                style: EstilosTextosCustomizado.apoio(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1304));

    final diaAtual = _diaSelecionado;
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    return Scaffold(
      appBar: appBarBelle(
          context, _modoRemarcar ? 'Remarcar horário' : 'Horários disponíveis'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- SERVIÇO ----------
                  CartaoBelle(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TituloSecao('Serviço'),
                        const SizedBox(height: 14),
                        _blocoServicos(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- DATA & HORA (carrossel de dias) ----------
                  CartaoBelle(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TituloSecao('Data e Hora'),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 92,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: dias.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final dia = dias[i];
                              final bool ativo = dia == diaAtual;
                              final bool ehHoje = dia == hoje;

                              return GestureDetector(
                                onTap: () {
                                  setState(() => _diaSelecionado = dia);
                                  _buscarHorarios();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 58,
                                  decoration: BoxDecoration(
                                    color: ativo
                                        ? AppCores.acento
                                        : AppCores.fundo,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: ativo
                                          ? AppCores.acento
                                          : (ehHoje
                                          ? AppCores.acentoMarca
                                          : AppCores.borda),
                                      width: (ehHoje && !ativo) ? 1.6 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dia.day.toString().padLeft(2, '0'),
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: ativo
                                              ? Colors.white
                                              : AppCores.texto,
                                        ),
                                      ),
                                      Text(
                                        _semana[dia.weekday - 1],
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ativo
                                              ? Colors.white70
                                              : AppCores.textoSuave,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // pontinho marca o "hoje"
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ehHoje
                                              ? (ativo
                                              ? Colors.white
                                              : AppCores.acento)
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- GRADE DE HORÁRIOS ----------
                  CartaoBelle(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TituloSecao(
                          'Horários disponíveis',
                          subtitulo:
                          diaAtual == null ? null : _diaPorExtenso(diaAtual),
                        ),
                        const SizedBox(height: 16),
                        if (_carregandoHorarios || _carregandoServicos)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (horarios.isEmpty)
                          _mensagemVazia(_servicoSelecionado == null
                              ? 'Escolha um serviço para ver os horários.'
                              : 'Nenhum horário disponível neste dia.')
                        else
                          LayoutBuilder(builder: (context, c) {
                            // 3 colunas que preenchem a largura do cartão
                            final largura = (c.maxWidth - 20) / 3;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: horarios.map((hora) {
                                final bool disponivel = hora['ativo'] == true;
                                final bool selecionado =
                                    _horarioSelecionado == hora['hora'];

                                return GestureDetector(
                                  onTap: disponivel
                                      ? () {
                                    setState(() {
                                      _horarioSelecionado = selecionado
                                          ? null
                                          : hora['hora'];
                                    });
                                  }
                                      : null,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: largura,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: !disponivel
                                          ? AppCores.indisponivel
                                          : selecionado
                                          ? AppCores.acento
                                          : AppCores.fundo,
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: selecionado
                                            ? AppCores.acento
                                            : AppCores.borda,
                                      ),
                                    ),
                                    child: Text(
                                      '${hora['hora']}',
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        decoration: disponivel
                                            ? null
                                            : TextDecoration.lineThrough,
                                        color: !disponivel
                                            ? AppCores.textoSuave
                                            .withOpacity(0.55)
                                            : selecionado
                                            ? Colors.white
                                            : AppCores.texto,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- BOTÃO FIXO NO RODAPÉ ----------
          // Cinza enquanto nenhum horário foi escolhido
          RodapeFixo(
            child: BotaoPrincipal(
              texto: _modoRemarcar
                  ? 'Solicitar remarcação'
                  : 'Solicitar agendamento',
              icone: Icons.check_rounded,
              onPressed: _horarioSelecionado == null ? null : _acaoPrincipal,
            ),
          ),
        ],
      ),
    );
  }
}