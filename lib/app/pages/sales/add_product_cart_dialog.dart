import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/product_search_model.dart';
import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';

class AddProductCartDialog extends StatefulWidget {
  final ProductSearchModel product;

  const AddProductCartDialog({
    super.key,
    required this.product,
  });

  @override
  State<AddProductCartDialog> createState() =>
      _AddProductCartDialogState();
}

class _AddProductCartDialogState
    extends State<AddProductCartDialog> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0D3F87),
                      ),
                    ),
                    child: Image.network(
                      widget.product.imageurl,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Quantidade",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          value: quantity,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: List.generate(
                            widget.product.stock,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text(
                                "${index + 1}",
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              quantity = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                context
                                    .read<SaleViewModel>()
                                    .addProduct(
                                      widget.product,
                                      quantity,
                                    );

                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.reply,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}