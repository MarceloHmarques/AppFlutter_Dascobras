import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';

class EditProductDialog extends StatefulWidget {
  final dynamic product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;

  int selectedCategory = 1;
  File? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product.name);

    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );

    selectedCategory = widget.product.categoryId;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String> uploadImage() async {
    if (selectedImage == null) {
      return widget.product.imageurl;
    }

    final supabase = Supabase.instance.client;

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('imageProducts')
        .upload(fileName, selectedImage!);

    return supabase.storage.from('imageProducts').getPublicUrl(fileName);
  }

  Future<void> saveProduct() async {
    print("BOTÃO SALVAR CLICADO");

    try {
      print("ID: ${widget.product.id}");
      print("Nome: ${nameController.text}");
      print("Preço: ${priceController.text}");
      print("Estoque: ${stockController.text}");
      print("Categoria: $selectedCategory");

      // Faz upload da nova imagem (ou mantém a antiga)
      String imageUrl = await uploadImage();

      await context.read<HomeSearchViewmodel>().updateProduct(
        id: widget.product.id,
        name: nameController.text.trim(),
        imageurl: imageUrl,
        price: double.parse(priceController.text.replaceAll(',', '.')),
        stock: int.parse(stockController.text),
        categoryId: selectedCategory,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto atualizado com sucesso!")),
        );
      }
    } catch (e, s) {
      print("==================");
      print("ERRO AO SALVAR");
      print(e);
      print(s);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Produto',
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF0D3F87),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0D3F87)),
                    ),
                    child: selectedImage != null
                        ? Image.file(selectedImage!, fit: BoxFit.contain)
                        : Image.network(
                            widget.product.imageurl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 40,
                              );
                            },
                          ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Alterar Foto'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Bebida')),
                  DropdownMenuItem(value: 2, child: Text('Massas')),
                  DropdownMenuItem(value: 3, child: Text('Ração')),
                  DropdownMenuItem(value: 4, child: Text('Refrigerante')),
                  DropdownMenuItem(value: 5, child: Text('Grãos')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Estoque',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3F87),
                  ),
                  onPressed: saveProduct,
                  child: const Text(
                    'Salvar Produto',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
