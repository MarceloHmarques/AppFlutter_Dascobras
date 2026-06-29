import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/customer_model.dart';
import '../../model/product_search_model.dart';

class CartItem {
  final ProductSearchModel product;
  int quantity;
  double? customPrice; // 👈 Adicionado: guarda o preço customizado se houver

  CartItem({required this.product, this.quantity = 1, this.customPrice});

  // 👈 Modificado: Se houver preço customizado, usa ele; senão, usa o original do produto
  double get unitPrice => customPrice ?? product.price;

  // 👈 Modificado: O subtotal agora calcula baseado no preço ativo (original ou alterado)
  double get subtotal => unitPrice * quantity;
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

  Future<void> addProduct(ProductSearchModel product, int quantity, {double? customPrice}) async {
    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      cart[index].quantity += quantity;
      if (customPrice != null) {
        cart[index].customPrice = customPrice;
      }
    } else {
      cart.add(CartItem(product: product, quantity: quantity, customPrice: customPrice));
    }

    notifyListeners();
  }

  // 🔥 NOVA FUNÇÃO: Chama essa função na View quando o usuário editar o preço
  void changeProductPrice(CartItem cartItem, double newPrice) {
    if (newPrice < 0) {
      throw Exception('O preço não pode ser negativo.');
    }
    cartItem.customPrice = newPrice;
    notifyListeners(); // Atualiza o total e os valores na tela
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
        "unit_price": item.unitPrice, // 👈 Modificado: Salva o preço correto (original ou alterado)
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
    
    if (cart.isEmpty) {
      throw Exception('Carrinho vazio.');
    }

    try {
      // Centraliza a gravação usando a sua função padrão saveSale
      // com os dados que você definiu para o fechamento da venda
      await saveSale(
        paymentMethod: "DINHEIRO",
        statusOrder: "CONCLUIDA",
        userId: Supabase.instance.client.auth.currentUser?.id ?? "",
      );
    } catch (e) {
      throw Exception('Erro ao finalizar venda: $e');
    }
  }
}