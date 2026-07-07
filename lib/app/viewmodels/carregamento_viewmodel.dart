import 'package:flutter/material.dart';

class CarregamentoViewModel extends ChangeNotifier {
  // Mapa para armazenar os itens acumulados: o ID do produto é a chave
  // Isso facilita a soma automática das quantidades
  Map<int, Map<String, dynamic>> _itensAcumulados = {};

  Map<int, Map<String, dynamic>> get itensAcumulados => _itensAcumulados;

  /// Adiciona uma lista de itens de uma venda ao carregamento
  void adicionarPedido(List<dynamic> itens) {
    for (var item in itens) {
      final int productId = item['product_id'] ?? item['product']['id'];
      
      if (_itensAcumulados.containsKey(productId)) {
        // Se já existe, apenas soma a quantidade
        final qtdExistente = _itensAcumulados[productId]!['quantity'] as int;
        final qtdNova = item['quantity'] as int;
        _itensAcumulados[productId]!['quantity'] = qtdExistente + qtdNova;
      } else {
        // Se é novo, adiciona ao mapa
        _itensAcumulados[productId] = {
          'product_id': productId,
          'product': item['product'],
          'quantity': item['quantity'],
        };
      }
    }
    notifyListeners();
  }

  /// Remove todos os itens do carregamento atual
  void limparCarregamento() {
    _itensAcumulados.clear();
    notifyListeners();
  }

  /// Remove um item específico se necessário
  void removerItem(int productId) {
    _itensAcumulados.remove(productId);
    notifyListeners();
  }
}