import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DasCobras/app/viewmodels/carregamento_viewmodel.dart'; // Garanta que este import aponta para o seu arquivo correto

class SalesFloatingButtons extends StatelessWidget {
  final int cartCount;
  final int loadingCount;

  final VoidCallback onHistory;
  final VoidCallback onLoading;
  final VoidCallback onCart;

  const SalesFloatingButtons({
    super.key,
    required this.cartCount,
    required this.loadingCount,
    required this.onHistory,
    required this.onLoading,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'history',
          backgroundColor: const Color(0xFF0D3F87),
          onPressed: onHistory,
          child: const Icon(Icons.history, color: Colors.white),
        ),

        const SizedBox(height: 10),

        FloatingActionButton(
          heroTag: 'loading',
          backgroundColor: const Color(0xFF0D3F87),
          onPressed: onLoading,
          // 🟢 CORREÇÃO AQUI: Usamos o Consumer para escutar dinamicamente o número real de PEDIDOS salvos no ViewModel!
          child: Consumer<CarregamentoViewModel>(
            builder: (context, vm, _) {
              return Badge(
                label: Text(vm.pedidosCarregamento.length.toString()),
                child: const Icon(Icons.local_shipping, color: Colors.white),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        FloatingActionButton(
          heroTag: 'cart',
          backgroundColor: const Color(0xFF0D3F87),
          onPressed: onCart,
          child: Badge(
            label: Text(cartCount.toString()),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
