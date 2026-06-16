import 'package:flutter/material.dart';

class SalesFloatingButtons extends StatelessWidget {
  final int cartCount;
  final VoidCallback onHistory;
  final VoidCallback onCart;

  const SalesFloatingButtons({
    super.key,
    required this.cartCount,
    required this.onHistory,
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
