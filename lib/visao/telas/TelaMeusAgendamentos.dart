import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import 'TelaSolicitaçao.dart';

class TelaTres extends StatefulWidget {
  const TelaTres({super.key, required this.title});

  final String title;

  @override
  State<TelaTres> createState() => _TelaTresState();
}

class _TelaTresState extends State<TelaTres> {
  // Lista de agendamentos carregada do armazenamento local
  List<Map<String, String>> agendamentos = [];

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

  void _irParaDesmarcarOuEditar() {
    if (_indiceSelecionado == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDois(
          title: 'Solicitar horário',
          agendamentoOriginal: agendamentos[_indiceSelecionado!],
        ),
      ),
    );
  }

  //lê os agendamentos gravados no shared preferences (baixados na Splash2)
  Future<void> _carregarAgendamentos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? agendamentosJson = prefs.getString('agendamentos');

    List<Map<String, String>> lista = [];
    // Se já existe algo salvo, decodifica o JSON e transforma cada
    // item em um Map<String, String> (dia, hora, serviço, status)
    if (agendamentosJson != null) {
      final List<dynamic> decodificado = jsonDecode(agendamentosJson);
      lista = decodificado
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    }

    // Garante que a tela ainda está montada antes de atualizar o estado
    if (!mounted) return;
    setState(() {
      agendamentos = lista;
      _carregando = false;
    });
  }

  // INTERFACE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5B0A3),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            SizedBox(width: 10),
            Text("Meus agendamentos"),
          ],
        ),
      ),

      body: Container(
        color: Color(0xFFFAF9F8),

        // Três estados possíveis do corpo da tela:
        // carregando -> spinner; lista vazia -> mensagem;
        // lista com itens -> Column com lista + botão
        child: _carregando
            ? Center(child: CircularProgressIndicator(color: Color(0xFFE5B0A3)))
            : agendamentos.isEmpty
            ? Center(
          child: Text(
            'Nenhum agendamento encontrado.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : Column(
          children: [

            // LISTA DE AGENDAMENTOS

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: agendamentos.length,
                itemBuilder: (context, index) {

                  final item = agendamentos[index];
                  // Verifica se este é o card selecionado
                  final bool selecionado = _indiceSelecionado == index;

                  // GestureDetector torna o card inteiro clicável
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _indiceSelecionado =
                        selecionado ? null : index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),

                        // Borda destacada na cor do app somente quando
                        // este card está selecionado
                        border: Border.all(
                          color: selecionado
                              ? Color(0xFFE5B0A3)
                              : Colors.transparent,
                          width: 2,
                        ),

                        // Sombra leve para dar profundidade ao card
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //dia e hora
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  color: Color(0xFFE5B0A3)),
                              SizedBox(width: 8),
                              Text(
                                "${item['dia']} - ${item['hora']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          //serviço
                          Text(
                            "Serviço: ${item['servico']}",
                            style: TextStyle(fontSize: 14),
                          ),

                          SizedBox(height: 8),

                          //status
                          // "Selo" colorido mostrando o status do
                          // agendamento (ex: Confirmado, Pendente)
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10
                            ),
                            decoration: BoxDecoration(
                              // Cor destacada quando "Confirmado",
                              // cinza para qualquer outro status
                              color: item['status'] == "Confirmado"
                                  ? Color(0xFFE5B0A3)
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['status']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // BOTÃO "DESMARCAR OU EDITAR HORÁRIO"

            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5B0A3),
                    disabledBackgroundColor: const Color(0xFFE5B0A3),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0, // sem sombra
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: _indiceSelecionado == null
                      ? null
                      : _irParaDesmarcarOuEditar,
                  child: const Text(
                    'Desmarcar ou editar horário',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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