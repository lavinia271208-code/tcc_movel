import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Sincroniza {

  /**
   * Endereço base da API Laravel (php artisan serve).
   *
   * - Emulador Android  -> 10.0.2.2 aponta para o localhost do computador
   * - iOS Simulator / Web / Desktop -> 127.0.0.1
   * - Celular físico -> use o IP do computador na rede e inicie o servidor com
   *   "php artisan serve --host=0.0.0.0", passando o endereço ao rodar o app:
   *   flutter run --dart-define=API_URL=http://192.168.0.10:8000/api
   */
  static const String _urlDefinida = String.fromEnvironment('API_URL');

  static String get BASE_URL {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000/api";
    }
    return "http://127.0.0.1:8000/api";
  }

  static String get LOGIN_API => "$BASE_URL/login";
  static String get CADASTRO_API => "$BASE_URL/cadastro";
  static String get LOGOUT_API => "$BASE_URL/logout";
  static String get LISTAGEM_SERVICOS => "$BASE_URL/servicos";
  static String get LISTAGEM_HORARIOS => "$BASE_URL/horarios-disponiveis";
  static String get LISTAGEM_AGENDAMENTOS => "$BASE_URL/meus-agendamentos";
  static String get AGENDAMENTOS => "$BASE_URL/agendamentos";

  /**
   * Cria o Dio já com o header Accept: application/json (sem ele o Laravel
   * responde com redirecionamento em vez de JSON nos erros 401/422) e, quando
   * recebe o token, com o header de autenticação do Sanctum.
   */
  Dio _dio([String? token]) {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    return dio;
  }

  /**
   * Requisição http para solicitar login
   * POST /api/login -> { data: { id, name, email, is_admin, token } }
   */
  Future<Response> requestLogin(String email, String password) async {
    return await _dio().post(LOGIN_API, data: {'email': email, 'password': password});
  }

  /**
   * Requisição http para criar uma conta de cliente
   * POST /api/cadastro -> 201 { data: { id, name, email, is_admin, token } }
   */
  Future<Response> requestCadastro(String nome, String email, String password, String confirmacao) async {
    return await _dio().post(CADASTRO_API, data: {
      'name': nome,
      'email': email,
      'password': password,
      'password_confirmation': confirmacao,
    });
  }

  /**
   * Requisição http para invalidar o token no servidor
   * POST /api/logout
   */
  Future<Response> requestLogout(String token) async {
    return await _dio(token).post(LOGOUT_API);
  }

  /**
   * Requisição http para solicitar a lista de serviços
   * GET /api/servicos -> { data: [ { id, nome, descricao, preco, duracao_minutos } ] }
   */
  Future<Response> requestServicos(String token) async {
    return await _dio(token).get(LISTAGEM_SERVICOS);
  }

  /**
   * Requisição http para solicitar os horários de um dia
   * GET /api/horarios-disponiveis?data=YYYY-MM-DD&servico_id=1
   * -> { data: [ { hora: "08:00", ativo: true } ] }
   * [ignorarAgendamentoId] é usado ao remarcar, para o próprio agendamento
   * não bloquear o horário que ele já ocupa.
   */
  Future<Response> requestHorarios(String token, String data, int servicoId, {int? ignorarAgendamentoId}) async {
    final params = <String, dynamic>{'data': data, 'servico_id': servicoId};
    if (ignorarAgendamentoId != null) {
      params['ignorar_agendamento_id'] = ignorarAgendamentoId;
    }
    return await _dio(token).get(LISTAGEM_HORARIOS, queryParameters: params);
  }

  /**
   * Requisição http para solicitar os agendamentos da cliente logada
   * GET /api/meus-agendamentos -> { data: [ { id, data_hora, servico_id, servico } ] }
   */
  Future<Response> requestAgendamentos(String token) async {
    return await _dio(token).get(LISTAGEM_AGENDAMENTOS);
  }

  /**
   * Requisição http para criar um agendamento
   * POST /api/agendamentos (data_hora no formato "Y-m-d H:i:s") -> 201 { data: {...} }
   */
  Future<Response> requestCriaAgendamento(String token, int servicoId, String dataHora) async {
    return await _dio(token).post(AGENDAMENTOS, data: {
      'servico_id': servicoId,
      'data_hora': dataHora,
    });
  }

  /**
   * Requisição http para remarcar um agendamento
   * PUT /api/agendamentos/{id} -> { data: {...} }
   */
  Future<Response> requestRemarcaAgendamento(String token, int id, String dataHora, {int? servicoId}) async {
    final dados = <String, dynamic>{'data_hora': dataHora};
    if (servicoId != null) {
      dados['servico_id'] = servicoId;
    }
    return await _dio(token).put("$AGENDAMENTOS/$id", data: dados);
  }

  /**
   * Requisição http para cancelar um agendamento
   * DELETE /api/agendamentos/{id} -> { message: "..." }
   */
  Future<Response> requestCancelaAgendamento(String token, int id) async {
    return await _dio(token).delete("$AGENDAMENTOS/$id");
  }

  /**
   * Transforma qualquer erro de requisição em uma mensagem para a usuária.
   * O Laravel devolve 422 com { message, errors: { campo: [msg] } }; quando há
   * erros por campo, mostra o primeiro deles.
   */
  static String mensagemErro(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final dados = e.response?.data;

      if (status == 401) {
        return 'Sessão expirada, faça login novamente.';
      }

      if (dados is Map) {
        final erros = dados['errors'];
        if (erros is Map && erros.isNotEmpty) {
          final primeiro = erros.values.first;
          if (primeiro is List && primeiro.isNotEmpty) {
            return primeiro.first.toString();
          }
        }
        if (dados['message'] != null) {
          return dados['message'].toString();
        }
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Não foi possível conectar ao servidor. Verifique sua conexão.';
      }

      return 'Erro inesperado no servidor${status != null ? ' ($status)' : ''}.';
    }
    return e.toString();
  }
}