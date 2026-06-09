import 'package:DasCobras/app/service/validation/personal_validation.dart';
import 'package:DasCobras/app/service/validation/address_validation.dart';
import 'package:DasCobras/app/service/validation/mask.dart';
import 'package:DasCobras/app/service/validation/personal%20_data_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/client_viewmodel/client_viewmodel.dart';

class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog({super.key});

  @override
  State<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<CreateClientDialog> {
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final birthDateController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final houseNumberController = TextEditingController();
  final cepController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? selectedState;

  bool loading = false;

  Future<void> saveCustomer() async {
    try {
      setState(() => loading = true);

      await context.read<ClientViewModel>().addCustomer(
        name: nameController.text,
        birthDate: birthDateController.text,
        phone: phoneController.text,
        email: emailController.text,
        cpfOrCnpj: cpfController.text,
        state: stateController.text,
        city: cityController.text,
        neighborhood: neighborhoodController.text,
        cep: cepController.text,
        houseNumber: houseNumberController.text,
        address: addressController.text,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cliente cadastrado com sucesso!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Criar Cliente",
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF0D3F87),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                buildField(
                  "Nome",
                  nameController,
                  validator: (value) => PersonalDataValidation.name(value),
                  keyboardType: TextInputType.name,
                ),

                buildField(
                  "CPF/CNPJ",
                  cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final digits = newValue.text.replaceAll(
                        RegExp(r'\D'),
                        '',
                      );

                      if (digits.length <= 11) {
                        return Mask.cpfMaskFormatter.formatEditUpdate(
                          oldValue,
                          newValue,
                        );
                      } else {
                        return Mask.cnpjMaskFormatter.formatEditUpdate(
                          oldValue,
                          newValue,
                        );
                      }
                    }),
                  ],
                  validator: (value) {
                    validator:
                    (value) {
                      final text = value ?? '';
                      final digits = text.replaceAll(RegExp(r'\D'), '');

                      if (digits.isEmpty) {
                        return 'CPF ou CNPJ obrigatório';
                      }

                      if (digits.length != 11 && digits.length != 14) {
                        return 'CPF ou CNPJ incompleto';
                      }

                      if (!UtilsValidators.utilsCpfCnpj(digits)) {
                        return 'CPF ou CNPJ inválido';
                      }

                      return null;
                    };
                  },
                ),

                buildField(
                  "Data de nascimento",
                  birthDateController,
                  readOnly: true,

                  suffixIcon: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() {
                        birthDateController.text =
                            '${date.day}/${date.month}/${date.year}';
                      });
                    }
                  },
                  validator: (value) => PersonalDataValidation.birth(value),
                ),

                buildField(
                  "Telefone",
                  phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [Mask.phoneMaskFormatter],
                  validator: (value) => PersonalDataValidation.number(value),
                ),

                buildField(
                  "Email",
                  emailController,
                  validator: (value) => PersonalDataValidation.email(value),
                ),

                buildField(
                  "Rua",
                  addressController,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) => AddressValidation.road(value),
                ),

                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        "Número",
                        houseNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) =>
                            AddressValidation.numberHouse(value),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: buildField(
                        "CEP",
                        cepController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [Mask.cepMaskFormatter],
                        validator: (value) => AddressValidation.cep(value),
                      ),
                    ),
                  ],
                ),

                buildField(
                  "Bairro",
                  neighborhoodController,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) => AddressValidation.neighborhood(value),
                ),

                Row(
                  children: [
                    Expanded(
                      child: buildField(
                        "Cidade",
                        cityController,
                        keyboardType: TextInputType.name,
                        validator: (value) => AddressValidation.city(value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedState,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: AddressValidation.states.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                            stateController.text = value ?? '';
                          });
                        },
                        validator: (value) => AddressValidation.state(value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3F87),
                    ),
                    onPressed: loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            await saveCustomer();
                          },
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Salvar Cliente",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    houseNumberController.dispose();
    cepController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }
}
