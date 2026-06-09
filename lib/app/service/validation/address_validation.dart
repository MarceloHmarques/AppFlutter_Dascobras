class AddressValidation {
  static String? road(value) {
    if (value == null || value.trim().isEmpty) return 'Rua obrigatória';

    if (value.trim().length < 3) return 'Rua inválida';

    return null;
  }

  static String? city(value) {
    if (value == null || value.trim().isEmpty) return 'Cidade obrigatória';

    if (value.trim().length < 3) return 'Cidade inválida';

    return null;
  }

  static String? neighborhood(value) {
    if (value == null || value.trim().isEmpty) return 'Bairro obrigatório';

    if (value.trim().length < 2) return 'Bairro inválido';

    return null;
  }

  static String? cep(value) {
    //colocar o de ser diferente de numero
    if (value == null || value.isEmpty) return 'CEP obrigatório';

    if (value.length != 9) return 'CEP inválido';
    return null;
  }

  static String? numberHouse(value) {
    if (value == null || value.trim().isEmpty) return 'Número obrigatório';

    return null;
  }

  static String? state(value) {
    if (value == null || value.isEmpty) {
      return 'Selecione um estado';
    }
    return null;
  }

  static final List<String> states = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];
}
