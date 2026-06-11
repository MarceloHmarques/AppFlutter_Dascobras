import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool loading = false;

  double totalSales = 0;
  int salesCount = 0;

  List<Map<String, dynamic>> salesByDay = [];
  List<Map<String, dynamic>> topProducts = [];

  DateTime? startDate;
  DateTime? endDate;

  Future<void> loadToday() async {
    final now = DateTime.now();

    await loadByPeriod(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> loadWeek() async {
    final now = DateTime.now();

    final start = now.subtract(Duration(days: now.weekday - 1));

    await loadByPeriod(
      DateTime(start.year, start.month, start.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  Future<void> loadMonth() async {
    final now = DateTime.now();

    await loadByPeriod(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  Future<void> loadByPeriod(DateTime start, DateTime end) async {
    loading = true;
    notifyListeners();

    try {
      startDate = start;
      endDate = end;

      await _loadSales(start, end);
      await _loadTopProducts(start, end);
    } catch (e) {
      print('Erro ao carregar relatórios: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _loadSales(DateTime start, DateTime end) async {
    final response = await supabase
        .from('sale')
        .select('id, total, sale_date')
        .gte('sale_date', start.toIso8601String())
        .lte('sale_date', end.toIso8601String());

    totalSales = 0;
    salesCount = response.length;

    final Map<String, double> grouped = {};

    for (final sale in response) {
      final total = (sale['total'] as num?)?.toDouble() ?? 0;
      final date = DateTime.parse(sale['sale_date']);

      totalSales += total;

      final key = '${date.day}/${date.month}';

      grouped[key] = (grouped[key] ?? 0) + total;
    }

    salesByDay = grouped.entries.map((e) {
      return {'date': e.key, 'total': e.value};
    }).toList();
  }

  Future<void> _loadTopProducts(DateTime start, DateTime end) async {
    final response = await supabase
        .from('sale_item')
        .select('''
          quantity,
          subtotal,
          sale!inner (
            sale_date
          ),
          product (
            name
          )
        ''')
        .gte('sale.sale_date', start.toIso8601String())
        .lte('sale.sale_date', end.toIso8601String());

    final Map<String, int> grouped = {};

    for (final item in response) {
      final name = item['product']?['name'] ?? 'Produto';
      final quantity = item['quantity'] ?? 0;

      grouped[name] = (grouped[name] ?? 0) + (quantity as int);
    }

    topProducts = grouped.entries.map((e) {
      return {'name': e.key, 'quantity': e.value};
    }).toList();

    topProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));

    topProducts = topProducts.take(5).toList();
  }
}
