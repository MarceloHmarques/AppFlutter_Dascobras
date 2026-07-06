import 'package:flutter/material.dart';

class ClientCard extends StatelessWidget {
  final dynamic client;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientCard({
    super.key,
    required this.client,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 🛠️ Tratamento para verificar se existe Nome Fantasia (trade_name) preenchido
    final hasTradeName =
        client.tradeName != null &&
        client.tradeName.toString().trim().isNotEmpty;
    // 🛠️ Tratamento para buscar a Rota (caso ainda não exista no objeto, evita quebrar o app)
    final routeName = client.route ?? 'Sem Rota Definida';

    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
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
                // 📋 Exibe o Nome Fantasia em destaque se existir, caso contrário exibe o Razão Social / Nome
                Text(
                  hasTradeName
                      ? client.tradeName.toString().toUpperCase()
                      : client.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3F87),
                  ),
                ),

                // 🛠️ Se houver Nome Fantasia, mostra o Nome Civil / Razão Social logo abaixo menor
                if (hasTradeName)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "Nome: ${client.name}",
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // 🌐 Row contendo o CPF/CNPJ e a ROTA lado a lado para economizar espaço
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CPF/CNPJ",
                          style: TextStyle(
                            color: Color(0xFF0D3F87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(client.cpforcnpj),
                      ],
                    ),
                    const SizedBox(width: 25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ROTA",
                          style: TextStyle(
                            color: Color(
                              0xFF0D3F87,
                            ), // 🎨 Cor em destaque para a rota
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          routeName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: onView,
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

          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
