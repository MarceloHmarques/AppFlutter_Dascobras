import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class SaleHistoryViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];
  List<Map<String, dynamic>> rotasDisponiveis = [];

  // Variáveis de controle de filtros
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
      final currentUserId = supabase.auth.currentUser?.id;
      final rawRole = await AuthSessionService().getRole();
      final userRole = rawRole.trim().toUpperCase();

      // 🔍 PRINTS DE CONTROL: Veja no console se o papel está vindo certo!
      debugPrint('====================================');
      debugPrint('DEBUG HISTÓRICO: USUÁRIO ID = $currentUserId');
      debugPrint('DEBUG HISTÓRICO: CARGO LOGADO = $userRole');
      debugPrint('====================================');

      // 1. Busca as vendas normais da empresa
      var query = supabase
          .from('sale')
          .select('''
            *,
            customer:customer_id (
              id, name, trade_name, cpforcnpj, phone, state_, city, neighborhood, cep, house_number, address, route_id
            ),
            company:company_id (
              id, name, cnpj_or_cpf, phone, email, state_, city, neighborhood, cep, house_number, address
            )
          ''')
          .eq('company_id', companyId);

      if (userRole == 'SELLER' && currentUserId != null) {
        query = query.eq('user_id', currentUserId);
      }

      final response = await query.order('sale_date', ascending: false);
      final rawSales = List<Map<String, dynamic>>.from(response);

      // 2. Busca os nomes e IDs dos usuários na tabela company_user
      final usersResponse = await supabase
          .from('company_user')
          .select('user_id, name')
          .eq('company_id', companyId);

      final usersList = List<Map<String, dynamic>>.from(usersResponse);

      final userMap = {
        for (var u in usersList)
          u['user_id'].toString(): u['name'] ?? 'Não informado',
      };

      for (var sale in rawSales) {
        final sellerId = sale['user_id']?.toString();
        sale['vendedor'] = {'name': userMap[sellerId] ?? 'Não informado'};
      }

      sales = rawSales;
      filteredSales = List.from(sales);

      _applyFilters();
    } catch (e) {
      debugPrint("Erro ao carregar vendas: ${e.toString()}");
    }
  }

  void searchCustomer(String value) {
    _searchText = value;
    _applyFilters();
  }

  Future<void> loadRotas() async {
    try {
      final response = await supabase
          .from('route')
          .select('id, name')
          .eq('is_active', true);
      rotasDisponiveis = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

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

  void _applyFilters() {
    List<Map<String, dynamic>> temporaryList = List.from(sales);

    // 1. Aplica o filtro de texto se houver (Nome OU Nome Fantasia)
    if (_searchText.trim().isNotEmpty) {
      temporaryList = temporaryList.where((sale) {
        if (sale['customer'] == null) return false;

        final customerName = (sale['customer']['name'] ?? '')
            .toString()
            .toLowerCase();
        final tradeName = (sale['customer']['trade_name'] ?? '')
            .toString()
            .toLowerCase();
        final query = _searchText.toLowerCase();

        return customerName.contains(query) || tradeName.contains(query);
      }).toList();
    }

    // 2. Aplica o filtro de rota se houver uma selecionada
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

  Future<void> markAsPaid(int saleId) async {
    await supabase
        .from('sale')
        .update({'payment_status': 'Pago'})
        .eq('id', saleId);

    await loadSales();
  }
}
