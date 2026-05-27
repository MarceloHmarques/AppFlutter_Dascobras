class UserModel {
  final String id;
  String name;
  final String _cpf;
  String _password;
  DateTime date;

  UserModel({
    required this.id,
    required this.name,
    required this.date,
    required String cpf,
    required String password,
  }) : _cpf = cpf,
       _password = password;

  String get cpf => _cpf;

  String get password => _password;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
      password: json['password'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cpf': cpf,
    'password': password,
    'date': date,
  };
}
