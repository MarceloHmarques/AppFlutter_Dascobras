import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final String selectedOrder;
  final List<String> categories;
  final Function(String) onCategorySelected;
  final Function(String) onOrderSelected;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.selectedOrder,
    required this.categories,
    required this.onCategorySelected,
    required this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3F87),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              selectedCategory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: () => _openFilter(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF0D3F87)),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.filter_alt_outlined,
                color: Color(0xFF0D3F87),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFilter(BuildContext context) {
    final orders = [
      'A-Z',
      'Z-A',
      'Maior preço',
      'Menor preço',
      'Mais vendidos',
      'Menos vendidos',
      'Mais relevantes',
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Categorias',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              ...categories.map((category) {
                return ListTile(
                  title: Text(category),
                  trailing: selectedCategory == category
                      ? const Icon(Icons.check, color: Color(0xFF0D3F87))
                      : null,
                  onTap: () {
                    onCategorySelected(category);
                    Navigator.pop(context);
                  },
                );
              }),

              const Divider(),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ordenar por',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              ...orders.map((order) {
                return ListTile(
                  title: Text(order),
                  trailing: selectedOrder == order
                      ? const Icon(Icons.check, color: Color(0xFF0D3F87))
                      : null,
                  onTap: () {
                    onOrderSelected(order);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
