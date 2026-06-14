import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';

import 'package:DasCobras/app/pages/home/home_page.dart';
import 'package:DasCobras/app/pages/reports/reports_page.dart';
import '../../model/customer_model.dart';
import '../../viewmodels/client_viewmodel/client_viewmodel.dart';
import 'package:DasCobras/app/pages/client/client_page.dart';
import 'package:DasCobras/app/pages/client/view_client_dialog.dart';
import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';
import 'cart_dialog.dart';
import 'package:DasCobras/app/pages/sales/add_product_cart_dialog.dart';
import 'package:DasCobras/app/pages/widgets/home/custom_bottom_nav.dart';
import 'sales_history_page.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  CustomerModel? selectedCustomer;

  final TextEditingController clientSearchController = TextEditingController();
  String selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeSearchViewmodel>().loadProduct();
      context.read<ClientViewModel>().loadCustomers();
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
                controller: clientSearchController,
                hintText: 'Buscar Cliente...',
                hintStyle: const WidgetStatePropertyAll(
                  TextStyle(color: Color(0xFF0D3F87)),
                ),
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
                  context.read<ClientViewModel>().searchCustomer(value);
                  setState(() {});
                },
              ),
            ),

            // LISTA DE CLIENTES ENCONTRADOS
            Consumer<ClientViewModel>(
              builder: (context, clientVm, _) {
                if (selectedCustomer != null ||
                    clientSearchController.text.trim().isEmpty) {
                  return const SizedBox();
                }

                if (clientVm.filteredCustomers.isEmpty) {
                  return const SizedBox();
                }

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: clientVm.filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final client = clientVm.filteredCustomers[index];

                      return ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF0D3F87),
                        ),
                        title: Text(client.name),
                        subtitle: Text(client.cpforcnpj),
                        onTap: () {
                          setState(() {
                            selectedCustomer = client;

                            clientSearchController.clear();

                            context.read<SaleViewModel>().setCustomer(client);
                          });

                          context.read<ClientViewModel>().searchCustomer('');
                        },
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 15),
            Consumer<ClientViewModel>(
              builder: (context, clientVm, _) {
                if (selectedCustomer == null) {
                  return const SizedBox();
                }

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
                              selectedCustomer!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'CPF/CNPJ: ${selectedCustomer!.cpforcnpj}',
                              style: const TextStyle(
                                color: Color(0xFF0D3F87),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ViewClientDialog(
                                    client: selectedCustomer!,
                                  ),
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

                      IconButton(
                        onPressed: () {
                          setState(() {
                            setState(() {
                              selectedCustomer = null;
                            });

                            context.read<SaleViewModel>().removeCustomer();

                            context.read<ClientViewModel>().searchCustomer('');
                          });

                          context.read<ClientViewModel>().searchCustomer('');
                        },
                        icon: const Icon(Icons.close, color: Color(0xFF0D3F87)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBar(
                hintText: 'Buscar produto...',
                elevation: const WidgetStatePropertyAll(0),
                hintStyle: const WidgetStatePropertyAll(
                  TextStyle(color: Color(0xFF0D3F87)),
                ),
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

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: openCategoryFilter,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF0D3F87),
                          width: 1,
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
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
                                      color: Colors.green,
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
                                      color: product.stock > 0
                                          ? const Color(0xFF0D3F87)
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          product.stock > 0
                                              ? Icons.inventory_2_outlined
                                              : Icons.warning_amber_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.stock > 0
                                              ? '${product.stock} em estoque'
                                              : 'Sem estoque',
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

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        AddProductCartDialog(product: product),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
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

      floatingActionButton: Consumer<SaleViewModel>(
        builder: (context, saleVm, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "history",
                backgroundColor: Color(0xFF0D3F87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesHistoryPage()),
                  );
                },
                child: const Icon(Icons.history, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Badge(
                label: Text("${saleVm.cart.length}"),
                child: FloatingActionButton(
                  heroTag: "cart",
                  backgroundColor: const Color(0xFF0D3F87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartPage()),
                    );
                  },
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, // Tela de Venda
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ClientPage()),
              );
              break;

            case 2:
              break; // Já está na tela de venda

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
