import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/reports_viewmodel/reports_viewmodel.dart';
import 'package:DasCobras/app/service/pdf/pdf_receipt_data.dart';
import 'package:DasCobras/app/service/pdf/pdf_service.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PendingSalesPage extends StatelessWidget {
  const PendingSalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos Pendentes"),
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReportsViewModel>(
        builder: (_, vm, __) {
          if (vm.pendingSales.isEmpty) {
            return const Center(child: Text("Nenhum pedido pendente."));
          }

          return ListView.builder(
            itemCount: vm.pendingSales.length,
            itemBuilder: (_, index) {
              final sale = vm.pendingSales[index];

              return ListTile(
                title: Text(sale['customer']['name']),
                subtitle: Text("Pedido #${sale['id']}"),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFF0D3F87),
                  ),
                  onPressed: () async {
                    try {
                      final items = await vm.getSaleItems(sale['id']);

                      final data = PdfReceiptData(
                        sale: sale,
                        company: sale['company'] ?? {},
                        customer: sale['customer'],
                        items: items,
                      );

                      final pdf = await PdfService.generateReceipt(data);

                      if (!context.mounted) return;

                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.visibility),
                              title: const Text("Visualizar"),
                              onTap: () {
                                Navigator.pop(context);
                                OpenFilex.open(pdf.path);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text("Compartilhar"),
                              onTap: () {
                                Navigator.pop(context);
                                Share.shareXFiles([XFile(pdf.path)]);
                              },
                            ),
                          ],
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
