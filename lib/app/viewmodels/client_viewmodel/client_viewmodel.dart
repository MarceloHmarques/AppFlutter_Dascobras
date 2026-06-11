import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../model/customer_model.dart';

class ClientViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomers = [];

  Future<void> loadCustomers() async {
    try {
      final response = await supabase.from('customer').select();

      customers = response
          .map<CustomerModel>((e) => CustomerModel.fromMap(e))
          .toList();

      filteredCustomers = List.from(customers);

      notifyListeners();
    } catch (e) {
      print('ERRO AO CARREGAR CLIENTES');
      print(e);
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
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parse(birthDate));

      await supabase.from('customer').insert({
        'name': name,
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

  Future<void> deleteCustomer(int id) async {
    try {
      await supabase.from('customer').delete().eq('id', id);

      await loadCustomers();

      print('CLIENTE REMOVIDO COM SUCESSO');
    } catch (e) {
      print('ERRO AO REMOVER CLIENTE');
      print(e);
      rethrow;
    }
  }

  Future<void> updateCustomer({
    required int id,
    required String name,
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
    String formattedDate = birthDate;

    if (birthDate.contains('/')) {
      formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateFormat('dd/MM/yyyy').parse(birthDate));
    }

    await supabase
        .from('customer')
        .update({
          'name': name,
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
        .eq('id', id);

    await loadCustomers();
  }
}
