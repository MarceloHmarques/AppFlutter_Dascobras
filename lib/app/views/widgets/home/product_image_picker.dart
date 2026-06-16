import 'dart:io';
import 'package:flutter/material.dart';

class ProductImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final VoidCallback onTap;
  final String? errorMessage;

  const ProductImagePicker({
    super.key,
    required this.selectedImage,
    this.imageUrl,
    required this.onTap,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0D3F87)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  )
                : imageUrl != null && imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 35,
                        color: Color(0xFF0D3F87),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Adicionar foto',
                        style: TextStyle(
                          color: Color(0xFF0D3F87),
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
