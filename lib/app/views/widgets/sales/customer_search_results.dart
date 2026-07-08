import 'package:flutter/material.dart';
import '../../../model/customer_model.dart';

class CustomerSearchResults extends StatelessWidget {
  final List<CustomerModel> customers;
  final Function(CustomerModel) onSelect;

  const CustomerSearchResults({
    super.key,
    required this.customers,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final client = customers[index];

          return Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF0D3F87)),
              // AJUSTE: Exibe o Nome e adiciona o Nome Fantasia ao lado se existir
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: client.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (client.tradeName != null && client.tradeName!.trim().isNotEmpty)
                      TextSpan(
                        text: ' (${client.tradeName})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              subtitle: Text(client.cpforcnpj),
              onTap: () => onSelect(client),
            ),
          );
        },
      ),
    );
  }
}