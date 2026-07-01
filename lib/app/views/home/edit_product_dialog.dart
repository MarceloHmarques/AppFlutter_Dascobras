import 'dart:io';
import 'package:DasCobras/app/service/auth_session_service.dart';

import 'package:DasCobras/app/views/widgets/home/product_image_picker.dart';
import 'package:DasCobras/app/service/product_image_service.dart';
import 'package:DasCobras/app/service/validation_service/mask.dart';
import 'package:DasCobras/app/service/validation_service/product_validation.dart';
import 'package:DasCobras/app/viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductDialog extends StatefulWidget {
  final dynamic product;

  const EditProductDialog({super.key, required this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController brandController;
  late TextEditingController commissionController;

  final supabase = Supabase.instance.client;
  final ProductImageService imageService = ProductImageService();

  String selectedUnitType = 'UN';
  List<Map<String, dynamic>> unitTypes = [];
  Future<void> loadUnitTypes() async {
    final companyId = await AuthSessionService().getCompanyId();

    final response = await supabase
        .from('unit_type')
        .select('id, name')
        .eq('company_id', companyId)
        .order('name');

    if (!mounted) return;

    setState(() {
      unitTypes = List<Map<String, dynamic>>.from(response);
    });
  }

  List<Map<String, dynamic>> categories = [];

  int? selectedCategory;
  File? selectedImage;
  String? imageError;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadUnitTypes();
    nameController = TextEditingController(text: widget.product.name);

    priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2).replaceAll('.', ','),
    );

    stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );

    selectedCategory = widget.product.categoryId;
    brandController = TextEditingController(text: widget.product.brand);

    commissionController = TextEditingController(
      text: widget.product.commissionValue
          .toStringAsFixed(2)
          .replaceAll('.', ','),
    );

    selectedUnitType = widget.product.unitType;
    loadCategories();
  }

  Future<void> loadCategories() async {
    final companyId = await AuthSessionService().getCompanyId();

    final response = await supabase
        .from('category')
        .select('id, name')
        .eq('company_id', companyId)
        .order('name');
    if (!mounted) return;

    setState(() {
      categories = List<Map<String, dynamic>>.from(response);
    });
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

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      String imageUrl = widget.product.imageurl;

      if (selectedImage != null) {
        await imageService.deleteImageByUrl(widget.product.imageurl);
        imageUrl = await imageService.uploadImage(selectedImage!);
      }

      await context.read<HomeSearchViewmodel>().updateProduct(
        id: widget.product.id,
        name: nameController.text.trim(),
        imageurl: imageUrl,
        price: double.parse(
          priceController.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
        stock: int.parse(stockController.text),
        categoryId: selectedCategory!,
        brand: brandController.text.trim().isEmpty
            ? 'Sem Marca'
            : brandController.text.trim(),
        unitType: selectedUnitType,
        commissionValue: double.parse(
          commissionController.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto atualizado com sucesso!")),
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
          border: Border.all(color: const Color(0xFF0D3F87), width: 2),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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

                ProductImagePicker(
                  selectedImage: selectedImage,
                  imageUrl: widget.product.imageurl,
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
                        });
                      },
                    );
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

                    const SizedBox(width: 10),

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

                    const SizedBox(width: 10),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnitType,
                        decoration: _inputDecoration(label: 'Opção Unidade:'),
                        dropdownColor: Colors.white,
                        items: unitTypes.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit['name'],
                            child: Text(unit['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUnitType = value ?? 'UN';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: commissionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [Mask.currencyFormatter],
                  decoration: InputDecoration(
                    labelText: 'Comissão do vendedor (Un)',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

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
