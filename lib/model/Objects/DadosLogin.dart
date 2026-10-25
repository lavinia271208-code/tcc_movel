//classe modelo de objeto
class Dadoslogin {

  final int id;
  final String usuario;
  final String nome;
  final String token;

  //construtor da classe
  Dadoslogin({required this.usuario, required this.nome, required this.token, required this.id});

  //método que recebe um hash map e retorna um Dadoslogin
  factory Dadoslogin.fromJson(Map<dynamic, dynamic> json) {
    return Dadoslogin(
      usuario: json['usuario'],
      nome: json['nome'],
      token: json['token'],
      id: json['id'],
    );
  }

  //método que transforma os dados do respectivo objeto em um hashmap
  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['usuario'] = usuario;
    map['nome'] = nome;
    map['token'] = token;
    map['id'] = id;
    return map;
  }
}