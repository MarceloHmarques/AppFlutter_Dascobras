class ProductValidation {
  static String? name(String? value) {
    if ((value == null) || (value.isEmpty)) return 'Nome obrigatório';

    if ((value.trim().isEmpty) ||
        (value.length < 3) ||
        (!RegExp(r'^[0-9A-Za-zÀ-ÿ-.\s]+$').hasMatch(value))) {
      return 'Nome inválido';
    }
    return null;
  }

  static String? stock(value) {
    if (value == null || value.isEmpty) return 'Quantidade obrigatória';

    if (RegExp(r'^[0-9]').hasMatch(value) || value.length > 5) {
      return 'Quantidade inválida';
    }
    return null;
  }

  static String? price(value) {
    if (value == null || value.isEmpty) return 'Preço obrigatório';

    if (RegExp(r'^R?\$?\s?\d+(,\d{2})?$').hasMatch(value) || value.length > 5) {
      return 'Quantidade inválida';
    }

    return null;
  }
}
