import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/model/product_search_model.dart';

class HomeSearchViewmodel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<ProductSearchModel> products = [];
  List<ProductSearchModel> filteredProducts = [];
  List<String> categories = ['Todos'];

  bool loading = false;

  String selectedCategory = 'Todos';
  String selectedOrder = '';

  void applyFilters() {
    var result = List<ProductSearchModel>.from(products);

    if (selectedCategory != 'Todos') {
      result = result.where((product) {
        return product.category.toLowerCase() == selectedCategory.toLowerCase();
      }).toList();
    }

    if (selectedOrder == 'A-Z') {
      result.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedOrder == 'Z-A') {
      result.sort((a, b) => b.name.compareTo(a.name));
    } else if (selectedOrder == 'Maior preço') {
      result.sort((a, b) => b.price.compareTo(a.price));
    } else if (selectedOrder == 'Menor preço') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedOrder == 'Mais relevantes') {
      result.sort((a, b) {
        if (a.stock == 0 && b.stock > 0) return 1;
        if (a.stock > 0 && b.stock == 0) return -1;
        return a.name.compareTo(b.name);
      });
    }

    filteredProducts = result;
    notifyListeners();
  }

  void filterByCategory(String category) {
    selectedCategory = category;
    applyFilters();
  }

  void orderProducts(String order) {
    selectedOrder = order;
    applyFilters();
  }

  Future<void> loadProduct({bool force = false}) async {
    if (products.isNotEmpty && !force) return;

    try {
      final response = await supabase
          .from('product')
          .select('''
          *,
          category:category_id (
            id,
            name
          )
        ''')
          .eq('is_active', true);

      products = response.map((e) => ProductSearchModel.fromMap(e)).toList();

      categories = [
        'Todos',
        ...products
            .map((product) => product.category.trim())
            .where((category) => category.isNotEmpty)
            .where((category) => category != 'Sem categoria')
            .toSet()
            .toList(),
      ];

      applyFilters(); 

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> searchProduct({required String value}) async {
    try {
      if (value.trim().isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(value.toLowerCase());
        }).toList();
      }

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String imageurl,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    try {
      await supabase
          .from('product')
          .update({
            'name': name,
            'imageurl': imageurl,
            'price': price,
            'stock': stock,
            'category_id': categoryId,
          })
          .eq('id', id);

      await loadProduct(force: true);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('product').update({'is_active': false}).eq('id', id);

    await loadProduct(force: true);
  }

  Future<void> addProduct({
    required String name,
    required String imageurl,
    required double price,
    required int stock,
    required int categoryId,
    required String brand,    
    required String unitType, 
    required double commissionValue,
  }) async {
    await supabase.from('product').insert({
      'name': name,
      'imageurl': imageurl,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'brand': brand,         
      'unit_type': unitType,   
      'commission_value': commissionValue,
    });

    await loadProduct(force: true);
  }

  Future<void> refreshProducts() async {
    products.clear();
    filteredProducts.clear();

    await loadProduct(force: true);
  }

  Future<void> loadCategories() async {
    try {
      final response = await supabase.from('product').select('category');

      final uniqueCategories = response
          .map((e) => e['category'].toString())
          .toSet()
          .toList();

      categories = ['Todos', ...uniqueCategories];

      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadInitialData() async {
    await loadProduct();
    await loadCategories();
  }
}