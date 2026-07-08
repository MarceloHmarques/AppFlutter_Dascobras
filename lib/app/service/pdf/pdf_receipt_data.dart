class PdfReceiptData {
  final Map<String, dynamic> sale;
  final Map<String, dynamic> company;
  final Map<String, dynamic>? customer;
  final List<Map<String, dynamic>> items;

  PdfReceiptData({
    required this.sale,
    required this.company,
    required this.customer,
    required this.items,
  });

  String get orderId => sale['id']?.toString() ?? '';

  String get companyName => company['name'] ?? '';
  String get companyAddress => company['address'] ?? '';
  String get companyHouseNumber => company['house_number'] ?? '';
  String get companyNeighborhood => company['neighborhood'] ?? '';
  String get companyCity => company['city'] ?? '';
  String get companyState => company['state_'] ?? '';
  String get companyCep => company['cep'] ?? '';
  String get companyPhone => company['phone'] ?? '';
  String get companyCnpj => company['cnpj'] ?? company['cnpj_or_cpf'] ?? '';
  String get companyEmail => company['email'] ?? '';
  String get companyLogoUrl => company['image'] ?? '';

  String get customerName => customer?['name'] ?? '';
  String get customerTradeName => customer?['trade_name'] ?? '';
  String get customerDocument => customer?['cpforcnpj'] ?? '';
  String get customerAddress => customer?['address'] ?? '';
  String get customerNeighborhood => customer?['neighborhood'] ?? '';
  String get customerCity => customer?['city'] ?? '';
  String get customerState => customer?['state_'] ?? '';
  String get customerCep => customer?['cep'] ?? '';
  String get customerPhone => customer?['phone'] ?? '';

  double get total => (sale['total'] as num?)?.toDouble() ?? 0;

  String get saleDate {
    final rawDate = sale['sale_date'];

    if (rawDate == null) {
      final now = DateTime.now();

      return '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/'
          '${now.year}';
    }

    final date = DateTime.parse(rawDate.toString());

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String get sellerName {
    if (sale['vendedor'] != null) {
      if (sale['vendedor'] is Map) {
        return sale['vendedor']['name'] ?? 'Não informado';
      }
    }
    return 'Não informado';
  }
}
