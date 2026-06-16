import 'package:flutter/material.dart';

class ClientSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String value) onChanged;

  const ClientSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchBar(
        controller: controller,
        hintText: 'Buscar Cliente...',
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
        onChanged: onChanged,
      ),
    );
  }
}
