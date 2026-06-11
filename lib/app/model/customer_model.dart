import 'package:intl/intl.dart';

class CustomerModel {
  final int id;
  final String name;
  final String birthDate;
  final String phone;
  final String email;
  final String customerType;
  final String cpforcnpj;
  final String state;
  final String city;
  final String neighborhood;
  final String cep;
  final String houseNumber;
  final String address;

  CustomerModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.phone,
    required this.email,
    required this.customerType,
    required this.cpforcnpj,
    required this.state,
    required this.city,
    required this.neighborhood,
    required this.cep,
    required this.houseNumber,
    required this.address,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'] ?? '',
      birthDate: map['birth_date'] != null
          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(map['birth_date']))
          : '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      customerType: map['customer_type'] ?? 'PF',
      cpforcnpj: map['cpforcnpj'] ?? '',
      state: map['state_'] ?? '',
      city: map['city'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      cep: map['cep'] ?? '',
      houseNumber: map['house_number'] ?? '',
      address: map['address'] ?? '',
    );
  }
}
