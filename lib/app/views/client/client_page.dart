import 'package:DasCobras/app/views/sales/sales_page.dart';
import 'package:DasCobras/app/views/widgets/shared/logo_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/views/home/home_page.dart';
import 'package:DasCobras/app/views/reports/reports_page.dart';
import 'package:DasCobras/app/views/client/create_client_dialog.dart';
import 'package:DasCobras/app/views/client/edit_client_dialog.dart';
import 'package:DasCobras/app/views/client/create_route_dialog.dart'; // 🛠️ Import adicionado
import 'view_client_dialog.dart';
import 'package:DasCobras/app/views/widgets/home/custom_bottom_nav.dart';
import 'package:DasCobras/app/views/widgets/shared/client_search_bar.dart';
import 'package:DasCobras/app/views/widgets/client/client_card.dart';

import '../../viewmodels/client_viewmodel/client_viewmodel.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController clientSearchController = TextEditingController();

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
            const LogoHeader(),
            const SizedBox(height: 15),

            ClientSearchBar(
              controller: clientSearchController,
              onChanged: (value) {
                context.read<ClientViewModel>().searchCustomer(value);
                setState(() {});
              },
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

                      return ClientCard(
                        client: client,
                        onView: () {
                          showDialog(
                            context: context,
                            builder: (_) => ViewClientDialog(client: client),
                          );
                        },
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditClientDialog(client: client),
                          );
                        },
                        onDelete: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Excluir Cliente"),
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
                                      style: TextStyle(color: Colors.white),
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
                                  .deleteCustomer(client.id.toString());

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Cliente removido com sucesso!",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Erro ao apagar cliente: $e"),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🗺️ Botão de Rotas (Novo) - Configurado para abrir o modal de criação de rotas
          FloatingActionButton.extended(
            heroTag: 'btn_rotas',
            backgroundColor: const Color(0xFF0D3F87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateRouteDialog(),
              );
            },
            icon: const Icon(Icons.map_outlined, color: Colors.white),
            label: const Text(
              "Gerenciar Rotas", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          
          const SizedBox(height: 12),

          // 👤 Botão de Adicionar Cliente
          FloatingActionButton.extended(
            heroTag: 'btn_add_cliente',
            backgroundColor: const Color(0xFF0D3F87),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CreateClientDialog(),
              );
            },
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
            label: const Text(
              "Adicionar Cliente", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
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
      ),
    );
  }

  @override
  void dispose() {
    clientSearchController.dispose();
    super.dispose();
  }
}