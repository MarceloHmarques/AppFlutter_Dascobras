import 'package:flutter/material.dart';

class SelectedClientCard extends StatelessWidget {
  final String name;
  final String cpfOrCnpj;
  final VoidCallback onDetails;
  final VoidCallback onRemove;

  const SelectedClientCard({
    super.key,
    required this.name,
    required this.cpfOrCnpj,
    required this.onDetails,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0D3F87)),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 50,
              color: Color(0xFF0D3F87),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'CPF/CNPJ: $cpfOrCnpj',
                  style: const TextStyle(
                    color: Color(0xFF0D3F87),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: onDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3F87),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Ver Detalhes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Color(0xFF0D3F87)),
          ),
        ],
      ),
    );
  }
}
