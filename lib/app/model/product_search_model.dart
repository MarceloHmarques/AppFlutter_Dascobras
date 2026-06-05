class ProductSearchModel {
  final String name;
  final String imageurl;
  final double price;
  final int stock;
  final String category;

  ProductSearchModel({
    required this.name,
    required this.imageurl,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory ProductSearchModel.fromMap(Map<String, dynamic> map) {
    print('FROM MAP');
    print(map);

    return ProductSearchModel(
      name: map['name'] ?? '',
      imageurl: map['imageurl'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: map['stock'] ?? 0,
      category: map['category']?['name'] ?? 'Sem categoria',
    );
  }
}
