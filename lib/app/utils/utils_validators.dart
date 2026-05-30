import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class UtilsValidators {
  static String? name(String? value) {
    if ((value == null) || (value.isEmpty)) return 'Nome obrigatório';

    if ((value.trim().isEmpty) ||
        (value.length < 3) ||
        (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(value))) {
      return 'Nome inválido';
    }
    return null;
  }

  static bool utilsCpf(String value) {
    value = value.replaceAll(RegExp(r'[.\-]'), '');

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

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Digite sua senha';

    if (value.length < 8) return 'Senha muito curta';

    if (!RegExp('[A-Z]').hasMatch(value) ||
        (!RegExp('[a-z]').hasMatch(value)) ||
        (!RegExp('[@#*+.]').hasMatch(value))) {
      return 'Obrigatório pelo menos:\nUma letra Maiúscula;\nUma minuscula;\nUm caracter especial(ex: @ ,# ,* ,+ .);';
    }

    return null;
  }

  final cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  static String? Birth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Selecione uma data';
    }

    final birthStripe = value.split('/');

    final dateBirth = DateTime(
      int.parse(birthStripe[2]),
      int.parse(birthStripe[1]),
      int.parse(birthStripe[0]),
    );

    final today = DateTime.now();

    int ade = today.year - dateBirth.year;

    if (today.month < dateBirth.month ||
        today.month == dateBirth.month && today.day > dateBirth.day) {
      ade--;
    }

    if (ade < 18) {
      return 'Você deve ter pelo menos 18 anos';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Obrigatório';
    }

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }
}
