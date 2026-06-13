import 'package:DasCobras/app/service/validation/personal_validation.dart';
import 'package:DasCobras/app/service/validation/mask.dart';
import 'package:DasCobras/app/service/validation/personal%20_data_validation.dart';
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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  DateTime? selectDate;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 55),

                Image.asset('lib/app/assets/img/LogoLonga.png', width: 190),

                const SizedBox(height: 45),

                _label('Nome completo:'),
                TextFormField(
                  controller: nameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ ]')),
                  ],
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(),
                  validator: (value) => PersonalDataValidation.name(value),
                ),

                const SizedBox(height: 18),

                _label('CPF:'),
                TextFormField(
                  controller: _cpfController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(),
                  inputFormatters: [Mask.cpfMaskFormatter],
                  validator: (value) => PersonalValidation.cpf(value),
                ),

                const SizedBox(height: 18),

                _label('Email:'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(),
                  validator: (value) => PersonalDataValidation.email(value),
                ),

                const SizedBox(height: 18),

                _label('Senha:'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: _inputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) => PersonalValidation.password(value),
                ),

                const SizedBox(height: 18),

                _label('Data de nascimento:'),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: _inputDecoration(
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  ),
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() {
                        selectDate = date;
                        dateController.text =
                            '${date.day}/${date.month}/${date.year}';
                      });
                    }
                  },
                  validator: (value) => PersonalDataValidation.birth(value),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D3F87),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            FocusScope.of(context).unfocus();

                            setState(() {
                              _isLoading = true;
                            });

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
                                  content: Text('Usuário cadastrado.'),
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

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: const Text(
                            'Cadastrar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Já possui conta? Faça login',
                    style: TextStyle(
                      color: Color(0xFF0D3F87),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'from',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const Text(
                  'EVOLUTEC',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3F87),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  InputDecoration _inputDecoration({Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0D3F87), width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
