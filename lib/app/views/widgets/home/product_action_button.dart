import 'package:flutter/material.dart';

class ProductActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const ProductActionButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed == null ? Colors.grey : color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
