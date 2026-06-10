class ProductSearchModel {
  final int id;
  final String name;
  final String imageurl;
  final double price;
  int stock;
  final int categoryId;
  final String category;

  ProductSearchModel({
    required this.id,
    required this.name,
    required this.imageurl,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.category,
  });

  factory ProductSearchModel.fromMap(Map<String, dynamic> map) {
    print("----------------");
    print(map);
    print(map["category"]);

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
    );
  }
}
