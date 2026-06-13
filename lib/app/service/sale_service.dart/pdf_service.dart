import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../viewmodels/sale_viewmodel/sale_viewmodel.dart';

class PdfService {
  static Future<File> generate(SaleViewModel saleVm) async {
    final pdf = pw.Document();

    final logo = await imageFromAssetBundle('lib/app/assets/img/LogoLonga.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) {
          return [
            //-----------------------------------
            // LOGO
            //-----------------------------------
            pw.Center(child: pw.Image(logo, width: 180)),

            pw.SizedBox(height: 20),

            //-----------------------------------
            // TÍTULO
            //-----------------------------------
            pw.Center(
              child: pw.Text(
                "COMPROVANTE DE VENDA",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Divider(),

            //-----------------------------------
            // DADOS CLIENTE
            //-----------------------------------
            pw.Table(
              border: pw.TableBorder.all(),

              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Nome:\n${saleVm.customer?.name ?? ""}"),
                    ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        "CPF/CNPJ:\n${saleVm.customer?.cpforcnpj ?? ""}",
                      ),
                    ),
                  ],
                ),

                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("Cidade:\n${saleVm.customer?.city ?? ""}"),
                    ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        "Estado:\n${saleVm.customer?.state ?? ""}",
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 5),

            pw.Text(
              "Data da Compra: "
              "${DateTime.now().day.toString().padLeft(2, '0')}/"
              "${DateTime.now().month.toString().padLeft(2, '0')}/"
              "${DateTime.now().year}",
              style: const pw.TextStyle(fontSize: 14),
            ),

            pw.SizedBox(height: 5),

            pw.Text(
              "Pedido: ${saleVm.cart.hashCode}",
              style: const pw.TextStyle(fontSize: 14),
            ),

            pw.SizedBox(height: 20),

            pw.Divider(),

            //-----------------------------------
            // CABEÇALHO TABELA
            //-----------------------------------
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    "Produto",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),

                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      "Qtd",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),

                pw.Expanded(
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "Unit.",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),

                pw.Expanded(
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      "Total",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            pw.Divider(),

            //-----------------------------------
            // PRODUTOS
            //-----------------------------------
            ...saleVm.cart.map(
              (item) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.Text(item.product.name)),

                    pw.Expanded(
                      child: pw.Center(child: pw.Text("${item.quantity}")),
                    ),

                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "R\$ ${item.product.price.toStringAsFixed(2)}",
                        ),
                      ),
                    ),

                    pw.Expanded(
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          "R\$ ${item.subtotal.toStringAsFixed(2)}",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.Divider(),

            //-----------------------------------
            // TOTAL
            //-----------------------------------
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL: R\$ ${saleVm.total.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 40),

            //-----------------------------------
            // RODAPÉ
            //-----------------------------------
            pw.Center(
              child: pw.Text(
                "Obrigado pela preferência!",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Center(
              child: pw.Text(
                "Das Cobras © 2026",
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
          ];
        },
      ),
    );

    //-----------------------------------
    // SALVAR PDF
    //-----------------------------------

    final bytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();

    final file = File(
      "${directory.path}/Venda_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(bytes);

    //-----------------------------------
    // ABRIR PDF
    //-----------------------------------

    return file;
  }
}
