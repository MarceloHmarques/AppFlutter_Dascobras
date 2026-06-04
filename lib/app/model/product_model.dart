class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int stock;
  final double price;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.stock,
    required this.price,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      stock: json['stock'],
      price: json['price'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'stock': stock,
    'price': price,
    'category': category,
  };
}
