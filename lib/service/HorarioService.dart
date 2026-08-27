class HorarioService {
  //horários indisponíveis (já ocupados) simulados por dia da semana
  static const Map<String, List<String>> _horariosIndisponiveisPorDia = {
    'Segunda-feira': ['13:00', '15:00'],
    'Terça-feira': ['08:00', '09:00'],
    'Quarta-feira': ['11:00', '16:00'],
    'Quinta-feira': ['10:00'],
    'Sexta-feira': ['13:00'],
    'Sábado': ['08:00', '09:00', '10:00'],
  };

  static const List<String> _horariosBase = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  //simula uma pequena espera, como se estivesse consultando um servidor
  Future<List<Map<String, dynamic>>> buscarHorarios(String diaSemana) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final indisponiveis = _horariosIndisponiveisPorDia[diaSemana] ?? [];

    return _horariosBase
        .map((hora) => {
      'hora': hora,
      'ativo': !indisponiveis.contains(hora),
    })
        .toList();
  }
}