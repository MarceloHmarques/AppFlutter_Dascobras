class PersonalDataValidation {
  static String? number(value) {
    if (value == null || value.isEmpty) return 'Telefone obrigatório';

    if (value.length != 15) return 'Telefone inválido';

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email Obrigatório';

    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

    if (!emailRegex.hasMatch(value)) return 'Email inválido';

    return null;
  }

  static String? name(String? value) {
    if ((value == null) || (value.isEmpty)) return 'Nome obrigatório';

    if ((value.trim().isEmpty) ||
        (value.length < 3) ||
        (!RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(value))) {
      return 'Nome inválido';
    }
    return null;
  }

  static String? birth(String? value) {
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

    if (ade < 18) return 'Você deve ter pelo menos 18 anos';

    return null;
  }
}
