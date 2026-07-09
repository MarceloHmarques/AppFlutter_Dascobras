import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';
import 'package:intl/intl.dart';

class CommissionReportViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  Map<String, List<Map<String, dynamic>>> groupedSales = {};
  bool isLoading = false;

 Future<void> loadWeeklyReport() async {
    isLoading = true;
    notifyListeners();

    final companyId = await AuthSessionService().getCompanyId();
    final userId = supabase.auth.currentUser?.id;
    final role = await AuthSessionService().getRole();

    // 1. DECLARE A QUERY PRIMEIRO
    var query = supabase
        .from('sale')
        .select('id, total, total_commission, sale_date')
        .eq('company_id', companyId);

    // 2. AGORA VOCÊ PODE MODIFICAR A QUERY USANDO O IF
    if (role.trim().toUpperCase() == 'SELLER') {
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
    }

    // 3. AGORA VOCÊ PODE EXECUTAR A QUERY
    final response = await query.order('sale_date', ascending: false);
    final List<Map<String, dynamic>> sales = List<Map<String, dynamic>>.from(response);

    // Agrupamento por semana
    groupedSales = {};
    for (var sale in sales) {
      DateTime date = DateTime.parse(sale['sale_date']);
      // Formata para identificar a semana (ex: "Semana 42 - 2026")
      String weekKey = "Semana ${DateFormat("w/yyyy").format(date)}";
      
      if (!groupedSales.containsKey(weekKey)) {
        groupedSales[weekKey] = [];
      }
      groupedSales[weekKey]!.add(sale);
    }

    isLoading = false;
    notifyListeners();
  }

  double getTotalForWeek(String weekKey) {
    return groupedSales[weekKey]!.fold(0.0, (sum, item) => sum + (item['total_commission'] as num).toDouble());
  }
}