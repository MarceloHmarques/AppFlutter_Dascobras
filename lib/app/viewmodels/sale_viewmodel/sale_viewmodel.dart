import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/customer_model.dart';
import '../../model/product_search_model.dart';

class CartItem {
  final ProductSearchModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class SaleViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  CustomerModel? customer;

  List<CartItem> cart = [];

  void setCustomer(CustomerModel client) {
    customer = client;
    notifyListeners();
  }

  void removeCustomer() {
    customer = null;
    notifyListeners();
  }

  Future<void> addProduct(ProductSearchModel product, int quantity) async {
    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cart[index].quantity += quantity;
    } else {
      cart.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  Future<void> removeProduct(ProductSearchModel product) async {
    final item = cart.firstWhere((e) => e.product.id == product.id);

    await supabase
        .from("product")
        .update({"stock": product.stock + item.quantity})
        .eq("id", product.id);

    cart.remove(item);

    notifyListeners();
  }

  void increaseQuantity(cartItem) {
    if (cartItem.quantity >= cartItem.product.stock) {
      throw Exception('Quantidade maior que o estoque disponível.');
    }

    cartItem.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      cart.remove(cartItem);
    }

    notifyListeners();
  }

  void changeQuantity(cartItem, int value) {
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

  Future<void> saveSale({
    required String paymentMethod,
    required String statusOrder,
    required String userId,
  }) async {
    if (customer == null) {
      throw Exception("Selecione um cliente.");
    }

    if (cart.isEmpty) {
      throw Exception("Carrinho vazio.");
    }

    final sale = await supabase
        .from("sale")
        .insert({
          "customer_id": customer!.id,
          "total": total,
          "status_order": statusOrder,
          "payment_method": paymentMethod,
          "user_id": userId,
        })
        .select()
        .single();

    final int saleId = sale["id"];

    for (var item in cart) {
      await supabase.from("sale_item").insert({
        "sale_id": saleId,
        "product_id": item.product.id,
        "quantity": item.quantity,
        "unit_price": item.product.price,
        "subtotal": item.subtotal,
      });

      await supabase
          .from("product")
          .update({"stock": item.product.stock - item.quantity})
          .eq("id", item.product.id);
    }

    cart.clear();
    customer = null;

    notifyListeners();
  }

  void cancelSale() {
    cart.clear();
    customer = null;
    notifyListeners();
  }

  Future<void> finishSale() async {
    if (customer == null) {
      throw Exception('Selecione um cliente.');
    }
    await saveSale(
      paymentMethod: "PIx",
      statusOrder: "Pendente",
      userId: Supabase.instance.client.auth.currentUser?.id ?? "",
    );
    if (cart.isEmpty) {
      throw Exception('Carrinho vazio.');
    }

    try {
      final saleResponse = await supabase
          .from('sale')
          .insert({
            'customer_id': customer!.id,
            'total': total,
            'payment_method': 'DINHEIRO',
            'status': 'CONCLUIDA',
          })
          .select()
          .single();

      final saleId = saleResponse['id'];

      for (final item in cart) {
        if (item.quantity > item.product.stock) {
          throw Exception('Estoque insuficiente para ${item.product.name}.');
        }

        await supabase.from('sale_item').insert({
          'sale_id': saleId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'unit_price': item.product.price,
          'subtotal': item.subtotal,
        });

        await supabase
            .from('product')
            .update({'stock': item.product.stock - item.quantity})
            .eq('id', item.product.id);
      }

      cart.clear();
      customer = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao finalizar venda: $e');
    }
  }
}
