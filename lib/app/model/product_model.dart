class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int stock;
  final double price;
  final String category;
  final String brand;    
  final String unitType; 

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.stock,
    required this.price,
    required this.category,
    required this.brand,    
    required this.unitType, 
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
      brand: json['brand'] ?? 'Sem Marca', 
      unitType: json['unit_type'] ?? 'UN', 
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'stock': stock,
    'price': price,
    'category': category,
    'brand': brand,       
    'unit_type': unitType, 
  };
}