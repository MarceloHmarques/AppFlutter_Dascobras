import 'package:flutter/material.dart';

class CarregamentoViewModel extends ChangeNotifier {
  // Mapa para armazenar os itens acumulados para o PDF consolidado
  final Map<int, Map<String, dynamic>> _itensAcumulados = {};
  Map<int, Map<String, dynamic>> get itensAcumulados => _itensAcumulados;

  // Lista que armazena os cards de pedidos individuais na tela
  List<dynamic> pedidosCarregamento = [];

  /// 🟢 CORRIGIDO: Agora recebe o Objeto/Mapa do pedido completo, salva e acumula
  void adicionarPedido(Map<String, dynamic> pedido) {
    // 1. Salva o pedido na lista para aparecer o Card na tela
    pedidosCarregamento.add(pedido);

    // 2. Extrai os itens dele para somar no totalizador do PDF
    final List<dynamic> itens = pedido['items'] ?? pedido['itens'] ?? [];
    for (var item in itens) {
      final int productId = item['product_id'] ?? item['product']?['id'] ?? 0;
      if (productId == 0) continue;

      if (_itensAcumulados.containsKey(productId)) {
        final qtdExistente = _itensAcumulados[productId]!['quantity'] as int;
        final qtdNova = (item['quantity'] ?? 0) as int;
        _itensAcumulados[productId]!['quantity'] = qtdExistente + qtdNova;
      } else {
        _itensAcumulados[productId] = {
          'product_id': productId,
          'product_name': item['product_name'] ?? item['product']?['name'] ?? 'PRODUTO',
          'brand': item['brand'] ?? item['product']?['brand'] ?? 'SEM MARCA',
          'quantity': item['quantity'] ?? 0,
        };
      }
    }
    
    // 3. Notifica os Badges e as telas para atualizarem o número imediatamente!
    notifyListeners();
  }

  /// 🗑️ Remove um pedido da lista e recalcula o acumulado do PDF do zero
  void removerPedido(int index) {
    if (index >= 0 && index < pedidosCarregamento.length) {
      pedidosCarregamento.removeAt(index);
      
      // Recalcula o mapa de somas
      _itensAcumulados.clear();
      for (var ped in pedidosCarregamento) {
        final List<dynamic> itens = ped['items'] ?? ped['itens'] ?? [];
        for (var item in itens) {
          final int productId = item['product_id'] ?? item['product']?['id'] ?? 0;
          if (productId == 0) continue;
          
          if (_itensAcumulados.containsKey(productId)) {
            _itensAcumulados[productId]!['quantity'] = 
                (_itensAcumulados[productId]!['quantity'] as int) + ((item['quantity'] ?? 0) as int);
          } else {
            _itensAcumulados[productId] = {
              'product_id': productId,
              'product_name': item['product_name'] ?? item['product']?['name'] ?? 'PRODUTO',
              'brand': item['brand'] ?? item['product']?['brand'] ?? 'SEM MARCA',
              'quantity': item['quantity'] ?? 0,
            };
          }
        }
      }
      notifyListeners();
    }
  }

  /// 🧹 Zera completamente o estado do carregamento após finalizar
  void limparCarregamento() {
    pedidosCarregamento.clear();
    _itensAcumulados.clear();
    notifyListeners();
  }
}