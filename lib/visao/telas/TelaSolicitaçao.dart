import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/AgendamentoModel.dart';

// TELA DE SOLICITAÇÃO

const String _numeroWhatsApp = '5537998072287';

class TelaDois extends StatefulWidget {
  const TelaDois({
    super.key,
    required this.title,
    this.diaSelecionado,
    this.horaSelecionado,
    this.agendamentoOriginal,
  });

  final String title;

  // Dia e horário escolhidos na tela de Horários
  final String? diaSelecionado;
  final String? horaSelecionado;

  // Preenchido quando o cliente veio da tela "Meus agendamentos"
  // pedindo para desmarcar ou editar um agendamento já existente
  final Map<String, String>? agendamentoOriginal;

  @override
  State<TelaDois> createState() => _TelaDoisState();
}

class _TelaDoisState extends State<TelaDois> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _servicoController = TextEditingController();

  bool _enviando = false;

  bool get _modoEdicao => widget.agendamentoOriginal != null;

  String? get _diaExibido => _modoEdicao ? widget.agendamentoOriginal!['dia'] : widget.diaSelecionado;

  String? get _horaExibido => _modoEdicao ? widget.agendamentoOriginal!['hora'] : widget.horaSelecionado;

  @override
  void initState() {
    super.initState();

    // Se for edição/cancelamento, já preenche o serviço com o
    // que estava no agendamento original (o cliente pode alterar)
    if (_modoEdicao) {
      _servicoController.text = widget.agendamentoOriginal!['servico'] ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _servicoController.dispose();
    super.dispose();
  }

  // SALVA O AGENDAMENTO E ABRE O WHATSAPP

  Future<void> _abrirWhatsApp() async {
    if (_diaExibido == null || _horaExibido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Não foi possível identificar o agendamento selecionado.'
                : 'Selecione um horário na aba "Horários" antes de conversar.',
          ),
        ),
      );

      return;
    }

    // Verifica se o nome e o serviço foram preenchidos
    if (_nomeController.text.trim().isEmpty ||
        _servicoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha seu nome e o serviço desejado antes de conversar.',
          ),
        ),
      );

      return;
    }

    // Mostra o carregamento
    setState(() {
      _enviando = true;
    });

    try {
      // SALVA O NOVO AGENDAMENTO (apenas quando o cliente está
      // solicitando um horário novo; no modo edição/cancelamento
      // o agendamento já existe, então não é criado outro)

      if (!_modoEdicao) {
        final novoAgendamento = AgendamentoModel(
          dia: widget.diaSelecionado!,
          hora: widget.horaSelecionado!,
          servico: _servicoController.text.trim(),
          status: 'Pendente',
        );

        final SharedPreferences prefs =
        await SharedPreferences.getInstance();

        // Busca os agendamentos já existentes
        final String? agendamentosJson =
        prefs.getString('agendamentos');

        List<Map<String, dynamic>> lista = [];

        // Se já existem agendamentos salvos
        if (agendamentosJson != null) {
          final List<dynamic> decodificado =
          jsonDecode(agendamentosJson);

          lista = decodificado
              .map(
                (item) => Map<String, dynamic>.from(item),
          )
              .toList();
        }

        // Adiciona o novo agendamento
        lista.add(novoAgendamento.toMap());

        // Salva novamente
        await prefs.setString(
          'agendamentos',
          jsonEncode(lista),
        );
      }

      if (!mounted) return;

      // Para o carregamento
      setState(() {
        _enviando = false;
      });

      // MOSTRA CONFIRMAÇÃO

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modoEdicao
                ? 'Solicitação de alteração enviada com sucesso!'
                : 'Solicitação enviada com sucesso!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // CRIA A MENSAGEM DO WHATSAPP

      final String mensagem = _modoEdicao
          ? 'Oi, tudo bem? Eu sou '
          '${_nomeController.text.trim()} '
          'e gostaria de desmarcar ou editar meu agendamento de '
          '${widget.agendamentoOriginal!['servico']} '
          'no dia $_diaExibido '
          'às $_horaExibido. '
          'Serviço informado agora: '
          '${_servicoController.text.trim()}. '
          'Obrigada(o)!'
          : 'Oi, tudo bem? Eu sou '
          '${_nomeController.text.trim()} '
          'e desejo agendar um horário de '
          '${_servicoController.text.trim()} '
          'no dia ${widget.diaSelecionado} '
          'às ${widget.horaSelecionado}. '
          'Obrigada(o)!';

      // CRIA O LINK DO WHATSAPP

      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$_numeroWhatsApp'
            '?text=${Uri.encodeComponent(mensagem)}',
      );

      // ABRE O WHATSAPP

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o WhatsApp.',
            ),
          ),
        );
      }
    } catch (e) {
      // CASO ACONTEÇA ALGUM ERRO

      if (!mounted) return;

      setState(() {
        _enviando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar a solicitação: $e',
          ),
        ),
      );
    }
  }

  // INTERFACE

  @override
  Widget build(BuildContext context) {
    final bool temHorarioSelecionado =
        _diaExibido != null && _horaExibido != null;

    return Scaffold(
      // APP BAR

      appBar: AppBar(
        backgroundColor: const Color(0xFFE5B0A3),
        elevation: 0,

        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),

            const SizedBox(width: 10),

            Text(
              _modoEdicao ? 'Desmarcar ou editar horário' : 'Solicitar horário',
            ),
          ],
        ),
      ),

      // CORPO

      body: Container(
        color: const Color(0xFFFAF9F8),

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 20),

            // HORÁRIO SELECIONADO

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(12),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFFE5B0A3),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      temHorarioSelecionado
                          ? '$_horaExibido - $_diaExibido'
                          : 'Nenhum horário selecionado ainda',

                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SEU NOME

            const Text(
              'Seu nome',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nomeController,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),

            // SERVIÇO DESEJADO

            const Text(
              'Serviço desejado',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _servicoController,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // BOTÃO CONVERSAR

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5B0A3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  overlayColor: Colors.transparent,
                ).copyWith(
                  elevation: WidgetStateProperty.all(0),
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                ),

                onPressed: _enviando ? null : _abrirWhatsApp,

                icon: _enviando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.chat,
                  color: Colors.white,
                ),

                label: Text(
                  _enviando ? 'Salvando...' : 'Conversar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}