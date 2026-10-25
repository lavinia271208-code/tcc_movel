import 'package:intl/intl.dart';
import 'package:login/model/Objects/Servico.dart';

//classe modelo de objeto: um agendamento da cliente
//(GET /api/meus-agendamentos -> data[], POST/PUT /api/agendamentos -> data)
class Agendamento {

  static const List<String> _diasSemana = [
    'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
    'Sexta-feira', 'Sábado', 'Domingo',
  ];

  final int id;
  final DateTime dataHora;
  final int servicoId;
  final Servico? servico;

  //construtor da classe
  Agendamento({
    required this.id,
    required this.dataHora,
    required this.servicoId,
    this.servico,
  });

  //A API exige "Y-m-d H:i:s" (ex: 2026-09-28 14:30:00) para data_hora.
  //Não usar toIso8601String(): o "T" no meio faz o Laravel responder 422.
  static String formataParaApi(DateTime dataHora) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dataHora);
  }

  //ex: "2026-09-28" (parâmetro ?data= de /horarios-disponiveis)
  static String formataDataParaApi(DateTime data) {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  //método que recebe um hash map e retorna um Agendamento
  factory Agendamento.fromJson(Map<dynamic, dynamic> json) {
    return Agendamento(
      id: (json['id'] as num).toInt(),
      dataHora: DateTime.parse(json['data_hora']),
      servicoId: (json['servico_id'] as num).toInt(),
      servico: json['servico'] != null ? Servico.fromJson(json['servico']) : null,
    );
  }

  //método que transforma os dados do respectivo objeto em um hashmap
  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['id'] = id;
    map['data_hora'] = formataParaApi(dataHora);
    map['servico_id'] = servicoId;
    map['servico'] = servico?.toMap();
    return map;
  }

  //ex: "Segunda-feira, 28/09/2026"
  static String formataDia(DateTime dataHora) =>
      '${_diasSemana[dataHora.weekday - 1]}, ${DateFormat('dd/MM/yyyy').format(dataHora)}';

  //ex: "14:30"
  static String formataHora(DateTime dataHora) => DateFormat('HH:mm').format(dataHora);

  String get diaFormatado => formataDia(dataHora);

  String get horaFormatada => formataHora(dataHora);

  String get servicoNome => servico?.nome ?? 'Serviço #$servicoId';

  bool get jaPassou => dataHora.isBefore(DateTime.now());
}