import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../model/customer_model.dart';
import '../../viewmodels/client_viewmodel/client_viewmodel.dart';
import 'package:DasCobras/app/service/validation_service/personal_validation.dart';
import 'package:DasCobras/app/service/validation_service/address_validation.dart';
import 'package:DasCobras/app/service/validation_service/mask.dart';
import 'package:DasCobras/app/service/validation_service/personal%20_data_validation.dart';

class EditClientDialog extends StatefulWidget {
  final CustomerModel client;

  const EditClientDialog({super.key, required this.client});

  @override
  State<EditClientDialog> createState() => _EditClientDialogState();
}

class _EditClientDialogState extends State<EditClientDialog> {
  late TextEditingController nameController;
  late TextEditingController cpfController;
  late TextEditingController birthDateController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController addressController;
  late TextEditingController houseNumberController;
  late TextEditingController cepController;
  late TextEditingController neighborhoodController;
  late TextEditingController cityController;
  late TextEditingController stateController;

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String? errorMessage;
  String customerType = 'PF';
  String? selectedState;
  @override
  void initState() {
    super.initState();
    final type = widget.client.customerType.trim().toUpperCase();

    customerType = type == 'PJ' ? 'PJ' : 'PF';

    nameController = TextEditingController(text: widget.client.name);
    cpfController = TextEditingController(text: widget.client.cpforcnpj);
    birthDateController = TextEditingController(text: widget.client.birthDate);
    phoneController = TextEditingController(text: widget.client.phone);
    emailController = TextEditingController(text: widget.client.email);

    addressController = TextEditingController(text: widget.client.address);

    houseNumberController = TextEditingController(
      text: widget.client.houseNumber,
    );

    cepController = TextEditingController(text: widget.client.cep);

    neighborhoodController = TextEditingController(
      text: widget.client.neighborhood,
    );

    cityController = TextEditingController(text: widget.client.city);
    stateController = TextEditingController(text: widget.client.state);
    selectedState = widget.client.state;
  }

  Future<void> updateCustomer() async {
    try {
      setState(() => loading = true);

      await context.read<ClientViewModel>().updateCustomer(
        id: widget.client.id,
        name: nameController.text,
        birthDate: birthDateController.text,
        phone: phoneController.text,
        email: emailController.text,
        customerType: customerType,
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
          const SnackBar(content: Text("Cliente atualizado com sucesso!")),
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
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D3F87), width: 2),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Editar Cliente",
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

                DropdownButtonFormField<String>(
                  value: customerType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de cliente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PF', child: Text('Pessoa Física')),
                    DropdownMenuItem(
                      value: 'PJ',
                      child: Text('Pessoa Jurídica'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      customerType = value!;
                      cpfController.clear();
                    });
                  },
                ),

                const SizedBox(height: 10),

                buildField(
                  customerType == 'PF' ? 'CPF' : 'CNPJ',
                  cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    customerType == 'PF'
                        ? Mask.cpfMaskFormatter
                        : Mask.cnpjMaskFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return customerType == 'PF'
                          ? 'CPF obrigatório'
                          : 'CNPJ obrigatório';
                    }

                    final valid = customerType == 'PF'
                        ? PersonalValidation.utilsCpf(value)
                        : PersonalValidation.utilsCnpj(value);

                    if (!valid) {
                      return customerType == 'PF'
                          ? 'CPF inválido'
                          : 'CNPJ inválido';
                    }

                    return null;
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
                  keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(width: 10),
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

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

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
                            if (!_formKey.currentState!.validate()) return;
                            await updateCustomer();
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
}
