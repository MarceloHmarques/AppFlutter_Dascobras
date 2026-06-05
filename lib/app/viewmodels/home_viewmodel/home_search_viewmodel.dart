import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/model/product_search_model.dart';

class HomeSearchViewmodel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<ProductSearchModel> products = [];
  List<ProductSearchModel> filteredProducts = [];

  Future<void> loadProduct() async {
    try {
      final response = await supabase.from('product').select('''
      *,
      category!product_category_id_fkey (
        id,
        name
      )
    ''');

      print('====================================');
      print('RESPOSTA COMPLETA');
      print(response);

      print('====================================');
      print('PRIMEIRO ITEM');
      print(response.first);

      print('====================================');
      print('CHAVES DO PRIMEIRO ITEM');
      print(response.first.keys);

      print('====================================');
      print('CAMPO CATEGORY');
      print(response.first['category']);

      products = response.map((e) {
        print('====================================');
        print('MAP INDIVIDUAL');
        print(e);

        return ProductSearchModel.fromMap(e);
      }).toList();

      for (var p in products) {
        print('====================================');
        print('Produto: ${p.name}');
        print('Categoria: ${p.category}');
      }

      filteredProducts = List.from(products);

      notifyListeners();
    } catch (e) {
      print('====================================');
      print('ERRO AO CARREGAR');
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
    } catch (e) {
      print('Erro na busca: $e');
    }

    notifyListeners();
  }
}
