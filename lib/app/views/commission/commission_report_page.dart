import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Ajuste o import abaixo se o caminho da pasta for diferente no seu projeto
import '../../viewmodels/commission_viewmodel/commission_report_viewmodel.dart';

class CommissionReportPage extends StatelessWidget { // ou StatefulWidget
  const CommissionReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório Semanal"),
      ),
      body: Consumer<CommissionReportViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (vm.groupedSales.isEmpty) {
            return const Center(child: Text("Nenhuma comissão encontrada."));
          }

          return ListView.builder(
            itemCount: vm.groupedSales.keys.length,
            itemBuilder: (context, index) {
              String week = vm.groupedSales.keys.elementAt(index);
              double total = vm.getTotalForWeek(week);

              return ExpansionTile(
                title: Text(week, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Total da semana: R\$ ${total.toStringAsFixed(2)}"),
                children: vm.groupedSales[week]!.map((sale) => ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: Text("Pedido #${sale['id']}"),
                  trailing: Text("R\$ ${sale['total_commission']}"),
                  onTap: () {
                    // Aqui você pode adicionar a lógica para abrir o detalhe do pedido se quiser
                  },
                )).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<CommissionReportViewModel>(context, listen: false).loadWeeklyReport();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}