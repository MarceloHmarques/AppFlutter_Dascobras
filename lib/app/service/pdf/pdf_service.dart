import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_receipt_data.dart';

class PdfService {
  static final _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static Future<File> generateReceipt(PdfReceiptData data) async {
    final pdf = pw.Document();

    final logo = data.companyLogoUrl.isNotEmpty
        ? await networkImage(data.companyLogoUrl)
        : await imageFromAssetBundle('lib/app/assets/img/LogoEmpresa2.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return [
            _header(data, logo),
            _customerInfo(data),
            _productsTable(data),
            _totals(data),
            _footer(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    
    String nomeCliente = 'cliente';
    
    if (data.customerName != null && data.customerName.trim().isNotEmpty) {
      nomeCliente = data.customerName
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[áàâã]'), 'a')
          .replaceAll(RegExp(r'[éèê]'), 'e')
          .replaceAll(RegExp(r'[íìî]'), 'i')
          .replaceAll(RegExp(r'[óòôõ]'), 'o')
          .replaceAll(RegExp(r'[úùû]'), 'u')
          .replaceAll(RegExp(r'[ç]'), 'c')
          .replaceAll(RegExp(r'[^\w\s]+'), '') 
          // Troca espaços por _
          .replaceAll(' ', '_');
    }

    // Caso o tratamento limpe a string por completo, garante o fallback
    if (nomeCliente.isEmpty) nomeCliente = 'cliente';

    final String nomeArquivo = 'Venda_${data.orderId}_$nomeCliente.pdf';
    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: nomeArquivo,
      );
      return File('');
    }

    // Código executado no Telemóvel (Salva localmente com o nome correto)
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$nomeArquivo');
    await file.writeAsBytes(bytes);

    return file;
  } 

