import 'dart:io';

import 'package:DasCobras/app/service/validation/product_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:DasCobras/app/service/validation/mask.dart';

import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  final supabase = Supabase.instance.client;

  int? selectedCategory;
  File? selectedImage;

  bool loading = false;

  String? imageError;

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final response = await supabase.from('category').select('id, name');

    setState(() {
      categories = List<Map<String, dynamic>>.from(response);
    });
  }

  bool isValidImage(String path) {
    final extension = path.split('.').last.toLowerCase();

    return ['png', 'jpg', 'jpeg', 'webp', 'heic', 'heif'].contains(extension);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (!isValidImage(image.path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Formato inválido. Use PNG, JPG, JPEG, WebP, HEIC ou HEIF.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final file = File(image.path);
    final sizeInMB = await file.length() / (1024 * 1024);

    if (sizeInMB > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagem muito grande. Máximo permitido: 5MB.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      selectedImage = file;
    });
  }

  Future<String> uploadImage() async {
    if (selectedImage == null) {
      throw Exception('Imagem obrigatória.');
    }

    final extension = selectedImage!.path.split('.').last.toLowerCase();
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";

    await supabase.storage
        .from('imageProducts')
        .upload(fileName, selectedImage!);

    return supabase.storage.from('imageProducts').getPublicUrl(fileName);
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      setState(() {
        imageError = 'Adicione uma imagem do produto.';
      });
      return;
    }

    try {
      setState(() => loading = true);

      final imageUrl = await uploadImage();

      await context.read<HomeSearchViewmodel>().addProduct(
        name: nameController.text.trim(),
        imageurl: imageUrl,
        price: double.parse(
          priceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
        stock: int.parse(stockController.text),
        categoryId: selectedCategory!,
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto cadastrado com sucesso!")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D3F87), width: 1),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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

                if (imageError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      imageError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  validator: (value) => ProductValidation.name(value),
                  decoration: _inputDecoration(label: 'Nome:'),
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<int>(
                  value: selectedCategory,
                  decoration: _inputDecoration(label: 'Categoria:'),
                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Categoria obrigatória';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [Mask.currencyFormatter],
                        decoration: InputDecoration(
                          labelText: 'Preço',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) => ProductValidation.price(value),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _inputDecoration(label: 'Estoque'),
                        validator: (value) => ProductValidation.stock(value),
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
                    onPressed: loading ? null : saveProduct,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Salvar Produto',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF0D3F87), fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration({String? label}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }
}
