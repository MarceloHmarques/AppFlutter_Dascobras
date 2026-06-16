import 'package:flutter/material.dart';
import 'package:DasCobras/app/views/widgets/shared/product_image.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final Widget actions;

  const ProductCard({super.key, required this.product, required this.actions});

  @override
  Widget build(BuildContext context) {
    final Color stockColor = product.stock == 0
        ? Colors.red
        : product.stock <= 10
        ? Colors.orange
        : const Color(0xFF0D3F87);

    final String stockText = product.stock == 0
        ? 'Sem estoque'
        : product.stock <= 10
        ? 'Últimas ${product.stock} unidades'
        : '${product.stock} em estoque';
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF0D3F87)),
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Row(
        children: [
          ProductImage(imageUrl: product.imageurl),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                  ),
                ),

                Text(
                  product.category,
                  style: const TextStyle(
                    color: Color(0xFF0D3F87),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  currency.format(product.price),
                  style: const TextStyle(
                    color: Color(0xFF28A745),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: stockColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stockColor == Colors.red || stockColor == Colors.orange
                            ? Icons.warning_amber_rounded
                            : Icons.inventory_2_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stockText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          actions,
        ],
      ),
    );
  }
}
