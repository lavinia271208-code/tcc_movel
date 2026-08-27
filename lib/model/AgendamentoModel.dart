//modelo que representa um agendamento vindo da API (simulada)
class AgendamentoModel {
  String dia;
  String hora;
  String servico;
  String status;

  AgendamentoModel({
    required this.dia,
    required this.hora,
    required this.servico,
    required this.status,
  });

  //converte o objeto em Map para poder ser transformado em JSON
  Map<String, dynamic> toMap() {
    return {
      'dia': dia,
      'hora': hora,
      'servico': servico,
      'status': status,
    };
  }

  //cria o objeto a partir de um Map (vindo do JSON salvo no shared preferences)
  factory AgendamentoModel.fromMap(Map<String, dynamic> map) {
    return AgendamentoModel(
      dia: map['dia'] ?? '',
      hora: map['hora'] ?? '',
      servico: map['servico'] ?? '',
      status: map['status'] ?? '',
    );
  }
}