import 'package:flutter/material.dart';

import '../../model/customer_model.dart';

class ViewClientDialog extends StatelessWidget {
  final CustomerModel client;

  const ViewClientDialog({super.key, required this.client});

  Widget buildInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3F87),
              ),
            ),
            const SizedBox(height: 4),
            Text(value.isEmpty ? "-" : value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF0D3F87), width: 2),
          ),
          child: Column(
            children: [
              const Text(
                "Detalhes do Cliente",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3F87),
                ),
              ),

              const SizedBox(height: 20),

              buildInfo("Nome", client.name),
              buildInfo("CPF/CNPJ", client.cpforcnpj),
              buildInfo("Data de Nascimento", client.birthDate),
              buildInfo("Telefone", client.phone),
              buildInfo("E-mail", client.email),
              buildInfo("Rua", client.address),
              buildInfo("Número", client.houseNumber),
              buildInfo("CEP", client.cep),
              buildInfo("Bairro", client.neighborhood),
              buildInfo("Cidade", client.city),
              buildInfo("Estado", client.state),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3F87),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Fechar",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
