class SaleItemModel {
  final int id;
  final int saleId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItemModel({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}
