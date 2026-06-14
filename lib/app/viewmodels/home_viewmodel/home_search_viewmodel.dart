import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/model/product_search_model.dart';

class HomeSearchViewmodel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<ProductSearchModel> products = [];
  List<ProductSearchModel> filteredProducts = [];
  List<String> categories = ['Todos'];

  bool loading = false;

  Future<void> loadProduct({bool force = false}) async {
    if (products.isNotEmpty && !force) return;

    try {
      final response = await supabase.from('product').select('''
      *,
      category:category_id (
        id,
        name
      )
    ''');

      print(response);

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

      filteredProducts = List.from(products);

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
      print("ERRO NA BUSCA");
      print(e);
    }
  }

  Future<void> filterByCategory(String category) async {
    if (category == 'Todos') {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products.where((product) {
        return product.category == category;
      }).toList();
    }

    notifyListeners();
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
      print("========== UPDATE ==========");

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

      await loadProduct();
    } catch (e) {
      print("ERRO AO ATUALIZAR");
      print(e);
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('product').delete().eq('id', id);

    await loadProduct();
  }

  Future<void> addProduct({
    required String name,
    required String imageurl,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    await supabase.from('product').insert({
      'name': name,
      'imageurl': imageurl,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
    });

    await loadProduct();
  }

  Future<void> refreshProducts() async {
    await loadProduct();
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
