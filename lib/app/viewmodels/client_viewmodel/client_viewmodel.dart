import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';
import '../../model/customer_model.dart';

class ClientViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final authSession = AuthSessionService();
  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomers = [];

  Future<String> _getCompanyId() async {
    return await authSession.getCompanyId();
  }

  Future<void> loadCustomers() async {
    try {
      final companyId = await _getCompanyId();

      final response = await supabase
          .from('customer')
          .select()
          .eq('is_active', true)
          .eq('company_id', companyId)
          .order('name');

      customers = response
          .map<CustomerModel>((e) => CustomerModel.fromMap(e))
          .toList();

      filteredCustomers = List.from(customers);

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void searchCustomer(String value) {
    if (value.trim().isEmpty) {
      filteredCustomers = List.from(customers);
    } else {
      filteredCustomers = customers.where((customer) {
        return customer.name.toLowerCase().contains(value.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  Future<void> addCustomer({
    required String name,
    String? tradeName, 
    String? routeId,   
    required String birthDate,
    required String phone,
    required String email,
    required String customerType,
    required String cpfOrCnpj,
    required String state,
    required String city,
    required String neighborhood,
    required String cep,
    required String houseNumber,
    required String address,
  }) async {
    try {
      String? formattedDate;
      if (birthDate.trim().isNotEmpty) {
        formattedDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateFormat('dd/MM/yyyy').parse(birthDate));
      }

      final companyId = await _getCompanyId();
      await supabase.from('customer').insert({
        'company_id': companyId, 
        'name': name,
        'trade_name': tradeName, 
        'route_id': routeId,     
        'birth_date': formattedDate,
        'phone': phone,
        'email': email,
        'customer_type': customerType,
        'cpforcnpj': cpfOrCnpj,
        'state_': state,
        'city': city,
        'neighborhood': neighborhood,
        'cep': cep,
        'house_number': houseNumber,
        'address': address,
      });

      await loadCustomers();
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Cliente já cadastrado.');
      }
      throw Exception(e.message);
    }
  }

  Future<void> deleteCustomer(String id) async { // 🛠️ Mudado int para String para casar com o Model
    try {
      final companyId = await _getCompanyId();

      await supabase
          .from('customer')
          .update({'is_active': false})
          .eq('id', id)
          .eq('company_id', companyId);

      await loadCustomers();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateCustomer({
    required String id, // 🛠️ Mudado int para String para casar com o Model
    required String name,
    String? tradeName, // 🛠️ Adicionado opcional
    String? routeId,   // 🛠️ Adicionado opcional
    required String birthDate,
    required String phone,
    required String email,
    required String customerType,
    required String cpfOrCnpj,
    required String state,
    required String city,
    required String neighborhood,
    required String cep,
    required String houseNumber,
    required String address,
  }) async {
    String? formattedDate = birthDate.trim().isEmpty ? null : birthDate;

    if (birthDate.contains('/')) {
      formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parse(birthDate));
    }

    final companyId = await _getCompanyId();

    await supabase
        .from('customer')
        .update({
          'name': name,
          'trade_name': tradeName, // 🛠️ Atualização da coluna ativa
          'route_id': routeId,     // 🛠️ Atualização da coluna ativa
          'birth_date': formattedDate,
          'phone': phone,
          'email': email,
          'customer_type': customerType,
          'cpforcnpj': cpfOrCnpj,
          'state_': state,
          'city': city,
          'neighborhood': neighborhood,
          'cep': cep,
          'house_number': houseNumber,
          'address': address,
        })
        .eq('id', id)
        .eq('company_id', companyId);

    await loadCustomers();
  }
}