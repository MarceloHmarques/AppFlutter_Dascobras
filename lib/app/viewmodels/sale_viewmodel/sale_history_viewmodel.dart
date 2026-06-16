import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleHistoryViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];

  String _searchText = '';

  Future<void> loadSales() async {
    try {
      final response = await supabase
          .from('sale')
          .select('''
            *,
            customer (
              id,
              name,
              cpforcnpj,
              city,
              state_
            )
          ''')
          .order('id', ascending: false);

      sales = List<Map<String, dynamic>>.from(response);
      filteredSales = List.from(sales);

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchCustomer(String value) {
    _searchText = value;
    _applyFilters();
  }

  void filterToday() {
    final today = DateTime.now();

    print("Hoje: $today");

    filteredSales = sales.where((sale) {
      final date = DateTime.parse(sale['sale_date']);

      print("Venda ${sale['id']}: $date");

      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

    print("Encontradas: ${filteredSales.length}");

    notifyListeners();
  }

  void filterLast7Days() {
    final start = DateTime.now().subtract(const Duration(days: 7));

    filteredSales = sales.where((sale) {
      final date = DateTime.parse(sale['sale_date']);
      return date.isAfter(start);
    }).toList();

    notifyListeners();
  }

  void filterLast30Days() {
    final start = DateTime.now().subtract(const Duration(days: 30));

    filteredSales = sales.where((sale) {
      final date = DateTime.parse(sale['sale_date']);
      return date.isAfter(start);
    }).toList();

    notifyListeners();
  }

  void filterByDate(DateTime? start, DateTime? end) {
    filteredSales = sales.where((sale) {
      final date = DateTime.parse(sale['sale_date']);

      if (start != null && date.isBefore(start)) {
        return false;
      }

      if (end != null && date.isAfter(end.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    filteredSales = List.from(sales);

    if (_searchText.isNotEmpty) {
      searchCustomer(_searchText);
    } else {
      notifyListeners();
    }
  }

  void _applyFilters() {
    if (_searchText.trim().isEmpty) {
      filteredSales = List.from(sales);
    } else {
      filteredSales = sales.where((sale) {
        final customer = sale['customer']['name'].toString().toLowerCase();

        return customer.contains(_searchText.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getSaleItems(int saleId) async {
    final response = await supabase
        .from('sale_item')
        .select()
        .eq('sale_id', saleId);

    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      response,
    );

    for (var item in items) {
      final product = await supabase
          .from('product')
          .select('name')
          .eq('id', item['product_id'])
          .single();

      item['product_name'] = product['name'];
    }

    return items;
  }
}
