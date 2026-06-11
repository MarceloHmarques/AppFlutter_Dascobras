import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';
import '../../services/pdf_service.dart';
import '../../viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrinho"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
      ),

      body: Consumer<SaleViewModel>(
        builder: (context, saleVm, _) {
          if (saleVm.customer == null) {
            return const Center(
              child: Text("Selecione um cliente antes de finalizar a venda"),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0D3F87),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Table(
                    border: TableBorder.all(color: const Color(0xFF0D3F87)),
                    children: [
                      TableRow(
                        children: [
                          _cell("Nome:\n${saleVm.customer?.name ?? ''}"),
                          _cell(
                            "CPF/CNPJ:\n${saleVm.customer?.cpforcnpj ?? ''}",
                          ),
                        ],
                      ),

                      TableRow(
                        children: [
                          _cell(
                            "Data de nascimento:\n${saleVm.customer?.birthDate ?? ''}",
                          ),
                          _cell("ID do pedido:\n${saleVm.cart.hashCode}"),
                        ],
                      ),

                      TableRow(
                        children: [
                          _cell("Rua:\n${saleVm.customer?.address ?? ''}"),
                          _cell(
                            "Número:\n${saleVm.customer?.houseNumber ?? ''}",
                          ),
                        ],
                      ),

                      TableRow(
                        children: [
                          _cell(
                            "Bairro:\n${saleVm.customer?.neighborhood ?? ''}",
                          ),
                          _cell("CEP:\n${saleVm.customer?.cep ?? ''}"),
                        ],
                      ),

                      TableRow(
                        children: [
                          _cell("Cidade:\n${saleVm.customer?.city ?? ''}"),
                          _cell("Estado:\n${saleVm.customer?.state ?? ''}"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pedido",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: Border.all()),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                "X",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            Expanded(
                              child: Text(
                                "Descrição",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            SizedBox(
                              width: 50,
                              child: Text(
                                "Qtd",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            SizedBox(
                              width: 70,
                              child: Text(
                                "Valor",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                            SizedBox(
                              width: 80,
                              child: Text(
                                "Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: saleVm.cart.length,
                          itemBuilder: (context, index) {
                            final item = saleVm.cart[index];

                            return Container(
                              padding: const EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),

                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: InkWell(
                                      onTap: () async {
                                        await saleVm.removeProduct(
                                          item.product,
                                        );
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),

                                  Expanded(child: Text(item.product.name)),

                                  SizedBox(
                                    width: 110,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            saleVm.decreaseQuantity(item);
                                          },
                                          child: const Icon(
                                            Icons.remove_circle_outline,
                                          ),
                                        ),

                                        Expanded(
                                          child: TextFormField(
                                            initialValue: item.quantity
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                            ),
                                            onFieldSubmitted: (value) {
                                              final quantity =
                                                  int.tryParse(value) ?? 1;

                                              try {
                                                saleVm.changeQuantity(
                                                  item,
                                                  quantity,
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      e.toString().replaceFirst(
                                                        'Exception: ',
                                                        '',
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),

                                        InkWell(
                                          onTap: () {
                                            try {
                                              saleVm.increaseQuantity(item);
                                            } catch (e) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.toString().replaceFirst(
                                                      'Exception: ',
                                                      '',
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      item.product.price.toStringAsFixed(2),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      item.subtotal.toStringAsFixed(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  "TOTAL: R\$ ${saleVm.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          saleVm.cancelSale();

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          try {
                            final pdfFile = await PdfService.generate(saleVm);

                            await saleVm.finishSale();

                            await Share.shareXFiles([
                              XFile(pdfFile.path),
                            ], text: 'Pedido ${saleVm.customer?.name}');

                            saleVm.cancelSale();

                            await context
                                .read<HomeSearchViewmodel>()
                                .loadProduct();
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: const Text(
                          "Finalizar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}
