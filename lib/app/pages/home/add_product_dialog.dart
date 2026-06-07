import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  int? selectedCategory;
  String? selectedUnit;

  File? selectedImage;

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
      return '';
    }

    final supabase = Supabase.instance.client;

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    await supabase.storage
        .from('imageProducts')
        .upload(fileName, selectedImage!);

    return supabase.storage.from('imageProducts').getPublicUrl(fileName);
  }

  Future<void> saveProduct() async {
    try {
      String imageUrl = await uploadImage();

      await context.read<HomeSearchViewmodel>().addProduct(
        name: nameController.text.trim(),
        imageurl: imageUrl,
        price: double.parse(priceController.text.replaceAll(',', '.')),
        stock: int.parse(stockController.text),
        categoryId: selectedCategory!,
      );

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto cadastrado com sucesso!")),
        );
      }
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
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
                'Adicionar Produto',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF0D3F87),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              InkWell(
                onTap: pickImage,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0D3F87)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImage == null
                      ? const Column(
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
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nome do produto *',
                  style: TextStyle(color: Color(0xFF0D3F87), fontSize: 16),
                ),
              ),

              const SizedBox(height: 5),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categoria *',
                  style: TextStyle(color: Color(0xFF0D3F87), fontSize: 16),
                ),
              ),

              const SizedBox(height: 5),

              DropdownButtonFormField<int>(
                value: selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Bebida')),
                  DropdownMenuItem(value: 2, child: Text('Massas')),
                  DropdownMenuItem(value: 3, child: Text('Ração')),
                  DropdownMenuItem(value: 4, child: Text('Refrigerante')),
                  DropdownMenuItem(value: 5, child: Text('Grãos')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
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
                      decoration: InputDecoration(
                        labelText: "Preço",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Estoque",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3F87),
                  ),
                  onPressed: saveProduct,
                  child: const Text(
                    'Salvar Produto',
                    style: TextStyle(color: Colors.white, fontSize: 18),
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
