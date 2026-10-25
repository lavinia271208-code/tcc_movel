//classe modelo de objeto: um serviço oferecido pelo estúdio
//(GET /api/servicos -> data[])
class Servico {

  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final int duracaoMinutos;

  //construtor da classe
  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.duracaoMinutos,
  });

  //método que recebe um hash map e retorna um Servico
  factory Servico.fromJson(Map<dynamic, dynamic> json) {
    return Servico(
      id: (json['id'] as num).toInt(),
      nome: json['nome']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
      preco: double.tryParse(json['preco']?.toString() ?? '') ?? 0,
      duracaoMinutos: int.tryParse(json['duracao_minutos']?.toString() ?? '') ?? 0,
    );
  }

  //método que transforma os dados do respectivo objeto em um hashmap
  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['id'] = id;
    map['nome'] = nome;
    map['descricao'] = descricao;
    map['preco'] = preco;
    map['duracao_minutos'] = duracaoMinutos;
    return map;
  }

  //ex: "R$ 180,00"
  String get precoFormatado => 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
}