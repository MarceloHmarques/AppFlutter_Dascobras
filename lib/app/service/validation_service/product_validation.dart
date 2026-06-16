class ProductValidation {
  static String? name(String? value) {
    if ((value == null) || (value.isEmpty)) return 'Nome obrigatório';

    if ((value.trim().isEmpty) ||
        (value.length < 3) ||
        (!RegExp(r'^[0-9A-Za-zÀ-ÿ\s().-]+$').hasMatch(value))) {
      return 'Nome inválido';
    }
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantidade obrigatória';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Quantidade deve conter apenas números';
    }

    final stock = int.tryParse(value);

    if (stock == null || stock < 0) {
      return 'Quantidade inválida';
    }

    if (stock > 99999) {
      return 'Quantidade máxima: 99999';
    }

    return null;
  }

  static String? price(String? value) {
    if (value == null || value.isEmpty) {
      return 'Preço obrigatório';
    }

    final price = double.tryParse(
      value.replaceAll('.', '').replaceAll(',', '.'),
    );

    if (price == null) {
      return 'Preço inválido';
    }

    if (price <= 0) {
      return 'Preço deve ser maior que zero';
    }

    return null;
  }
}
