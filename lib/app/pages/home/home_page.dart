import 'package:DasCobras/app/pages/sales/sales_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:DasCobras/app/pages/home/edit_product_dialog.dart';
import 'package:DasCobras/app/pages/home/add_product_dialog.dart';
import 'package:DasCobras/app/pages/client/client_page.dart';
import 'package:DasCobras/app/pages/reports/reports_page.dart';
import 'package:DasCobras/app/pages/widgets/home/custom_bottom_nav.dart';
import 'package:DasCobras/app/pages/widgets/home/product_car_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeSearchViewmodel>().loadProduct(force: true);
    });
  }

  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  void openCategoryFilter() {
    final vm = context.read<HomeSearchViewmodel>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vm.categories.length,
            itemBuilder: (context, index) {
              final category = vm.categories[index];

              return ListTile(
                title: Text(category),
                trailing: selectedCategory == category
                    ? const Icon(Icons.check, color: Color(0xFF0D3F87))
                    : null,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });

                  vm.filterByCategory(category);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
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
                hintText: 'Buscar produto...',
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: const WidgetStatePropertyAll(Colors.white),
                trailing: const [Icon(Icons.search, color: Color(0xFF0D3F87))],
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Color(0xFF0D3F87)),
                  ),
                ),
                onChanged: (value) {
                  context.read<HomeSearchViewmodel>().searchProduct(
                    value: value,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: openCategoryFilter,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF0D3F87),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.filter_alt_outlined,
                        color: Color(0xFF0D3F87),
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3F87),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selectedCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Consumer<HomeSearchViewmodel>(
                builder: (context, service, _) {
                  if (service.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (service.filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('Nenhum produto encontrado'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
                    itemCount: service.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = service.filteredProducts[index];

                      final Color stockColor = product.stock == 0
                          ? Colors.red
                          : product.stock <= 10
                          ? Colors.orange
                          : const Color(0xFF0D3F87);

                      final String stockText = product.stock == 0
                          ? 'Sem estoque'
                          : product.stock <= 10
                          ? 'Últimas ${product.stock} unidades'
                          : '${product.stock} em estoque';

                      return ProductCard(
                        product: product,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                EditProductDialog(product: product),
                          );
                        },
                        onDelete: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Excluir Produto"),
                                content: Text(
                                  "Deseja realmente apagar o produto?\n\n${product.name}",
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
                                  .read<HomeSearchViewmodel>()
                                  .deleteProduct(product.id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Produto removido com sucesso!",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erro ao apagar: $e")),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D3F87),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddProductDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // Home
        onTap: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ClientPage()),
              );
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
}
