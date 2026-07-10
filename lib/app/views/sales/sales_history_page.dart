import 'package:DasCobras/app/service/pdf/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:DasCobras/app/service/pdf/pdf_receipt_data.dart';
import 'package:open_filex/open_filex.dart';
import '../../viewmodels/sale_viewmodel/sale_history_viewmodel.dart';
import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart';

import 'package:DasCobras/app/views/commission/commission_report_page.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({super.key});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  DateTime? startDate;
  DateTime? endDate;
  String selectedFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleHistoryViewModel>().loadSales();
      context.read<SaleHistoryViewModel>().loadRotas();
    });
  }

  Widget _buildFilterButton(String label, VoidCallback onTap) {
    final isSelected = selectedFilter == label;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0D3F87) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF0D3F87),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF0D3F87)),
        ),
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
          onTap();
        },
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
        actions: [
          // 🟢 Botão de Relatório de Comissões
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'Ver Comissões',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommissionReportPage()),
              );
            },
          ),

          // Seu botão original de limpar filtros
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Limpar filtros',
            onPressed: () {
              setState(() {
                selectedFilter = '';
              });
              context.read<SaleHistoryViewModel>().clearFilters();
            },
          ),
        ],
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
                  side: const BorderSide(color: Color(0xFF0D3F87)),
                ),
              ),
              onChanged: (value) {
                context.read<SaleHistoryViewModel>().searchCustomer(value);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Consumer<SaleHistoryViewModel>(
              builder: (context, vm, _) {
                return DropdownButtonFormField<int>(
                  value: vm.selectedRouteId,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Rota',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Todas as Rotas"),
                    ),
                    ...vm.rotasDisponiveis.map(
                      (rota) => DropdownMenuItem(
                        value: rota['id'] as int,
                        child: Text(rota['name']),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<SaleHistoryViewModel>().filterByRoute(value);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text(
                  'Filtrar por período',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0D3F87),
                  side: const BorderSide(color: Color(0xFF0D3F87), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (range != null) {
                    setState(() {
                      selectedFilter = 'Período';
                    });
                    context.read<SaleHistoryViewModel>().filterByDate(
                      range.start,
                      range.end,
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                _buildFilterButton(
                  'Hoje',
                  () => context.read<SaleHistoryViewModel>().filterToday(),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  '7 Dias',
                  () => context.read<SaleHistoryViewModel>().filterLast7Days(),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                  '30 Dias',
                  () => context.read<SaleHistoryViewModel>().filterLast30Days(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<SaleHistoryViewModel>(
              builder: (_, vm, __) {
                if (vm.filteredSales.isEmpty) {
                  return const Center(child: Text('Nenhuma venda encontrada'));
                }
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
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          sale['customer']?['name'] ??
                                          'Cliente não informado',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (sale['customer']?['trade_name'] !=
                                            null &&
                                        sale['customer']['trade_name']
                                            .toString()
                                            .trim()
                                            .isNotEmpty)
                                      TextSpan(
                                        text:
                                            ' (${sale['customer']['trade_name']})',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 3),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sale['payment_status'] == 'Pago'
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sale['payment_status'] ?? 'Pendente',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                // 🟢 Corrigido: Instancia o viewmodel do carregamento localmente no escopo do botão
                                final carregamentoVm = context
                                    .read<CarregamentoViewModel>();

                                // 🟢 Corrigido: Se os itens não vierem no mapa inicial, busca de forma assíncrona com o método correto
                                final itens =
                                    sale['items'] ??
                                    sale['itens'] ??
                                    await vm.getSaleItems(sale['id']) ??
                                    [];

                                if (!mounted) return;

                                // 🟢 Estrutura o mapa do pedido completo de forma segura
                                final pedidoCompleto = {
                                  'id': sale['id'] ?? sale['order_id'] ?? 0,
                                  'customer_name':
                                      sale['customer']?['name'] ??
                                      'Cliente não informado',
                                  'items': itens,
                                };

                                carregamentoVm.adicionarPedido(pedidoCompleto);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Pedido #${sale['id']} adicionado ao carregamento!",
                                    ),
                                    backgroundColor: const Color(0xFF0D3F87),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                sale['payment_status'] == 'Pago'
                                    ? Icons.check_circle
                                    : Icons.attach_money,
                                color: sale['payment_status'] == 'Pago'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              tooltip: sale['payment_status'] == 'Pago'
                                  ? 'Venda paga'
                                  : 'Marcar como paga',
                              onPressed: sale['payment_status'] == 'Pago'
                                  ? null
                                  : () async {
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          title: const Text(
                                            'Confirmar pagamento',
                                            style: TextStyle(
                                              color: Color(0xFF0D3F87),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: const Text(
                                            'Deseja marcar esta venda como paga?',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF0D3F87,
                                                ),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Confirmar',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmar == true) {
                                        await vm.markAsPaid(sale['id']);
                                      }
                                    },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Color(0xFF0D3F87),
                              ),
                              onPressed: () async {
                                try {
                                  final items = await vm.getSaleItems(
                                    sale['id'],
                                  );
                                  final data = PdfReceiptData(
                                    sale: sale,
                                    company: sale['company'] ?? {},
                                    customer: sale['customer'],
                                    items: items,
                                  );
                                  final pdfFile =
                                      await PdfService.generateReceipt(data);
                                  if (!mounted) return;
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.visibility),
                                          title: const Text('Visualizar'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            OpenFilex.open(pdfFile.path);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.share),
                                          title: const Text('Compartilhar'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Share.shareXFiles([
                                              XFile(pdfFile.path),
                                            ]);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                          ],
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
