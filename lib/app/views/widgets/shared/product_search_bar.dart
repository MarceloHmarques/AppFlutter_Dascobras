import 'package:flutter/material.dart';

class ProductSearchBar extends StatelessWidget {
  final void Function(String value) onSearch;

  const ProductSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar(
            hintText: 'Buscar produto...',
            hintStyle: const WidgetStatePropertyAll(
              TextStyle(color: Color.fromARGB(255, 110, 110, 110)),
            ),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(Colors.white),
            trailing: const [Icon(Icons.search, color: Color(0xFF0D3F87))],
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF0D3F87)),
              ),
            ),
            onChanged: onSearch,
          ),
        ),
      ],
    );
  }
}
