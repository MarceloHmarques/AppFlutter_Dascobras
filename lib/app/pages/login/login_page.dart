import 'package:DasCobras/app/pages/home/home_page.dart';
import 'package:DasCobras/app/pages/register/register_page.dart';
import 'package:DasCobras/app/service/auth_service/auth_session_service.dart';
import 'package:DasCobras/app/service/validation/personal_validation.dart';
import 'package:DasCobras/app/service/validation/personal%20_data_validation.dart';
import 'package:DasCobras/app/viewmodels/login_viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:DasCobras/app/viewmodels/splash_viewmodel/splash_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginService viewModel = LoginService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _isLoading = false;

  final splashViewModel = SplashViewmodel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'lib/app/assets/img/Logo.png',
                width: 200,
                height: 200,
              ),

              TextFormField(
                controller: _emailController,

                keyboardType: TextInputType.emailAddress,

                textCapitalization: TextCapitalization.none,

                autocorrect: false,
                //para ter o botão de proximo no teclado
                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(labelText: 'Email'),

                validator: (value) => PersonalDataValidation.email(value),
              ),
              const SizedBox(height: 20),

              //campo de Senha
              TextFormField(
                controller: _passwordController,
                //criar a senha obscura, tanto aq quanto no register
                obscureText: _obscurePassword,

                keyboardType: TextInputType.visiblePassword,

                enableSuggestions: false,

                autocorrect: false,

                //alterar caixas de texto
                textInputAction: TextInputAction.done,

                decoration: InputDecoration(
                  labelText: 'Senha',

                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                validator: (value) => UtilsValidators.passwordBasic(value),
              ),
              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Esqueceu a senha?'),
                ),
              ),

              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    FocusScope.of(context).unfocus();

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final loginService = LoginService();

                      await loginService.login(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      );

                      await AuthSessionService().saveLoginDate();
                      await AuthSessionService().saveSessionCheckDate();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login realizado com sucesso'),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email ou senha inválido.'),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  child: const Text('Entrar'),
                ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },

                child: const Text('Não possui conta? Faça seu registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
}
