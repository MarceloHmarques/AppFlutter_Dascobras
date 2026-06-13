class PersonalValidation {
  static bool utilsCpfCnpj(String value) {
    value = value.replaceAll(RegExp(r'[.\-/]'), '');
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 11) return utilsCpf(digits);
    if (digits.length == 14) return utilsCnpj(digits);

    return false;
  }

  static bool utilsCpf(String value) {
    value = value.replaceAll(RegExp(r'[.\-]'), '');
    value = value.replaceAll(RegExp(r'\D'), '');

    if (value.length != 11) return false;

    if (RegExp(r'^(\d)\1{10}$').hasMatch(value)) return false;

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(value[i]) * (10 - i);
    }
    int one = (sum * 10) % 11;
    if (one == 10 || one == 11) one = 0;
    if (one != int.parse(value[9])) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(value[i]) * (11 - i);
    }
    int two = (sum * 10) % 11;
    if (two == 10 || two == 11) two = 0;
    if (two != int.parse(value[10])) return false;

    return true;
  }

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) return 'CPF obrigatório';

    if (utilsCpf(value) == false) return 'CPF inválido';

    return null;
  }

  static bool utilsCnpj(String value) {
    value = value.replaceAll(RegExp(r'[.\-/]'), '');
    value = value.replaceAll(RegExp(r'\D'), '');

    if (value.length != 14) return false;

    if (RegExp(r'^(\d)\1{13}$').hasMatch(value)) return false;

    List<int> pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(value[i]) * pesos1[i];
    }
    int one = sum % 11;
    one = one < 2 ? 0 : 11 - one;
    if (one != int.parse(value[12])) return false;

    List<int> pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(value[i]) * pesos2[i];
    }
    int two = sum % 11;
    two = two < 2 ? 0 : 11 - two;
    if (two != int.parse(value[13])) return false;

    return true;
  }

  static String? passwordBasic(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';

    if (value.length < 8) return 'Senha muito curta';

    if (!RegExp('[A-Z]').hasMatch(value) ||
        (!RegExp('[a-z]').hasMatch(value)) ||
        (!RegExp('[@#*+.]').hasMatch(value))) {
      return 'Obrigatório pelo menos:\nUma letra Maiúscula;\nUma minuscula;\nUm caracter especial(ex: @ ,# ,* ,+ .);';
    }

    return null;
  }
}
