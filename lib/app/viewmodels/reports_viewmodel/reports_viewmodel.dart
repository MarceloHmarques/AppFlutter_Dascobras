import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final authSession = AuthSessionService();

  bool loading = false;

  double totalSales = 0;
  int salesCount = 0;

  List<Map<String, dynamic>> salesByDay = [];
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> lowStockProducts = [];

  DateTime? startDate;
  DateTime? endDate;

  Future<String> _getCompanyId() async {
    return await authSession.getCompanyId();
  }

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
      await loadLowStockProducts();
    } catch (e) {
      debugPrint('Erro ao carregar relatórios: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _loadSales(DateTime start, DateTime end) async {
    final companyId = await _getCompanyId();

    final response = await supabase
        .from('sale')
        .select('id, total, sale_date')
        .eq('company_id', companyId)
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
    final companyId = await _getCompanyId();

    final response = await supabase
        .from('sale_item')
        .select('''
          quantity,
          subtotal,
          sale!inner (
            sale_date,
            company_id
          ),
          product (
            name
          )
        ''')
        .eq('sale.company_id', companyId)
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

  Future<void> loadLowStockProducts() async {
    final companyId = await _getCompanyId();

    final response = await supabase
        .from('product')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .lte('stock', 5);

    lowStockProducts = List<Map<String, dynamic>>.from(response);

    notifyListeners();
  }

  List<Map<String, dynamic>> pendingSales = [];

  Future<void> loadPendingSales() async {
    final companyId = await authSession.getCompanyId();

    final response = await supabase
        .from('sale')
        .select('''
        *,
        customer:customer_id(*),
        company:company_id(*)
      ''')
        .eq('company_id', companyId)
        .eq('payment_status', 'Pendente')
        .order('id', ascending: false);

    pendingSales = List<Map<String, dynamic>>.from(response);

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final response = await supabase
        .from('sale_item')
        .select('''
        *,
        product:product_id (
          id,
          name,
          brand,
          unit_type
        )
      ''')
        .eq('sale_id', saleId);

    return List<Map<String, dynamic>>.from(response);
  }
}
