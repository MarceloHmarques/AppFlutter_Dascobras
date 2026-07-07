import 'package:DasCobras/app/views/widgets/shared/logo_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sales_history_page.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:DasCobras/app/views/home/home_page.dart';
import 'package:DasCobras/app/views/reports/reports_page.dart';
import '../../model/customer_model.dart';
import '../../viewmodels/client_viewmodel/client_viewmodel.dart';
import 'package:DasCobras/app/views/client/client_page.dart';
import 'package:DasCobras/app/views/client/view_client_dialog.dart';
import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';
import 'cart_dialog.dart';
import 'package:DasCobras/app/views/widgets/home/custom_bottom_nav.dart';
import 'package:DasCobras/app/views/widgets/sales/selected_client_card.dart';
import 'package:DasCobras/app/views/widgets/shared/client_search_bar.dart';
import 'package:DasCobras/app/views/widgets/sales/customer_search_results.dart';
import 'package:DasCobras/app/views/widgets/shared/product_search_bar.dart';
import 'package:DasCobras/app/views/widgets/shared/category_filter.dart';
import 'package:DasCobras/app/views/widgets/shared/product_card.dart';
import 'package:DasCobras/app/views/widgets/sales/product_sale_actions.dart';
import 'package:DasCobras/app/views/widgets/sales/sales_floating_buttons.dart';

import 'package:provider/provider.dart';

import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  CustomerModel? selectedCustomer;

  final TextEditingController clientSearchController = TextEditingController();
  String selectedCategory = 'Todos';
  String selectedOrder = 'Mais relevantes';

  final ScrollController _scrollController = ScrollController();

  bool showHeader = true;
  double lastOffset = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeSearchViewmodel>().loadProduct();
      context.read<ClientViewModel>().loadCustomers();
    });

    _scrollController.addListener(() {
      final currentOffset = _scrollController.offset;

      if (currentOffset > lastOffset + 8 && currentOffset > 80) {
        if (showHeader) {
          setState(() => showHeader = false);
        }
      }

      if (currentOffset < lastOffset - 8) {
        if (!showHeader) {
          setState(() => showHeader = true);
        }
      }

      lastOffset = currentOffset;
    });
  }

  @override
  void dispose() {
    clientSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            ClipRect(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: showHeader
                    ? Column(
                        key: const ValueKey('header-visible'),
                        children: [
                          const LogoHeader(),

                          const SizedBox(height: 15),

                          ClientSearchBar(
                            controller: clientSearchController,
                            onChanged: (value) {
                              context.read<ClientViewModel>().searchCustomer(
                                value,
                              );
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 10),

                          if (selectedCustomer != null)
                            SelectedClientCard(
                              name: selectedCustomer!.name,
                              cpfOrCnpj: selectedCustomer!.cpforcnpj,
                              onDetails: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ViewClientDialog(
                                    client: selectedCustomer!,
                                  ),
                                );
                              },
                              onRemove: () {
                                setState(() {
                                  selectedCustomer = null;
                                });

                                context.read<SaleViewModel>().removeCustomer();
                                context.read<ClientViewModel>().searchCustomer(
                                  '',
                                );
                              },
                            ),
                        ],
                      )
                    : const SizedBox(key: ValueKey('header-hidden'), height: 0),
              ),
            ),

            const SizedBox(height: 0),

            Consumer<ClientViewModel>(
              builder: (context, clientVm, _) {
                if (selectedCustomer != null ||
                    clientSearchController.text.trim().isEmpty) {
                  return const SizedBox();
                }

                return CustomerSearchResults(
                  customers: clientVm.filteredCustomers,
                  onSelect: (client) {
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

            const SizedBox(height: 15),

            ProductSearchBar(
              onSearch: (value) {
                context.read<HomeSearchViewmodel>().searchProduct(value: value);
              },
            ),

            const SizedBox(height: 10),

            Consumer<HomeSearchViewmodel>(
              builder: (context, vm, _) {
                return CategoryFilter(
                  categories: vm.categories,
                  selectedCategory: selectedCategory,
                  selectedOrder: selectedOrder,
                  onCategorySelected: (category) {
                    setState(() => selectedCategory = category);
                    vm.filterByCategory(category);
                  },
                  onOrderSelected: (order) {
                    setState(() => selectedOrder = order);
                    vm.orderProducts(order);
                  },
                );
              },
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
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 100),
                    itemCount: service.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = service.filteredProducts[index];

                      return ProductCard(
                        product: product,
                        actions: ProductSaleActions(product: product),
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
          return SalesFloatingButtons(
            cartCount: saleVm.cart.length,
            onHistory: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalesHistoryPage()),
              );
            },
            onCart: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );

              if (mounted) {
                await context.read<HomeSearchViewmodel>().refreshProducts();
              }
            },
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
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        // Aqui está o segredo: pegamos o provider que já existe
        // e passamos para a próxima tela
        value: Provider.of<CarregamentoViewModel>(context, listen: false),
        child: const ClientPage(), // A página para onde você está indo
      ),
    ),
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
