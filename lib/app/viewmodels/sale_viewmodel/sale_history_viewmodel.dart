import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class SaleHistoryViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];
  List<Map<String, dynamic>> rotasDisponiveis = [];
  
  // Guarda o ID da rota selecionada no filtro da tela
  int? selectedRouteId;
  String _searchText = '';

  Future<List<Map<String, dynamic>>> getItemsDaVenda(int saleId) async {
    final response = await supabase
        .from('sale_item')
        .select('product_id, quantity, product(name)')
        .eq('sale_id', saleId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> loadSales() async {
    try {
      final companyId = await AuthSessionService().getCompanyId();

      // AJUSTE: Incluído o route_id dentro do nó do customer para o filtro funcionar
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
        address,
        route_id
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

      // Toda vez que recarregar as vendas, roda os filtros para manter a tela atualizada
      _applyFilters();
    } catch (e) {
      debugPrint("Erro ao carregar vendas: ${e.toString()}");
    }
  }

  void searchCustomer(String value) {
    _searchText = value;
    _applyFilters();
  }

  // Carrega apenas as rotas válidas/ativas para o filtro
  Future<void> loadRotas() async {
    try {
      final response = await supabase
          .from('route')
          .select('id, name')
          .eq('is_active', true);
      rotasDisponiveis = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao carregar rotas: ${e.toString()}");
    }
  }

  // Modifica a rota selecionada e aplica as regras de filtragem combinadas
  void filterByRoute(int? routeId) {
    selectedRouteId = routeId;
    _applyFilters();
  }

  void filterToday() {
    final today = DateTime.now();

    filteredSales = sales.where((sale) {
      final date = DateTime.parse(sale['sale_date']);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).toList();

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
    selectedRouteId = null;
    _searchText = '';
    filteredSales = List.from(sales);
    notifyListeners();
  }

  // Centraliza a lógica unificando o filtro de busca por texto e o filtro por rota por completo
  void _applyFilters() {
    List<Map<String, dynamic>> temporaryList = List.from(sales);

    // 1. Aplica filtro de texto se houver
    if (_searchText.trim().isNotEmpty) {
      temporaryList = temporaryList.where((sale) {
        if (sale['customer'] == null || sale['customer']['name'] == null) return false;
        final customerName = sale['customer']['name'].toString().toLowerCase();
        return customerName.contains(_searchText.toLowerCase());
      }).toList();
    }

    // 2. Aplica filtro de rota se houver uma selecionada
    if (selectedRouteId != null) {
      temporaryList = temporaryList.where((sale) {
        return sale['customer'] != null && 
               sale['customer']['route_id'] == selectedRouteId;
      }).toList();
    }

    filteredSales = temporaryList;
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