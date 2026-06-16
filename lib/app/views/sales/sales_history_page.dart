import 'package:DasCobras/app/service/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../viewmodels/sale_viewmodel/sale_history_viewmodel.dart';

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
    });
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });

      context.read<SaleHistoryViewModel>().filterByDate(startDate, endDate);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0D3F87), // azul principal
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF0D3F87),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
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
                              'Data: ${DateTime.parse(sale['sale_date']).day.toString().padLeft(2, '0')}/'
                              '${DateTime.parse(sale['sale_date']).month.toString().padLeft(2, '0')}/'
                              '${DateTime.parse(sale['sale_date']).year}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
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
                              debugPrint(e.toString());

                              if (!mounted) return;

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
