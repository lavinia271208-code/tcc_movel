import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:login/visao/telas/Splash2.dart';
import 'package:login/visao/estilos/EstilosBotoes.dart';
import 'package:login/visao/estilos/EstilosTexto.dart';
import 'package:login/visao/telas/Principal.dart';
import 'package:login/visao/util/WidgetsUteis.dart';
import '../../service/AuthService.dart';

// Tela de Login/Cadastro do aplicativo.
// É um StatefulWidget porque o conteúdo muda dinamicamente
// (alterna entre o formulário de "Entrar" e o de "Cadastrar").
class Login extends StatefulWidget {
  const Login({super.key, required this.title});
  final String title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Chave usada para identificar e validar o formulário de login
  // (permite chamar formState.validate() para rodar os validators)
  final _formKey = GlobalKey<FormState>();

  // Controlam qual aba está "ativa" visualmente (Entrar ou Cadastrar),
  // usados para deixar o texto do botão em negrito/maior quando selecionado
  bool _entrarActive = false;
  bool _cadastrarActive = true;

  // Indica se uma requisição de login está em andamento
  // (mostra o spinner de carregamento e desabilita a tela)
  bool _carregando = false;

  // Controllers dos campos de texto da aba "Entrar"
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Controllers dos campos de texto da aba "Cadastrar"
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Libera a memória usada pelos controllers quando o widget é destruído
  // (evita vazamento de memória)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Navega para a tela Principal, substituindo a tela de Login
  // (o usuário não consegue voltar para o Login com o botão "voltar")
  void telaPrincipal(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Principal()),
    );
  }

  // Navega para a Splash2 (tela que baixa os dados do usuário),
  // também substituindo a tela atual na pilha de navegação
  void telaSplash2(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Splash2()),
    );
  }

  // Executa o processo de login: valida o formulário, chama o serviço
  // de autenticação, salva os dados retornados e navega para a próxima tela
  Future<void> _processarLogin(BuildContext context) async {
    // Roda os validators dos campos do Form; se algum falhar, para aqui
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    // Validação extra: garante que a senha não esteja vazia
    // (o campo de senha não usa TextFormField/validator, é um TextField comum)
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    // Ativa o indicador de carregamento
    setState(() => _carregando = true);

    try {
      // Chama o serviço de autenticação (faz uma
      // simulação de requisição HTTP) passando email e senha
      final authService = AuthService();

      final loginModel = await authService.realizarLogin(
        _emailController.text,
        _passwordController.text,
      );

      // Salva os dados retornados pelo login (email, data/hora e o
      // token de autenticação) localmente, no SharedPreferences,
      // para serem usados depois em outras telas/requisições
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.setString('idUsuario', loginModel.id);
      await prefs.setString('emailUsuario', loginModel.email);
      await prefs.setString('dataHoraLogin', loginModel.dataHora);
      await prefs.setString('tokenAutenticacao', loginModel.token);

      // Verifica se o widget ainda está montado antes de mexer no estado
      // (evita erro caso o usuário tenha saído da tela durante o await)
      if (!mounted) return;
      setState(() => _carregando = false);

      // Login deu certo: segue para a Splash2 (que vai baixar os dados)
      telaSplash2(context);

    } catch (erro) {
      // Se o login falhar (credenciais inválidas, erro de rede, etc.),
      // desativa o carregamento e mostra o erro para o usuário
      setState(() => _carregando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na autenticação: $erro')),
      );
    }
  }

  // Constrói o formulário da aba "Entrar" (login de quem já tem conta)
  Widget _showEntrar(BuildContext context) {
    return Form(
      key: _formKey, // liga este Form à _formKey para permitir validação
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: ScreenUtil().setHeight(30)),

          // Campo de e-mail com validação (usa TextFormField por isso)
          TextFormField(
              style: TextStyle(color: Theme.of(context).highlightColor),
              controller: _emailController,
              decoration: InputDecoration(
                hintText: Internacionalizacao.hintTextEmail,
                hintStyle: EstilosTextosCustomizado.formField(context),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
                prefixIcon: const Icon(Icons.email, color: Colors.white),
              ),
              // validação do email
              // retorna uma mensagem de erro (String) se o campo for inválido,
              // ou null se estiver tudo certo
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return 'Por favor, insira seu e-mail!';
                }
                if(!value.contains('@')){
                  return 'O e-mail deve conter um @!';
                }
                return null;
              }
          ),
          SizedBox(height: ScreenUtil().setHeight(50)),

          // Campo de senha (obscureText: true esconde os caracteres digitados)
          // Não possui validator próprio; a checagem de vazio é feita manualmente
          // em _processarLogin
          TextField(
            obscureText: true,
            style: const TextStyle(color: Color(0xFFFFC0CB)),
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: Internacionalizacao.hintTextPassword,
              hintStyle: EstilosTextosCustomizado.formField(context),
              enabledBorder: UnderlineInputBorder(borderSide: EstilosBotoes().borderSideFino(context)),
              focusedBorder: UnderlineInputBorder(borderSide: EstilosBotoes().borderSideFino(context)),
              prefixIcon: const Icon(Icons.lock, color: Colors.white),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(80)),

          // Botão de acessar: enquanto _carregando for true, mostra um
          // spinner no lugar do botão; senão, mostra o ElevatedButton normal
          Container(
            padding: const EdgeInsets.all(8.0),
            child: _carregando
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7D4CC),
                foregroundColor: Colors.black,
              ),
              onPressed: () => _processarLogin(context),
              child: const Text('Acessar'),
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(15)),

          // Linha decorativa com um traço "-" no meio, separando o
          // formulário de outro conteúdo (visual apenas)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WidgetsUteis().horizontalLine(),
              Text('-', style: EstilosTextosCustomizado.body(context)),
              WidgetsUteis().horizontalLine()
            ],
          ),
          WidgetsUteis().espacoHorizontal15,
        ],
      ),
    );
  }

  // Constrói o formulário da aba "Cadastrar" (criação de conta nova)
  // Observação: diferente de _showEntrar, aqui não há validação nem
  // chamada real de cadastro - o botão apenas navega para a Splash2
  Widget _showCadastrar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: ScreenUtil().setHeight(30)),

        // Campo de e-mail para o novo cadastro
        TextField(
          style: EstilosTextosCustomizado.formField(context),
          controller: _newEmailController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextNewEmail,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(50)),

        // Campo de senha para o novo cadastro
        TextField(
          obscureText: true,
          style: EstilosTextosCustomizado.formField(context),
          controller: _newPasswordController,
          decoration: InputDecoration(
            hintText: Internacionalizacao.hintTextNewPassword,
            hintStyle: EstilosTextosCustomizado.formField(context),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).highlightColor, width: 1.0)),
            prefixIcon: const Icon(Icons.lock, color: Colors.white),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(80)),

        // Botão de cadastro: hoje apenas leva direto para a Splash2,
        // sem de fato criar uma conta nova via serviço/API
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7D4CC),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          onPressed: () {
            telaSplash2(context);
          },
          child: Text(
            Internacionalizacao.signUpMenuButton,
            style: EstilosTextosCustomizado.button(context),
          ),
        ),
      ],
    );
  }

  // Monta a interface completa da tela de Login
  @override
  Widget build(BuildContext context) {
    // Trava a orientação da tela apenas em modo retrato (vertical)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Inicializa o ScreenUtil com um tamanho de design de referência
    // (750x1304), usado para escalar tamanhos (setWidth/setHeight)
    // de forma proporcional em diferentes tamanhos de tela
    ScreenUtil.init(context, designSize: const Size(750, 1304));

    return Scaffold(
      // Faz a tela se ajustar quando o teclado aparece, evitando
      // que o teclado cubra os campos de texto
        resizeToAvoidBottomInset: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE5B0A3), // cor de fundo da tela

          // Permite rolar o conteúdo caso ele não caiba na tela
          // (importante quando o teclado abre e reduz o espaço disponível)
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  // Cabeçalho com o título e subtítulo da tela
                  // (ex: "Entre na sua conta" / "Digite seus dados para acessar")
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(190),
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(Internacionalizacao.logoTitle,
                                style: EstilosTextosCustomizado.title(context)),
                            Text(Internacionalizacao.logoSubTitle,
                                style: EstilosTextosCustomizado.subTitle(context)),
                          ],
                        )),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(60)),

                  // Duas "abas" (botões) para alternar entre Entrar e Cadastrar.
                  // O texto de cada botão fica maior/negrito quando está ativo
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(170),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                            // Botão "ACESSAR": muda o estado para exibir
                            // o formulário de login
                            OutlinedButton(
                              onPressed: () => setState(() => _alterarParaEntrar()),
                              child: Text(Internacionalizacao.signInMenuButton,
                                  style: _cadastrarActive
                                      ? TextStyle(
                                      fontSize: 22,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.bold)
                                      : TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.normal)),
                            ),

                            // Botão "CADASTRAR": muda o estado para exibir
                            // o formulário de cadastro
                            OutlinedButton(
                              onPressed: () => setState(() => _alterarParaCadastrar()),
                              child: Text(Internacionalizacao.signUpMenuButton,
                                  style: _entrarActive
                                      ? TextStyle(
                                      fontSize: 22,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.bold)
                                      : TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).highlightColor,
                                      fontWeight: FontWeight.normal)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(5)),

                  // Área que troca de conteúdo dependendo da aba ativa:
                  // mostra _showEntrar() ou _showCadastrar()
                  SizedBox(
                    width: ScreenUtil().setWidth(750),
                    height: ScreenUtil().setHeight(778),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: _cadastrarActive ? _showEntrar(context) : _showCadastrar()),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Ativa a aba "Cadastrar" (troca as flags de controle das abas)
  void _alterarParaCadastrar() {
    _entrarActive = true;
    _cadastrarActive = false;
  }

  // Ativa a aba "Entrar" (troca as flags de controle das abas)
  void _alterarParaEntrar() {
    _entrarActive = false;
    _cadastrarActive = true;
  }
}

// Classe com os textos fixos usados na tela (uma forma simples de
// centralizar strings, como se fosse uma preparação para internacionalização)
class Internacionalizacao {
  static String logoTitle = "Entre na sua conta";
  static String logoSubTitle = "Digite seus dados para acessar";
  static String signInMenuButton = "ACESSAR";
  static String signUpMenuButton = "CADASTRAR";
  static String hintTextEmail = "Email";
  static String hintTextPassword = "Senha";
  static String hintTextNewEmail = "Entre com seu Email";
  static String hintTextNewPassword = "Crie uma senha";
}