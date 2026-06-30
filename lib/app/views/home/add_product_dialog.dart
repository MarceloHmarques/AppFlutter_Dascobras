import 'dart:io';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:DasCobras/app/service/validation_service/product_validation.dart';
import 'package:DasCobras/app/service/validation_service/mask.dart';
import 'package:DasCobras/app/views/widgets/home/product_image_picker.dart';
import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:DasCobras/app/service/product_image_service.dart';

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
  final brandController = TextEditingController(); 
  final commissionController = TextEditingController(text: '0,00'); 

  final supabase = Supabase.instance.client;
  final ProductImageService imageService = ProductImageService();

  String? imageError;
  String? categoryError;

  int? selectedCategory;
  File? selectedImage;
  bool loading = false;
  bool isAdmin = false; 
  String selectedUnitType = 'UN'; 
  final List<String> unitOptions = ['UN', 'Fardo', 'Caixa', 'Saco', 'Kg'];

  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
    checkUserPermission(); 
  }

  Future<void> loadCategories() async {
    final response = await supabase.from('category').select('id, name');

    if (!mounted) return;

    setState(() {
      categories = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> checkUserPermission() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        isAdmin = response['is_admin'] ?? false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isAdmin = false);
      }
    }
  }

  Future<void> pickImage() async {
    try {
      final file = await imageService.pickImage();

      if (file == null) return;

      setState(() {
        selectedImage = file;
        imageError = null;
      });
    } catch (e) {
      setState(() {
        imageError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<String> uploadImage() async {
    if (selectedImage == null) {
      throw Exception('Imagem obrigatória.');
    }

    return imageService.uploadImage(selectedImage!);
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      setState(() {
        categoryError = 'Categoria obrigatória';
      });
      return;
    }

    if (selectedImage == null) {
      setState(() {
        imageError = 'Adicione uma imagem do produto.';
      });
      return;
    }

    try {
      setState(() => loading = true);

      final imageUrl = await uploadImage();

      final cleanCommission = double.parse(
        commissionController.text.replaceAll('.', '').replaceAll(',', '.'),
      );

      await context.read<HomeSearchViewmodel>().addProduct(
        name: nameController.text.trim(),
        imageurl: imageUrl,
        price: double.parse(
          priceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
        stock: int.parse(stockController.text),
        categoryId: selectedCategory!,
        brand: brandController.text.trim().isEmpty ? 'Sem Marca' : brandController.text.trim(), 
        unitType: selectedUnitType, 
        commissionValue: cleanCommission, 
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

                ProductImagePicker(
                  selectedImage: selectedImage,
                  errorMessage: imageError,
                  onTap: pickImage,
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  validator: (value) => ProductValidation.name(value),
                  decoration: _inputDecoration(label: 'Nome:'),
                ),

                const SizedBox(height: 15),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<int>(
                      width: constraints.maxWidth,
                      initialSelection: selectedCategory,
                      label: const Text('Categoria:'),
                      menuHeight: 230,
                      menuStyle: MenuStyle(
                        backgroundColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                        surfaceTintColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                        elevation: const WidgetStatePropertyAll(4),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      dropdownMenuEntries: categories.map((category) {
                        return DropdownMenuEntry<int>(
                          value: category['id'],
                          label: category['name'],
                        );
                      }).toList(),
                      onSelected: (value) {
                        setState(() {
                          selectedCategory = value;
                          categoryError = null;
                        });
                      },
                    );
                  },
                ),

                if (categoryError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        categoryError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
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

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: brandController,
                        decoration: _inputDecoration(label: 'Marca:'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnitType,
                        decoration: _inputDecoration(label: 'Opção Unidade:'),
                        dropdownColor: Colors.white,
                        items: unitOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUnitType = newValue ?? 'UN';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: commissionController,
                  enabled: isAdmin, 
                  keyboardType: TextInputType.number,
                  inputFormatters: [Mask.currencyFormatter],
                  decoration: InputDecoration(
                    labelText: 'Ganho do Vendedor (Por Unidade)',
                    prefixText: 'R\$ ',
                    fillColor: isAdmin ? Colors.white : Colors.grey.shade200,
                    filled: !isAdmin,
                    helperText: isAdmin ? null : 'Apenas administradores podem gerenciar este valor.',
                    helperStyle: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w500),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
    brandController.dispose(); 
    commissionController.dispose(); 
    super.dispose();
  }
}