  static pw.Widget _header(PdfReceiptData data, pw.ImageProvider logo) {
    final date = data.saleDate;

    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 4),
                  _bold('PEDIDO: ${data.orderId}', 10),
                  _bold('DATA: $date', 10),
                  _bold('VENDEDOR: ${data.sellerName.toUpperCase()}', 9),
                ],
              ),
            ),
            pw.Expanded(
              flex: 5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  _bold(data.companyName.toUpperCase(), 10),
                  _text(
                    '${data.companyAddress}, ${data.companyHouseNumber} - ${data.companyNeighborhood}'
                        .toUpperCase(),
                    7.5,
                  ),
                  _text(
                    '${data.companyCity} - ${data.companyState} - CEP: ${data.companyCep}',
                    7.5,
                  ),
                  _text('Fone: ${data.companyPhone}', 7.5),
                  _text('CNPJ: ${data.companyCnpj}', 7.5),
                  _text('Email: ${data.companyEmail}', 7.5),
                ],
              ),
            ),
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
      ],
    );
  }

  static pw.Widget _customerInfo(PdfReceiptData data) {
    final tradeName = data.customerTradeName;

    final title = (tradeName != null && tradeName.trim().isNotEmpty)
        ? '${data.customerName} ($tradeName)'
        : data.customerName;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _bold('CLIENTE: ${title.toUpperCase()}', 9.5),
        pw.SizedBox(height: 3),

        pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: _text('END.: ${data.customerAddress}'.toUpperCase(), 8.5),
            ),
            pw.Expanded(
              flex: 3,
              child: _text(
                'BAIRRO: ${data.customerNeighborhood}'.toUpperCase(),
                8.5,
              ),
            ),
            pw.Expanded(flex: 3, child: _text('CEP: ${data.customerCep}', 8.5)),
          ],
        ),

        pw.SizedBox(height: 3),

        pw.Row(
          children: [
            pw.Expanded(
              flex: 5,
              child: _text('CIDADE: ${data.customerCity}'.toUpperCase(), 8.5),
            ),
            pw.Expanded(
              flex: 2,
              child: _text('UF: ${data.customerState}'.toUpperCase(), 8.5),
            ),
            pw.Expanded(
              flex: 3,
              child: _text('FONE: ${data.customerPhone}', 8.5),
            ),
          ],
        ),

        pw.SizedBox(height: 3),

        _text('CPF/CNPJ: ${data.customerDocument}', 8.5),

        pw.SizedBox(height: 5),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 5),
      ],
    );
  }

  static pw.Widget _productsTable(PdfReceiptData data) {
    return pw.Column(
      children: [
        pw.Row(
          children: [
            _tableHeader('CÓDIGO PRODUTO', 4),
            _tableHeader('MARCA', 2),
            _tableHeader('OP UND', 2),
            _tableHeader('QTDE', 1, center: true),
            _tableHeader('PREÇO', 2, right: true),
            _tableHeader('TOTAL', 2, right: true),
          ],
        ),
        pw.Divider(thickness: 1),
        ...data.items.map((item) {
          final productName =
              item['product_name'] ?? item['product']?['name'] ?? 'Produto';

          final brand =
              item['brand'] ?? item['product']?['brand'] ?? 'Sem Marca';

          final unit =
              item['unit_type'] ?? item['product']?['unit_type'] ?? 'UN';

          final quantity = item['quantity'] ?? 0;

          final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0;
          final subtotal = (item['subtotal'] as num?)?.toDouble() ?? 0;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              children: [
                _tableText(productName.toString().toUpperCase(), 4),
                _tableText(brand.toString().toUpperCase(), 2),
                _tableText(unit.toString(), 2),
                _tableText(quantity.toString(), 1, center: true),
                _tableText(_currency.format(unitPrice), 2, right: true),
                _tableText(_currency.format(subtotal), 2, right: true),
              ],
            ),
          );
        }),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _totals(PdfReceiptData data) {
    final totalQuantity = data.items.fold<num>(0, (sum, item) {
      return sum + ((item['quantity'] as num?) ?? 0);
    });

    return pw.Row(
      children: [
        pw.Expanded(
          flex: 6,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _bold('Observações:', 8.5),
              pw.SizedBox(height: 10),
              _bold('Obrigado pela preferência!', 9.5),
              _text('Volte sempre!', 8.5),
            ],
          ),
        ),
        pw.Expanded(
          flex: 5,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _bold('TOTALIZAÇÃO: ${_currency.format(data.total)}', 9),
              pw.SizedBox(height: 2),
              _bold(
                'QUANT. DE ITENS: $totalQuantity',
                9,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 25),
        pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
        pw.Center(child: _text('Assinatura do Cliente', 8.5)),
      ],
    );
  }

  static pw.Widget _tableHeader(
    String text,
    int flex, {
    bool center = false,
    bool right = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Align(
        alignment: right
            ? pw.Alignment.centerRight
            : center
            ? pw.Alignment.center
            : pw.Alignment.centerLeft,
        child: _bold(text, 8),
      ),
    );
  }

  static pw.Widget _tableText(
    String text,
    int flex, {
    bool center = false,
    bool right = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Align(
        alignment: right
            ? pw.Alignment.centerRight
            : center
            ? pw.Alignment.center
            : pw.Alignment.centerLeft,
        child: _text(text, 7.5),
      ),
    );
  }

  static pw.Text _text(String text, double size) {
    return pw.Text(text, style: pw.TextStyle(fontSize: size));
  }

  static pw.Text _bold(String text, double size) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: size, fontWeight: pw.FontWeight.bold),
    );
  }

  static Future<File> generatePickingList(List itens, String customerName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text(
              'Lista de Separação',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            ...itens.map(
              (item) => pw.Text(
                '${item['product_name']} - Qtde: ${item['quantity']}',
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    // 💡 FORMATANDO O NOME DO CLIENTE PARA A LISTA DE SEPARAÇÃO
    final String nomeCliente = customerName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');

    if (kIsWeb) {
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'PickingList_$nomeCliente.pdf',
      );

      return File('');
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/PickingList_$nomeCliente.pdf');

    await file.writeAsBytes(bytes);

    return file;
  }
}