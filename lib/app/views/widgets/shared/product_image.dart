import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width = 70,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 50,
            color: Color(0xFF0D3F87),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 50,
              color: Color(0xFF0D3F87),
            ),
          );
        },
      ),
    );
  }
}
