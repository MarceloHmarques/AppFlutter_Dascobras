import 'package:DasCobras/app/service/validation_service/personal_validation.dart';
import 'package:DasCobras/app/service/validation_service/address_validation.dart';
import 'package:DasCobras/app/service/validation_service/mask.dart';
import 'package:DasCobras/app/service/validation_service/personal%20_data_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../viewmodels/client_viewmodel/client_viewmodel.dart';

class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog({super.key});

  @override
  State<CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<CreateClientDialog> {
  final nameController = TextEditingController();
  final tradeNameController = TextEditingController(); // 🛠️ Controller Novo
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

  bool loading = false;
  String customerType = 'PF';
  String? errorMessage;
  String? selectedState;
  
  String? selectedRouteId; // 🛠️ Armazena a rota selecionada
  List<Map<String, dynamic>> routesList = []; // 🛠️ Armazena as rotas do banco

  @override
  void initState() {
    super.initState();
    _fetchRoutes(); // Carrega as rotas ao abrir
  }

  // 🔄 Busca as rotas cadastradas no banco de dados para listar no Dropdown
  Future<void> _fetchRoutes() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('route').select('id, name').eq('is_active', true);
      if (response != null) {
        setState(() {
          routesList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print("Erro ao carregar rotas: $e");
    }
  }

  Future<void> saveCustomer() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final birthDateValue = birthDateController.text.trim().isEmpty 
          ? '' 
          : birthDateController.text.trim();
          final emailValue = emailController.text.trim().isEmpty ? null : emailController.text.trim();

      // Se seu ViewModel ainda não aceita tradeName e routeId, adicione no método addCustomer dele!
      await context.read<ClientViewModel>().addCustomer(
        name: nameController.text.trim(),
        birthDate: birthDateValue,
        phone: phoneController.text.trim(),
        email: emailValue ?? '',
        cpfOrCnpj: cpfController.text.trim(),
        customerType: customerType,
        state: stateController.text.trim(),
        city: cityController.text.trim(),
        neighborhood: neighborhoodController.text.trim(),
        cep: cepController.text.trim(),
        houseNumber: houseNumberController.text.trim(),
        address: addressController.text.trim(),
        // tradeName: tradeNameController.text.trim(), // Descomente quando ajustar o ViewModel
        // routeId: selectedRouteId,                  // Descomente quando ajustar o ViewModel
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cliente cadastrado com sucesso!")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
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
                  "Criar Cliente",
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF0D3F87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                buildField(
                  "Nome / Razão Social",
                  nameController,
                  validator: (value) => PersonalDataValidation.name(value),
                  keyboardType: TextInputType.name,
                ),

                buildField(
                  "Nome Fantasia (Opcional)",
                  tradeNameController,
                  keyboardType: TextInputType.text,
                ),

                DropdownButtonFormField<String>(
                  value: customerType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de cliente',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PF', child: Text('Pessoa Física')),
                    DropdownMenuItem(value: 'PJ', child: Text('Pessoa Jurídica')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      customerType = value!;
                      cpfController.clear();
                    });
                  },
                ),
                const SizedBox(height: 12),

                buildField(
                  customerType == 'PF' ? 'CPF' : 'CNPJ',
                  cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    customerType == 'PF' ? Mask.cpfMaskFormatter : Mask.cnpjMaskFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return customerType == 'PF' ? 'CPF obrigatório' : 'CNPJ obrigatório';
                    }
                    final valid = customerType == 'PF'
                        ? PersonalValidation.utilsCpf(value)
                        : PersonalValidation.utilsCnpj(value);
                    if (!valid) {
                      return customerType == 'PF' ? 'CPF inválido' : 'CNPJ inválido';
                    }
                    return null;
                  },
                ),

                // 🛠️ Dropdown Dinâmico de Rotas buscando do banco
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: selectedRouteId,
                    decoration: InputDecoration(
                      labelText: 'Selecione a Rota / Região',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: routesList.map((route) {
                      return DropdownMenuItem<String>(
                        value: route['id'].toString(),
                        child: Text(route['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedRouteId = value),
                    validator: (value) => value == null ? 'Por favor, selecione uma rota' : null,
                  ),
                ),

                buildField(
                  "Data de nascimento (Opcional)",
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
                        birthDateController.text = '${date.day}/${date.month}/${date.year}';
                      });
                    }
                  },
                ),
email: emailValue ?? '',
                buildField(
                  "Telefone",
                  phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [Mask.phoneMaskFormatter],
                  validator: (value) => PersonalDataValidation.number(value),
                ),

                buildField(
                  "Email (Opcional)", // Label atualizado
                  emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    // Valida apenas se o usuário preencher algo
                    if (value != null && value.isNotEmpty) {
                      return PersonalDataValidation.email(value);
                    }
                    return null; // Campo vazio é aceito
                  },
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) => AddressValidation.numberHouse(value),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: AddressValidation.states.map((state) {
                          return DropdownMenuItem(value: state, child: Text(state));
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
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D3F87)),
                    onPressed: loading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      await saveCustomer();
                    },
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Salvar Cliente", style: TextStyle(color: Colors.white, fontSize: 18)),
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
    tradeNameController.dispose();
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