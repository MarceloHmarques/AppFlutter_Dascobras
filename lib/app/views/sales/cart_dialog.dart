import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';
import '../../service/pdf_service.dart';
import '../../viewmodels/home_viewmodel/home_search_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Carrinho"),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D3F87),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<SaleViewModel>(
        builder: (context, saleVm, _) {
          if (saleVm.customer == null) {
            return _buildNoCustomerWidget(context);
          }

          if (saleVm.cart.isEmpty) {
            return _buildEmptyCartWidget(context);
          }

          return Column(
            children: [
              // Dados do Cliente
              _buildCustomerInfoCard(saleVm),

              const SizedBox(height: 16),

              // Lista de Produtos
              Expanded(
                child: ListView.builder(
                  itemCount: saleVm.cart.length,
                  itemBuilder: (context, index) {
                    final item = saleVm.cart[index];
                    return _buildProductCard(item, saleVm, context, index);
                  },
                ),
              ),

              // Total e Botões
              _buildTotalSection(saleVm),
              _buildActionButtons(saleVm, context),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoCustomerWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Selecione um cliente antes de finalizar a venda",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Voltar e selecionar cliente"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3F87),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Seu carrinho está vazio",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text("Adicione produtos para continuar"),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Adicionar produtos"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3F87),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(SaleViewModel saleVm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
        border: Border.all(color: const Color(0xFF0D3F87).withOpacity(1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: const Color(0xFF0D3F87)),
              const SizedBox(width: 8),
              const Text(
                "Cliente",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D3F87), // azul
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.person_outline,
            "Nome",
            saleVm.customer?.name ?? '',
          ),
          _buildInfoRow(
            Icons.assignment_ind,
            "CPF/CNPJ",
            saleVm.customer?.cpforcnpj ?? '',
          ),
          _buildInfoRow(
            Icons.location_on,
            "Endereço",
            "${saleVm.customer?.address ?? ''}, ${saleVm.customer?.houseNumber ?? ''} - ${saleVm.customer?.neighborhood ?? ''}",
          ),
          _buildInfoRow(
            Icons.location_city,
            "Cidade",
            "${saleVm.customer?.city ?? ''}/${saleVm.customer?.state ?? ''}",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    dynamic item,
    SaleViewModel saleVm,
    BuildContext context,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D3F87), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha 1: Nome e botão deletar
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D3F87),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await saleVm.removeProduct(item.product);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Linha 2: Código
            if (item.product.id != null)
              Text(
                "Código: ${item.product.id}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

            const SizedBox(height: 12),

            // Linha 3: Quantidade, Preço e Total
            Row(
              children: [
                // Quantidade
                Container(
                  width: 120,
                  child: Row(
                    children: [
                      const Text(
                        "Qtd: ",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      InkWell(
                        onTap: () => saleVm.decreaseQuantity(item),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D3F87),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0D3F87),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          try {
                            saleVm.increaseQuantity(item);
                          } catch (e) {
                            _showErrorSnackBar(context, e);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF0D3F87),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
  child: GestureDetector(
    behavior: HitTestBehavior.opaque, 
    onTap: () => _showEditPriceDialog(context, saleVm, item),
    child: Padding(
      padding: const EdgeInsets.all(8.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Preço ",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Icon(Icons.edit, size: 12, color: const Color(0xFF0D3F87)), 
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "R\$ ${item.unitPrice.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF0D3F87),
              fontWeight: FontWeight.bold,
              decoration: item.customPrice != null ? TextDecoration.underline : TextDecoration.none,
              fontStyle: item.customPrice != null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    ),
  ),
),

                // Total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        "R\$ ${item.subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D3F87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(SaleViewModel saleVm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3F87).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total do Pedido",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                "${saleVm.cart.length} ${saleVm.cart.length == 1 ? 'item' : 'itens'}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          Text(
            "R\$ ${saleVm.total.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D3F87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SaleViewModel saleVm, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showCancelConfirmationDialog(context, saleVm),
              child: const Text("Cancelar Venda"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _finalizeSale(saleVm, context),
              child: const Text("Finalizar Venda"),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, SaleViewModel saleVm, dynamic item) {
    final TextEditingController priceController = TextEditingController(
      text: item.unitPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Alterar Preço - ${item.product.name}"),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Preço Unitário (R\$)",
            border: OutlineInputBorder(),
            prefixText: "R\$ ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3F87),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final double? newPrice = double.tryParse(priceController.text.replaceAll(',', '.'));
              if (newPrice != null) {
                try {
                  saleVm.changeProductPrice(item, newPrice);
                  Navigator.pop(dialogContext);
                } catch (e) {
                  _showErrorSnackBar(context, e);
                }
              } else {
                _showErrorSnackBar(context, "Insira um preço válido.");
              }
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    SaleViewModel saleVm,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Cancelar venda"),
        content: const Text("Tem certeza que deseja cancelar esta venda?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () {
              saleVm.cancelSale();
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeSale(SaleViewModel saleVm, BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final pdfFile = await PdfService.generate(saleVm);
      if (context.mounted) Navigator.pop(context);

      await Share.shareXFiles([
        XFile(pdfFile.path),
      ], text: 'Comprovante da venda');
      await saleVm.finishSale();

      if (context.mounted) {
        await context.read<HomeSearchViewmodel>().loadProduct();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venda finalizada!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackBar(context, "Erro: $e");
    }
  }
}