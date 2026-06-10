class SaleModel {
  final int id;
  final int customerId;
  final double total;
  final String statusOrder;
  final String? paymentMethod;
  final String? saleDate;

  SaleModel({
    required this.id,
    required this.customerId,
    required this.total,
    required this.statusOrder,
    this.paymentMethod,
    this.saleDate,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      customerId: map['customer_id'],
      total: (map['total'] as num).toDouble(),
      statusOrder: map['status_order'],
      paymentMethod: map['payment_method'],
      saleDate: map['sale_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'total': total,
      'status_order': statusOrder,
      'payment_method': paymentMethod,
    };
  }
}
