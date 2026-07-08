import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:DasCobras/app/service/pdf/loading_sheet_pdf_service.dart';
import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart';

class CarregamentoPage extends StatelessWidget {
  const CarregamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo do Carregamento'),
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
      ),
      body: Consumer<CarregamentoViewModel>(
        builder: (context, vm, _) {
          if (vm.itensAcumulados.isEmpty) {
            return const Center(
              child: Text('Nenhum item adicionado ao carregamento.'),
            );
          }

          final listaItens = vm.itensAcumulados.values.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: listaItens.length,
                  itemBuilder: (context, index) {
                    final item = listaItens[index];
                    return ListTile(
                      title: Text(item['product']['name']),
                      trailing: CircleAvatar(
                        backgroundColor: const Color(0xFF0D3F87),
                        child: Text(
                          '${item['quantity']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Limpar'),
                        onPressed: () => vm.limparCarregamento(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3F87),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Gerar PDF'),
                        onPressed: () async {
                          final pdfBytes = await LoadingSheetPdfService()
                              .generateLoadingSheet(
                                companyName: 'Das Cobra Stock',
                                routeName: 'Rota Principal',
                                items: vm.itensAcumulados.values.map((item) {
                                  return {
                                    'product_id': item['product']['id'],
                                    'product_name': item['product']['name'],
                                    'brand':
                                        item['product']['brand'] ?? 'Sem Marca',
                                    'quantity': item['quantity'],
                                  };
                                }).toList(),
                              );

                          if (kIsWeb) {
                            await Printing.layoutPdf(
                              onLayout: (_) async => pdfBytes,
                              name: 'MapaCarregamento.pdf',
                            );
                          } else {
                            final dir =
                                await getApplicationDocumentsDirectory();

                            final file = File(
                              '${dir.path}/MapaCarregamento.pdf',
                            );

                            await file.writeAsBytes(pdfBytes);

                            OpenFilex.open(file.path);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
