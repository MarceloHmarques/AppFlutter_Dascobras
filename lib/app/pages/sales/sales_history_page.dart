import 'package:DasCobras/app/service/sale_service.dart/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sale_viewmodel/sale_history_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleHistoryViewModel>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: SearchBar(
              hintText: 'Buscar cliente...',
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
                context.read<SaleHistoryViewModel>().searchCustomer(value);
              },
            ),
          ),

          Expanded(
            child: Consumer<SaleHistoryViewModel>(
              builder: (_, vm, __) {
                return ListView.builder(
                  itemCount: vm.filteredSales.length,
                  itemBuilder: (_, index) {
                    final sale = vm.filteredSales[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF0D3F87),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),

                      child: ListTile(
                        title: Text(sale['customer']['name']),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 4),

                            Text(
                              'Pedido #${sale['id']}',
                              style: const TextStyle(
                                color: Color(0xFF0D3F87),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              'R\$ ${sale['total']}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Color(0xFF0D3F87),
                          ),
                          onPressed: () async {
                            try {
                              final items = await vm.getSaleItems(sale['id']);

                              final pdfFile =
                                  await PdfService.generateHistoryPdf(
                                    sale: sale,
                                    items: items,
                                  );

                              await Share.shareXFiles([
                                XFile(pdfFile.path),
                              ], text: 'Comprovante da venda #${sale['id']}');
                            } catch (e) {
                              print(e);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
