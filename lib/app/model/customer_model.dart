import 'package:intl/intl.dart';

class CustomerModel {
  final int id;
  final String name;
  final String? tradeName;
  final int? routeId;       // 🔢 Mantém o ID numérico para o banco
  final String? routeName;  // 📝 Mantém o Nome em texto para a interface
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
    this.tradeName,
    this.routeId,
    this.routeName,
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
    String formattedBirthDate = '';

    if (map['birth_date'] != null && map['birth_date'].toString().isNotEmpty) {
      formattedBirthDate = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.parse(map['birth_date']));
    }

    String? nameOfRoute;
    if (map['route'] != null && map['route'] is Map) {
      nameOfRoute = map['route']['name']?.toString();
    } else if (map['route_name'] != null) {
      nameOfRoute = map['route_name']?.toString();
    }

    return CustomerModel(
      id: map['id'],
      name: map['name'] ?? '',
      tradeName: map['trade_name']?.toString(),
      routeId: map['route_id'] != null ? int.tryParse(map['route_id'].toString()) : null,
      routeName: nameOfRoute,
      birthDate: formattedBirthDate,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'trade_name': tradeName,
      'route_id': routeId,
      'birth_date': birthDate,
      'phone': phone,
      'email': email,
      'customer_type': customerType,
      'cpforcnpj': cpforcnpj,
      'state_': state,
      'city': city,
      'neighborhood': neighborhood,
      'cep': cep,
      'house_number': houseNumber,
      'address': address,
    };
  }
}