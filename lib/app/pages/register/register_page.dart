import 'package:DasCobras/app/utils/utils_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:DasCobras/app/viewmodels/register_viewmodel/register_viewmodel.dart';
import 'package:DasCobras/app/pages/login/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterService viewModel = RegisterService();

  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();

  final TextEditingController _cpfController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  DateTime? selectDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              //campo do nome
              TextFormField(
                controller: nameController,

                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ ]')),
                ],

                keyboardType: TextInputType.name,

                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(labelText: 'Nome Completo'),

                validator: (value) => UtilsValidators.name(value),
              ),
              const SizedBox(height: 20),

              //campo do cpf
              TextFormField(
                controller: _cpfController,

                keyboardType: TextInputType.number,

                textInputAction: TextInputAction.next,

                decoration: const InputDecoration(labelText: 'CPF'),

                inputFormatters: [UtilsValidators().cpfMaskFormatter],

                validator: (value) => UtilsValidators.cpf(value),
              ),

              const SizedBox(height: 20),

              //campo de email
              TextFormField(
                controller: _emailController,

                decoration: const InputDecoration(labelText: 'Email'),

                validator: (value) => UtilsValidators.email(value),
              ),
              const SizedBox(height: 30),

              //campo de Senha
              TextFormField(
                controller: _passwordController,

                obscureText: true,

                textInputAction: TextInputAction.next,

                autocorrect: false,

                enableSuggestions: false,

                decoration: const InputDecoration(labelText: 'Senha'),

                validator: (value) => UtilsValidators.password(value),
              ),

              const SizedBox(height: 30),

              //campo de data
              TextFormField(
                controller: dateController,
                readOnly: true, //vai impedir do usuario diigtar

                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  suffix: Icon(Icons.calendar_today),
                ),

                onTap: () async {
                  //enquanto o usuario clicar
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      selectDate = date; // Salva o DateTime aqui
                      dateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },

                validator: (value) => UtilsValidators.birth(value),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final authService = RegisterService();

                      await authService.register(
                        name: nameController.text,
                        cpf: _cpfController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                        date: selectDate!,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Usuário cadastrado. Verifique seu email.',
                          ),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },

                child: const Text('Cadastrar'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },

                child: const Text('Já possui conta? Faça login'),
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
    nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    dateController.dispose();
  }
}
