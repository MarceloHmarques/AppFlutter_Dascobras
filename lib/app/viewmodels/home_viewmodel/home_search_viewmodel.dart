import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:DasCobras/app/model/product_search_model.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class HomeSearchViewmodel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final authSession = AuthSessionService();

  List<ProductSearchModel> products = [];
  List<ProductSearchModel> filteredProducts = [];
  List<String> categories = ['Todos'];

  bool loading = false;

  String selectedCategory = 'Todos';
  String selectedOrder = 'Mais relevantes';

  Future<String> _getCompanyId() async {
    return await authSession.getCompanyId();
  }

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
      loading = true;
      notifyListeners();

      final companyId = await _getCompanyId();

      final response = await supabase
          .from('product')
          .select('''
            *,
            category:category_id (
              id,
              name
            )
          ''')
          .eq('company_id', companyId)
          .eq('is_active', true)
          .order('name');

      final data = List<Map<String, dynamic>>.from(response);

      products = data.map((e) => ProductSearchModel.fromMap(e)).toList();

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
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> searchProduct({required String value}) async {
    try {
      final search = value.trim().toLowerCase();

      var result = List<ProductSearchModel>.from(products);

      if (selectedCategory != 'Todos') {
        result = result.where((product) {
          return product.category.toLowerCase() ==
              selectedCategory.toLowerCase();
        }).toList();
      }

      if (search.isNotEmpty) {
        result = result.where((product) {
          return product.name.toLowerCase().contains(search) ||
              product.category.toLowerCase().contains(search);
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
    } catch (e) {
      debugPrint('Erro ao buscar produto: $e');
    }
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
    try {
      final companyId = await _getCompanyId();

      await supabase.from('product').insert({
        'name': name,
        'imageurl': imageurl,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
        'company_id': companyId,
        'brand': brand,
        'unit_type': unitType,
        'commission_value': commissionValue,
        'is_active': true,
      });

      await refreshProducts();
    } catch (e) {
      debugPrint('Erro ao adicionar produto: $e');
      rethrow;
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String imageurl,
    required double price,
    required int stock,
    required int categoryId,
    required String brand,
    required String unitType,
    required double commissionValue,
  }) async {
    try {
      final companyId = await _getCompanyId();

      await supabase
          .from('product')
          .update({
            'name': name,
            'imageurl': imageurl,
            'price': price,
            'stock': stock,
            'category_id': categoryId,
            'brand': brand,
            'unit_type': unitType,
            'commission_value': commissionValue,
          })
          .eq('id', id)
          .eq('company_id', companyId);

      await refreshProducts();
    } catch (e) {
      debugPrint('Erro ao atualizar produto: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final companyId = await _getCompanyId();

      await supabase
          .from('product')
          .update({'is_active': false})
          .eq('id', id)
          .eq('company_id', companyId);

      await refreshProducts();
    } catch (e) {
      debugPrint('Erro ao excluir produto: $e');
      rethrow;
    }
  }

  Future<void> refreshProducts() async {
    products.clear();
    filteredProducts.clear();

    await loadProduct(force: true);
  }

  Future<void> loadCategories() async {
    try {
      final companyId = await _getCompanyId();

      final response = await supabase
          .from('category')
          .select('id, name')
          .eq('company_id', companyId)
          .order('name');

      final data = List<Map<String, dynamic>>.from(response);

      categories = ['Todos', ...data.map((e) => e['name'].toString()).toList()];

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar categorias: $e');
    }
  }

  Future<void> loadInitialData() async {
    await loadCategories();
    await loadProduct(force: true);
  }
}
