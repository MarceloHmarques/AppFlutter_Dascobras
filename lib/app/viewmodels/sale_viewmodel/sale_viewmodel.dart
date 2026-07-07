import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/customer_model.dart';
import '../../model/product_search_model.dart';
import 'package:DasCobras/app/service/auth_session_service.dart';

class CartItem {
  final ProductSearchModel product;
  int quantity;
  double? customPrice;

  CartItem({required this.product, this.quantity = 1, this.customPrice});

  double get unitPrice => customPrice ?? product.price;

  double get subtotal => unitPrice * quantity;

  double get totalCommission => product.commissionValue * quantity;
}

class SaleViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final authSession = AuthSessionService();

  CustomerModel? customer;
  List<CartItem> cart = [];

  bool finishingSale = false;

  Future<String> _getCompanyId() async {
    return await authSession.getCompanyId();
  }

  void setCustomer(CustomerModel client) {
    customer = client;
    notifyListeners();
  }

  void removeCustomer() {
    customer = null;
    notifyListeners();
  }

  Future<void> addProduct(
    ProductSearchModel product,
    int quantity, {
    double? customPrice,
  }) async {
    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cart[index].quantity += quantity;

      if (customPrice != null) {
        cart[index].customPrice = customPrice;
      }
    } else {
      cart.add(
        CartItem(
          product: product,
          quantity: quantity,
          customPrice: customPrice,
        ),
      );
    }

    notifyListeners();
  }

  void changeProductPrice(CartItem cartItem, double newPrice) {
    if (newPrice < 0) {
      throw Exception('O preço não pode ser negativo.');
    }

    cartItem.customPrice = newPrice;
    notifyListeners();
  }

  Future<void> removeProduct(ProductSearchModel product) async {
    final companyId = await _getCompanyId();

    final item = cart.firstWhere((e) => e.product.id == product.id);

    await supabase
        .from("product")
        .update({"stock": product.stock + item.quantity})
        .eq("id", product.id)
        .eq("company_id", companyId);

    cart.remove(item);
    notifyListeners();
  }

  void increaseQuantity(CartItem cartItem) {
    if (cartItem.quantity >= cartItem.product.stock) {
      throw Exception('Quantidade maior que o estoque disponível.');
    }

    cartItem.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      cart.remove(cartItem);
    }

    notifyListeners();
  }

  void changeQuantity(CartItem cartItem, int value) {
    if (value <= 0) {
      cart.remove(cartItem);
    } else if (value > cartItem.product.stock) {
      throw Exception('Quantidade maior que o estoque disponível.');
    } else {
      cartItem.quantity = value;
    }

    notifyListeners();
  }

  double get total {
    double value = 0;

    for (var item in cart) {
      value += item.subtotal;
    }

    return value;
  }

  double get totalSaleCommission {
    double value = 0;

    for (var item in cart) {
      value += item.totalCommission;
    }

    return value;
  }

  Future<Map<String, dynamic>> saveSale({
    required String statusOrder,
    required String userId,
  }) async {
    if (finishingSale) {
      throw Exception("A venda já está sendo finalizada.");
    }

    if (customer == null) {
      throw Exception("Selecione um cliente.");
    }

    if (cart.isEmpty) {
      throw Exception("Carrinho vazio.");
    }

    try {
      finishingSale = true;
      notifyListeners();

      final companyId = await _getCompanyId();
      final saleResponse = await supabase
          .from("sale")
          .insert({
            "customer_id": customer!.id,
            "total": total,
            "status_order": statusOrder,
            "payment_method": null,
            "user_id": userId,
            "company_id": companyId,
          })
          .select('''
      *,
      customer:customer_id (
        id,
        name,
        trade_name,
        cpforcnpj,
        phone,
        state_,
        city,
        neighborhood,
        cep,
        house_number,
        address
      )
    ''')
          .single();

      final sale = Map<String, dynamic>.from(saleResponse);

      final companyResponse = await supabase
          .from('company')
          .select()
          .eq('id', companyId);

      final companyList = List.from(
        companyResponse,
      ).map((e) => Map<String, dynamic>.from(e)).toList();

      if (companyList.isEmpty) {
        throw Exception('Empresa não encontrada para gerar o PDF.');
      }

      sale['company'] = companyList.first;

      debugPrint('COMPANY PDF: ${sale['company']}');

      final int saleId = sale["id"];

      for (var item in cart) {
        await supabase.from("sale_item").insert({
          "sale_id": saleId,
          "product_id": item.product.id,
          "quantity": item.quantity,
          "unit_price": item.unitPrice,
          "subtotal": item.subtotal,
          "commission_paid": item.product.commissionValue,
        });

        await supabase
            .from("product")
            .update({"stock": item.product.stock - item.quantity})
            .eq("id", item.product.id)
            .eq("company_id", companyId);
      }

      cart.clear();
      customer = null;
      notifyListeners();

      return sale;
    } finally {
      finishingSale = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getLastSaleItems(int saleId) async {
    final response = await supabase
        .from('sale_item')
        .select('''
        *,
        product:product_id (
          id,
          name,
          brand
        )
      ''')
        .eq('sale_id', saleId);

    return List.from(
      response,
    ).map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> finishSale() async {
    try {
      return await saveSale(
        statusOrder: "Concluido",
        userId: Supabase.instance.client.auth.currentUser?.id ?? "",
      );
    } catch (e) {
      throw Exception('Erro ao finalizar venda: $e');
    }
  }

  void cancelSale() {
    cart.clear();
    customer = null;
    notifyListeners();
  }
}
