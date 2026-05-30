class UserModel {
  final String id;
  String _email;
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
    required String email,
  }) : _cpf = cpf,
       _password = password,
       _email = email;

  String get cpf => _cpf;

  String get password => _password;

  String get email => _email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
      password: json['password'],
      date: json['date'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cpf': cpf,
    'password': password,
    'date': date,
    'email': email,
  };
}
