import 'package:flutter/material.dart';

import '../../sales/add_product_cart_dialog.dart';
import '../home/product_action_button.dart';

class ProductSaleActions extends StatelessWidget {
  final dynamic product;

  const ProductSaleActions({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductActionButton(
      color: Colors.green,
      icon: Icons.add,
      onPressed: product.stock == 0
          ? null
          : () {
              showDialog(
                context: context,
                builder: (_) => AddProductCartDialog(product: product),
              );
            },
    );
  }
}
