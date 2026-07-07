import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class SaleHistoryViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];

  String _searchText = '';

  Future<void> loadSales() async {
    try {
      final companyId = await AuthSessionService().getCompanyId();

      final response = await supabase
          .from('sale')
          .select('''
      *,
      customer:customer_id (
        id,
        name,
        trade_name,
        cpforcnpj,
        phone,
        state_,
        city,
        neighborhood,
        cep,
        house_number,
        address
      ),
      company:company_id (
        id,
        name,
        cnpj_or_cpf,
        phone,
        email,
        state_,
        city,
        neighborhood,
        cep,
        house_number,
        address
      )
    ''')
          .eq('company_id', companyId)
          .order('sale_date', ascending: false);

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

    final items = List<Map<String, dynamic>>.from(response);

    for (var item in items) {
      item['product_name'] = item['product']?['name'] ?? 'Produto';
    }

    return items;
  }
}
