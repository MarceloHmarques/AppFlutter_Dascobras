import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../viewmodels/sale_viewmodel/sale_viewmodel.dart';

import 'package:intl/intl.dart';

class PdfService {
  static Future<File> generate(SaleViewModel saleVm) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');

    final logo = await imageFromAssetBundle(
      'lib/app/assets/img/LogoEmpresa2.png',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 1. BLOCO ESQUERDO: Dados de Controle do Pedido
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "1o. IMPRESSÃO",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "PEDIDO: ${saleVm.cart.hashCode}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "DATA: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        "Página: 1",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),

                // 2. BLOCO CENTRAL: Dados Físicos da Distribuidora
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          "EMANOEL MARQUES DE LIMA",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "AV DR JOSE APARICIO B DE FIGUEREDO, 1223 - JOÃO PAULO II",
                          style: const pw.TextStyle(fontSize: 7.5),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "JAGUARIBE - CE - CEP: 63475000 - Fone: 88-993123181",
                          style: const pw.TextStyle(fontSize: 7.5),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "CNPJ: - CGF:",
                          style: const pw.TextStyle(fontSize: 7.5),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "email:",
                          style: const pw.TextStyle(fontSize: 7.5),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. BLOCO DIREITO: Logo da Empresa
                pw.Expanded(
                  flex: 4,
                  child: pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Container(
                      height: 70,
                      width: 140,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),

            //-----------------------------------------------------------------
            // PARTE 2: DADOS DO CLIENTE E VENDEDOR
            //-----------------------------------------------------------------
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "CLIENTE: ${saleVm.customer?.id.toString().padLeft(5, '0') ?? ""} - ${saleVm.customer?.name ?? ""}"
                      .toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
                pw.SizedBox(height: 3),

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        "END.: ${saleVm.customer?.address ?? ""}".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "BAIRRO: ${saleVm.customer?.neighborhood ?? ""}"
                            .toUpperCase(),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "FANTASIA: NEM UM".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        "CIDADE: ${saleVm.customer?.city ?? ""}".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "UF: ${saleVm.customer?.state ?? ""}".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "CEP: ${saleVm.customer?.cep ?? ""}",
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 8,
                      child: pw.Text(
                        "CNPJ/CPF: ${saleVm.customer?.cpforcnpj ?? ""}",
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        "FONE: ${saleVm.customer?.phone ?? ""}",
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text(
                        "VENDEDOR: EMANOEL",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 6,
                      child: pw.Text(
                        "CONTATO:",
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),

            //-----------------------------------------------------------------
            // PARTE 3: CABEÇALHO DA TABELA DE ITENS
            //-----------------------------------------------------------------
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    "CÓDIGO PRODUTO",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "MARCA",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "NÚM.LOTE",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "OP UND",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      "QTDE",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "PREÇO",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "TOTAL",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "DESC.",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "LÍQUIDO",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            pw.Divider(thickness: 1),

            //-----------------------------------------------------------------
            // PRODUTOS DA LISTA
            //-----------------------------------------------------------------
            ...saleVm.cart.map(
              (item) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        "${item.product.id} ${item.product.name}".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        item.product.brand.toUpperCase(),
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        "-",
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        item.product.unitType,
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text(
                          "${item.quantity}",
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          item.product.price.toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          item.subtotal.toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "0.00",
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          item.subtotal.toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.Divider(thickness: 1),

            //-----------------------------------------------------------------
            // PARTE 4: TOTAIS E VALORES CONSOLIDADOS
            //-----------------------------------------------------------------
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 6,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Observações:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8.5,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        "Obrigado pela preferência!",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9.5,
                        ),
                      ),
                      pw.Text(
                        "Volte sempre!",
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "TOTALIZAÇÃO: R\$ ${saleVm.total.toStringAsFixed(2)}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "QUANT. DE ITENS: ${saleVm.cart.length}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      pw.Text(
                        "Data/Hora: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                        style: const pw.TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
            pw.Center(
              child: pw.Text(
                "Assinatura do Cliente",
                style: const pw.TextStyle(fontSize: 8.5),
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Venda_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      return File('');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        "${directory.path}/Venda_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );
      await file.writeAsBytes(bytes);
      return file;
    }
  }

  static Future<File> generateHistoryPdf({
    required Map<String, dynamic> sale,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle(
      'lib/app/assets/img/LogoEmpresa2.png',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "1o. IMPRESSÃO",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "PEDIDO: ${sale['id']}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "DATA: ${sale['sale_date'] ?? ''}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "EMANOEL MARQUES DE LIMA",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        "AV DR JOSE APARICIO B DE FIGUEREDO, 1223",
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                      pw.Text(
                        "JAGUARIBE - CE - Fone: 88-993123181",
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Align(
                    alignment: pw.Alignment.topRight,
                    child: pw.Container(
                      height: 50,
                      width: 90,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "CLIENTE: ${sale['customer']?['name'] ?? ''}".toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
                pw.Text(
                  "END.: ${sale['customer']?['address'] ?? ''}".toUpperCase(),
                  style: const pw.TextStyle(fontSize: 8.5),
                ),
                pw.Text(
                  "CIDADE: ${sale['customer']?['city'] ?? ''} - ${sale['customer']?['state_'] ?? ''}"
                      .toUpperCase(),
                  style: const pw.TextStyle(fontSize: 8.5),
                ),
                pw.Text(
                  "CNPJ/CPF: ${sale['customer']?['cpforcnpj'] ?? ''}",
                  style: const pw.TextStyle(fontSize: 8.5),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    "CÓDIGO PRODUTO",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    "MARCA",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Center(
                    child: pw.Text(
                      "QTDE",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "PREÇO",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "LÍQUIDO",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 1),
            ...items.map(
              (item) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        "${item['product_name'] ?? 'Produto'}".toUpperCase(),
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        "DISTRIBUIDORA",
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Center(
                        child: pw.Text(
                          "${item['quantity']}",
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "${item['unit_price'] ?? 0.0}",
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "${item['subtotal'] ?? 0.0}",
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 6,
                  child: pw.Text(
                    "Obrigado pela preferência!",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9.5,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "TOTALIZAÇÃO: R\$ ${NumberFormat('#,##0.00', 'en_US').format(sale['total'])}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                      pw.Text(
                        "QUANT. DE ITENS: ${items.length}",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Venda_${sale['id']}.pdf',
      );
      return File('');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/Venda_${sale['id']}.pdf");
      await file.writeAsBytes(bytes);
      return file;
    }
  }
}
