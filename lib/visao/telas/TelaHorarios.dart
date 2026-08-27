import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../service/HorarioService.dart';
import 'TelaSolicitaçao.dart';

// Tela "Horários disponíveis" (a primeira aba do app).
// Permite ao cliente escolher um dia da semana e, dentro dele, um
// horário livre, para depois seguir para a tela de Solicitação.
class TelaUm extends StatefulWidget {
  const TelaUm({super.key, required this.title});

  final String title;

  @override
  State<TelaUm> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaUm> {
  // Lista fixa dos dias da semana exibidos no carrossel horizontal,
  // cada um com número, abreviação e nome completo
  final List<Map<String, String>> dias = [
    {"numero": "01", "semana": "Seg", "nomeCompleto": "Segunda-feira"},
    {"numero": "02", "semana": "Ter", "nomeCompleto": "Terça-feira"},
    {"numero": "03", "semana": "Qua", "nomeCompleto": "Quarta-feira"},
    {"numero": "04", "semana": "Qui", "nomeCompleto": "Quinta-feira"},
    {"numero": "05", "semana": "Sex", "nomeCompleto": "Sexta-feira"},
    {"numero": "06", "semana": "Sáb", "nomeCompleto": "Sábado"},
  ];

  // Dia atualmente selecionado no carrossel (começa em Segunda-feira)
  String _diaSelecionado = "Segunda-feira";

  // Horário escolhido pelo usuário dentre os disponíveis do dia
  // (null enquanto nada foi selecionado)
  String? _horarioSelecionado;

  // Lista de horários do dia selecionado, cada item com o campo
  // 'hora' e 'ativo' (indica se está disponível ou já ocupado)
  List<Map<String, dynamic>> horarios = [];

  // Controla a exibição do spinner enquanto os horários do dia
  // estão sendo buscados
  bool _carregandoHorarios = true;

  // Ao iniciar a tela, já busca os horários do dia padrão (Segunda-feira)
  @override
  void initState() {
    super.initState();
    _buscarHorarios(_diaSelecionado);
  }

  // simula a busca dos horários disponíveis  usando o HorarioService
  Future<void> _buscarHorarios(String dia) async {
    // Enquanto busca, mostra o spinner e limpa o horário selecionado
    // anteriormente (já que ele era de outro dia)
    setState(() {
      _carregandoHorarios = true;
      _horarioSelecionado = null;
    });

    final resultado = await HorarioService().buscarHorarios(dia);

    // Garante que a tela ainda está montada antes de atualizar o estado
    if (!mounted) return;
    setState(() {
      horarios = resultado;
      _carregandoHorarios = false;
    });
  }

  //leva o dia e o horário escolhidos para a tela de solicitação,
  //abrindo uma tela NOVA por cima (com seta de voltar, sem barra inferior)
  void _irParaSolicitarHorario() {
    // Proteção extra: não deveria ser chamado sem horário selecionado
    // (o botão já fica desabilitado nesse caso), mas garante de novo aqui
    if (_horarioSelecionado == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDois(
          title: 'Solicitar horário',
          diaSelecionado: _diaSelecionado,
          horaSelecionado: _horarioSelecionado,
        ),
      ),
    );
  }

  // Monta a interface da tela: carrossel de dias, grade de horários
  // e botão para avançar para a tela de solicitação
  @override
  Widget build(BuildContext context) {
    // Inicializa o ScreenUtil com um tamanho de design de referência,
    // usado para escalonar tamanhos de forma proporcional
    ScreenUtil.init(context, designSize: const Size(750, 1304));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5B0A3),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            SizedBox(width: 10),
            Text("Horários disponíveis"),
          ],
        ),
      ),
      body: Container(
        color: Color(0xFFFAF9F8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data & Hora",
                style: TextStyle(fontSize: 16, color: Colors.black54, letterSpacing: 1),
              ),
              SizedBox(height: 10),

              // CARROSSEL HORIZONTAL DE DIAS DA SEMANA

              // Cada "cartão" de dia é clicável: ao tocar, atualiza o dia
              // selecionado e dispara uma nova busca de horários para ele
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: dias.map((dia) {

                    // Verifica se este cartão é o dia atualmente ativo
                    final bool ativo = dia['nomeCompleto'] == _diaSelecionado;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _diaSelecionado = dia['nomeCompleto']!);
                        _buscarHorarios(dia['nomeCompleto']!);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(

                          // Fundo colorido quando é o dia ativo
                          color: ativo ? Color(0xFFE5B0A3) : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Número do dia (ex: "01")
                            Text(
                              dia['numero']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ativo ? Colors.white : Colors.black,
                              ),
                            ),
                            // Abreviação da semana (ex: "Seg")
                            Text(
                              dia['semana']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: ativo ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 20),

              Text("Horários disponíveis", style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 15),


              // GRADE DE HORÁRIOS DO DIA SELECIONADO

              // Enquanto carrega, mostra um spinner; depois, mostra os
              // horários em um Wrap (que quebra linha automaticamente)
              _carregandoHorarios
                  ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFE5B0A3))),
              )
                  : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: horarios.map((hora) {
                  final bool disponivel = hora['ativo'] == true;

                  final bool selecionado = _horarioSelecionado == hora['hora'];

                  return GestureDetector(
                    onTap: disponivel
                        ? () {
                      setState(() {
                        // Toca de novo no mesmo horário = desmarca;
                        // toca em outro = seleciona o novo
                        _horarioSelecionado = selecionado ? null : hora['hora'];
                      });
                    }
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: !disponivel
                            ? Colors.grey.shade300
                            : selecionado
                            ? Color(0xFFE5B0A3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        // Borda destacada só quando selecionado
                        border: Border.all(
                          color: selecionado ? Color(0xFFE5B0A3) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        hora['hora'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          // Cor do texto conforme o estado (indisponível/
                          // selecionado/disponível)
                          color: !disponivel
                              ? Colors.black38
                              : selecionado
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),


              // BOTÃO "SOLICITAR AGENDAMENTO"

              SizedBox(
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
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: _horarioSelecionado == null
                      ? null
                      : _irParaSolicitarHorario,
                  child: const Text(
                    'Solicitar agendamento',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}