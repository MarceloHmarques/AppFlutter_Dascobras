import 'package:flutter/material.dart';
import 'package:DasCobras/app/model/product_search_model.dart';
import 'package:DasCobras/app/views/widgets/shared/product_image.dart';

class SalesProductCard extends StatelessWidget {
  final ProductSearchModel product;
  final VoidCallback onAdd;

  const SalesProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final Color stockColor = product.stock > 0
        ? const Color(0xFF0D3F87)
        : Colors.red;

    final String stockText = product.stock > 0
        ? '${product.stock} em estoque'
        : 'Sem estoque';

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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                  'R\$ ${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
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
                  child: Text(
                    stockText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: product.stock > 0 ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              onPressed: product.stock > 0 ? onAdd : null,
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
