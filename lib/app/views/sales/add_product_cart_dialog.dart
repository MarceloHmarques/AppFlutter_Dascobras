import 'package:DasCobras/app/service/validation_service/product_validation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:DasCobras/app/views/widgets/shared/product_image.dart';
import '../../model/product_search_model.dart';
import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';

class AddProductCartDialog extends StatefulWidget {
  final ProductSearchModel product;

  const AddProductCartDialog({super.key, required this.product});

  @override
  State<AddProductCartDialog> createState() => _AddProductCartDialogState();
}

class _AddProductCartDialogState extends State<AddProductCartDialog> {
  final TextEditingController quantityController = TextEditingController(
    text: "1",
  );

  late final TextEditingController priceController;

  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  int quantity = 1;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF0D3F87), width: 2),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ),

                  ProductImage(
                    imageUrl: widget.product.imageurl,
                    width: 140,
                    height: 140,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    currency.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.product.stock > 0
                          ? const Color(0xFF0D3F87)
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product.stock > 0
                          ? "Estoque: ${widget.product.stock}"
                          : "Sem estoque",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Preço de Venda Praticado:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D3F87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixText: "R\$ ",
                      hintText: "Digite o novo preço se desejar alterar",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0D3F87), width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Quantidade:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3F87),
                        ),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              quantityController.text = quantity.toString();
                            });
                          }
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),

                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          validator: (value) => ProductValidation.stock(value),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D3F87),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF0D3F87),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) return;

                            final qtd = int.tryParse(value);

                            if (qtd == null) return;

                            setState(() {
                              if (qtd > widget.product.stock) {
                                quantity = widget.product.stock;
                                quantityController.text = widget.product.stock.toString();
                                quantityController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: quantityController.text.length),
                                );
                              } else if (qtd < 1) {
                                quantity = 1;
                                quantityController.text = '1';
                                quantityController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: quantityController.text.length),
                                );
                              } else {
                                quantity = qtd;
                              }
                            });
                          },
                        ),
                      ),

                      IconButton(
  style: IconButton.styleFrom(
    backgroundColor: const Color(0xFF0D3F87),
  ),
  onPressed: () {
    setState(() {
      quantity++;
      quantityController.text = quantity.toString();
    });
  },
  icon: const Icon(Icons.add, color: Colors.white),
),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                   style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3F87),
                      ),
                    onPressed: () {
                    final qtd = int.tryParse(quantityController.text) ?? 0;

                    if (qtd < 1) return;
                       final double? parsedPrice = double.tryParse(
                     priceController.text.replaceAll(',', '.'),
                      );

                     final double? customPrice = 
                    (parsedPrice != null && parsedPrice != widget.product.price) 
                    ? parsedPrice 
                    : null;

                    context.read<SaleViewModel>().addProduct(
                      widget.product,
                      qtd,
                     customPrice: customPrice,
                      );

                    Navigator.pop(context);
                    },
                      icon: const Icon(
                      Icons.shopping_cart,
                     color: Colors.white,
                      ),
                       label: const Text(
                          "Adicionar ao Carrinho",
                           style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }
}