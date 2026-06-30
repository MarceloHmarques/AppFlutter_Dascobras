class ProductSearchModel {
  final int id;
  final String name;
  final String imageurl;
  final double price;
  int stock;
  final int categoryId;
  final String category;
  final String brand;    
  final String unitType; 
  final double commissionValue; 

  ProductSearchModel({
    required this.id,
    required this.name,
    required this.imageurl,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.category,
    required this.brand,    
    required this.unitType, 
    required this.commissionValue, 
  });

  factory ProductSearchModel.fromMap(Map<String, dynamic> map) {
    return ProductSearchModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      imageurl: map['imageurl'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: map['stock'] ?? 0,
      categoryId: map['category_id'] ?? 0,
      category: map['category'] == null
          ? 'Sem categoria'
          : map['category']['name'].toString().trim(),
      brand: map['brand'] ?? 'Sem Marca', 
      unitType: map['unit_type'] ?? 'UN', 
      commissionValue: (map['commission_value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}