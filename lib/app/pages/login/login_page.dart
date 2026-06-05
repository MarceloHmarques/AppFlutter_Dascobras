import 'package:DasCobras/app/pages/home/home_page.dart';
import 'package:DasCobras/app/pages/register/register_page.dart';
import 'package:DasCobras/app/utils/utils_validators.dart';
import 'package:DasCobras/app/viewmodels/login_viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';

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

                autocorrect: false,
                //para ter o botão de proximo no teclado
                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(labelText: 'Email'),

                validator: (value) => UtilsValidators.email(value),
              ),
              const SizedBox(height: 20),

              //campo de Senha
              TextFormField(
                controller: _passwordController,

                //criar a senha obscura, tanto aq quanto no register
                //alterar caixas de texto
                textInputAction: TextInputAction.done,

                decoration: const InputDecoration(labelText: 'Senha'),

                validator: (value) => UtilsValidators.passwordBasic(value),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  try {
                    if (_formKey.currentState!.validate()) {
                      final api_service = LoginService();

                      await api_service.login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login realizado com sucesso'),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
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
