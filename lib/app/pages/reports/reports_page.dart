import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/reports_viewmodel/reports_viewmodel.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String selectedFilter = 'Hoje';

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      selectedFilter = 'Hoje';
      context.read<ReportsViewModel>().loadToday();
    });
  }

  Future<void> _selectCustomPeriod(BuildContext context) async {
    final vm = context.read<ReportsViewModel>();

    final start = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (start == null) return;

    final end = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: start,
      lastDate: DateTime.now(),
    );

    if (end == null) return;

    await vm.loadByPeriod(
      start,
      DateTime(end.year, end.month, end.day, 23, 59, 59),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
      ),

      body: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _filterButton('Hoje', () {
                      setState(() => selectedFilter = 'Hoje');
                      vm.loadToday();
                    }),
                    _filterButton('Semana', () {
                      setState(() => selectedFilter = 'Semana');
                      vm.loadWeek();
                    }),
                    _filterButton('Mês', () {
                      setState(() => selectedFilter = 'Mês');
                      vm.loadMonth();
                    }),
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _selectCustomPeriod(context),
                    icon: const Icon(Icons.date_range),
                    label: const Text('Filtrar por período'),
                  ),
                ),

                const SizedBox(height: 20),

                _reportCard(
                  title: 'Total vendido',
                  value: vm.totalSales,
                  icon: Icons.attach_money,
                ),

                _smallInfoCard(
                  title: 'Quantidade de vendas',
                  value: vm.salesCount.toString(),
                  icon: Icons.shopping_cart_outlined,
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vendas por dia',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 15),

                _salesChart(vm),

                const SizedBox(height: 25),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Produtos mais vendidos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                if (vm.topProducts.isEmpty)
                  const Text('Nenhum produto vendido nesse período')
                else
                  ...vm.topProducts.map((product) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF0D3F87),
                        ),
                        title: Text(product['name']),
                        trailing: Text(
                          '${product['quantity']} vendidos',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterButton(String text, VoidCallback onTap) {
    final isSelected = selectedFilter == text;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Colors.white
                : const Color(0xFF0D3F87),
            foregroundColor: isSelected
                ? const Color(0xFF0D3F87)
                : Colors.white,
            side: const BorderSide(color: Color(0xFF0D3F87)),
          ),
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }

  Widget _salesChart(ReportsViewModel vm) {
    if (vm.salesByDay.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0D3F87)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('Sem vendas para exibir no gráfico'),
      );
    }

    final spots = vm.salesByDay.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), (entry.value['total'] as double));
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= vm.salesByDay.length) {
                    return const SizedBox();
                  }

                  return Text(
                    vm.salesByDay[index]['date'],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required double value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF0D3F87)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 5),
                Text(
                  'R\$ ${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D3F87)),
          const SizedBox(width: 15),
          Text(title),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
