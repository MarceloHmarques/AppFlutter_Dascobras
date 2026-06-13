import 'package:DasCobras/app/pages/sales/sales_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:DasCobras/app/pages/home/edit_product_dialog.dart';
import 'package:DasCobras/app/pages/home/add_product_dialog.dart';
import 'package:DasCobras/app/pages/client/client_page.dart';
import 'package:DasCobras/app/pages/reports/reports_page.dart';
import 'package:DasCobras/app/pages/widgets/custom_bottom_nav.dart';

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
      context.read<HomeSearchViewmodel>().loadProduct();
    });
  }

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
                trailing: const [Icon(Icons.search, color: Colors.grey)],
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
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
                  if (service.filteredProducts.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(fontSize: 18),
                      ),
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF0D3F87),
                                ),
                              ),
                              child: Image.network(
                                product.imageurl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) {
                                  return const Icon(
                                    Icons.image_not_supported_outlined,
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF000000),
                                    ),
                                  ),

                                  Text(
                                    product.category,
                                    style: const TextStyle(
                                      color: Color(0xFF0D3F87),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  Text(
                                    'R\$ ${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFF28A745),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stockColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          stockText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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
                                        builder: (context) =>
                                            EditProductDialog(product: product),
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
                                              "Excluir Produto",
                                            ),
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
                                              .read<HomeSearchViewmodel>()
                                              .deleteProduct(product.id);

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Produto removido com sucesso!",
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
                                                  "Erro ao apagar: $e",
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
