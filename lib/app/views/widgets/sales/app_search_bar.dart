import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final void Function(String value) onChanged;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SearchBar(
        controller: controller,
        hintText: hintText,
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(color: Color(0xFF0D3F87)),
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
