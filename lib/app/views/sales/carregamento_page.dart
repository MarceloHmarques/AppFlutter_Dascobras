import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart';
import 'package:DasCobras/app/service/pdf/loading_sheet_pdf_service.dart';
import 'package:printing/printing.dart';

class CarregamentoPage extends StatelessWidget {
  const CarregamentoPage({Key? key}) : super(key: key);

  // 🚀 Gera o PDF direto e limpa o carregamento sem perguntar rota
  Future<void> _gerarPdfEFinalizar(BuildContext context, CarregamentoViewModel vm) async {
    try {
      // Mapeia os dados acumulados para a lista de itens do PDF
      final List<Map<String, dynamic>> itensAgrupados = 
          vm.itensAcumulados.values.map((e) => Map<String, dynamic>.from(e)).toList();

      // Gera os bytes do PDF usando um nome padrão fixo de Rota
      final pdfBytes = await LoadingSheetPdfService().generateLoadingSheet(
        companyName: "Das Cobras",
        routeName: "Rota Geral", // 🟢 Definido direto aqui
        itens: itensAgrupados, 
      );

      // Abre a janela nativa de impressão/salvamento do PDF
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Mapa_Carregamento_Geral.pdf',
      );

      // 🟢 Limpa os dados do ViewModel e zera o badge do caminhão imediatamente
      vm.limparCarregamento();

      // Retorna para a tela anterior (Histórico ou Home) com o feedback de sucesso
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Carregamento finalizado e zerado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao gerar PDF: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Carregamento"),
      ),
      body: Consumer<CarregamentoViewModel>(
        builder: (context, vm, _) {
          if (vm.pedidosCarregamento.isEmpty) {
            return const Center(
              child: Text("Nenhum pedido adicionado ao carregamento."),
            );
          }

          return ListView.builder(
            itemCount: vm.pedidosCarregamento.length,
            itemBuilder: (context, index) {
              final pedido = vm.pedidosCarregamento[index];
              final List<dynamic> itensDoPedido = pedido['items'] ?? [];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📦 Topo da Caixa de Pedido
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: Colors.grey.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PEDIDO: #${pedido['id'] ?? pedido['order_id'] ?? 'N/A'}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${pedido['customer_name'] ?? pedido['customerName'] ?? 'CLIENTE'}".toUpperCase(),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              vm.removerPedido(index);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // 🍎 Lista Interna de Produtos deste Pedido
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itensDoPedido.length,
                      itemBuilder: (context, i) {
                        final item = itensDoPedido[i];
                        
                        final productName = item['product_name'] ?? item['product']?['name'] ?? 'PRODUTO';
                        final brand = item['brand'] ?? item['product']?['brand'] ?? 'SEM MARCA';
                        final quantity = item['quantity'] ?? 0;

                        return ListTile(
                          dense: true,
                          title: Text(
                            "$productName".toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("Marca: $brand"),
                          trailing: Text(
                            "$quantity UN",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.blueAccent,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // 🟢 Botão inferior que agora chama a função direta sem o pop-up da rota
      bottomNavigationBar: Consumer<CarregamentoViewModel>(
        builder: (context, vm, _) {
          if (vm.pedidosCarregamento.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                "FINALIZAR CARREGAMENTO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () => _gerarPdfEFinalizar(context, vm), // 🟢 Direto para a ação!
            ),
          );
        },
      ),
    );
  }
}
