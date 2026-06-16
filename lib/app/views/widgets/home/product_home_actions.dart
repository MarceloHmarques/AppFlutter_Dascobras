import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/views/home/edit_product_dialog.dart';
import 'package:DasCobras/app/views/widgets/home/product_action_button.dart';
import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';

class ProductHomeActions extends StatelessWidget {
  final dynamic product;

  const ProductHomeActions({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProductActionButton(
          color: const Color(0xFFFF9800),
          icon: Icons.edit_outlined,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => EditProductDialog(product: product),
            );
          },
        ),
        const SizedBox(height: 8),
        ProductActionButton(
          color: const Color(0xFFF44336),
          icon: Icons.delete_outline,
          onPressed: () async {
            final confirmar = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Excluir Produto"),
                  content: Text(
                    "Este produto deixará de aparecer nas vendas e no estoque. Deseja continuar?\n\n${product.name}",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Não"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => Navigator.pop(context, true),
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
              await context.read<HomeSearchViewmodel>().deleteProduct(
                product.id,
              );
            }
          },
        ),
      ],
    );
  }
}
