import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/pages/home/home_page.dart';
import 'package:DasCobras/app/pages/sales/sales_page.dart';
import 'package:DasCobras/app/pages/reports/reports_page.dart';
import 'package:DasCobras/app/pages/client/create_client_dialog.dart';
import 'package:DasCobras/app/pages/client/edit_client_dialog.dart';
import 'view_client_dialog.dart';

import '../../viewmodels/client_viewmodel/client_viewmodel.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientViewModel>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            Center(
              child: Image.asset(
                'lib/app/assets/img/LogoLonga.png',
                width: 180,
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(
                hintText: 'Buscar cliente...',
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                trailing: const [Icon(Icons.search, color: Colors.grey)],
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                onChanged: (value) {
                  context.read<ClientViewModel>().searchCustomer(value);
                },
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Consumer<ClientViewModel>(
                builder: (context, service, _) {
                  if (service.filteredCustomers.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum cliente encontrado',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
                    itemCount: service.filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final client = service.filteredCustomers[index];

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                          left: 5,
                          right: 5,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF0D3F87)),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF0D3F87),
                                ),
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
                                    client.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "CPF/CNPJ",
                                    style: TextStyle(
                                      color: Color(0xFF0D3F87),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    client.cpforcnpj,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            ViewClientDialog(client: client),
                                      );
                                    },
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
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            EditClientDialog(client: client),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF44336),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              "Excluir Cliente",
                                            ),
                                            content: Text(
                                              "Deseja realmente apagar o cliente?\n\n${client.name}",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text("Não"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text(
                                                  "Sim",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmar == true) {
                                        try {
                                          await context
                                              .read<ClientViewModel>()
                                              .deleteCustomer(client.id);

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Cliente removido com sucesso!",
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Erro ao apagar cliente: $e",
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D3F87),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const CreateClientDialog(),
          );
        },
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF0D3F87),
        unselectedItemColor: const Color(0xFF0D3F87),
        showUnselectedLabels: true,

        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
              break;

            case 1:
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SalesPage()),
              );
              break;

            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReportsPage()),
              );
              break;
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Clientes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Venda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}
