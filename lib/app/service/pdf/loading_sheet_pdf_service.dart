import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LoadingSheetPdfService {
  /// Gera o PDF do Mapa de Carregamento baseado nos itens vendidos/agrupados
  Future<Uint8List> generateLoadingSheet({
    required String companyName,
    required String routeName,
    required List<Map<String, dynamic>> itens, // ✨ Padronizado para 'itens'
  }) async {
    final pdf = pw.Document();
    final String currentDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());

    // Cálculos dos Totais do Rodapé
    final int totalRecords = itens.length;
    final int totalItemsQuantity = itens.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LOJA: ${companyName.toUpperCase()} - MATRIZ',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'L3.2.2 LISTAGEM DE PRODUTOS PARA ENTREGA (MAPA DE CARREGAMENTO)',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'ROTA: ${routeName.toUpperCase()}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'EMISSÃO: $currentDate',
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 6),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table(
              border: const pw.TableBorder(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                horizontalInside: pw.BorderSide(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(2), // Código
                1: pw.FlexColumnWidth(6), // Produto
                2: pw.FlexColumnWidth(3), // Marca
                3: pw.FlexColumnWidth(2), // Quantidade
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildCell('CÓDIGO', isHeader: true),
                    _buildCell('PRODUTO', isHeader: true),
                    _buildCell('MARCA', isHeader: true),
                    _buildCell(
                      'QUANT',
                      isHeader: true,
                      align: pw.TextAlign.right,
                    ),
                  ],
                ),
                ...itens.map((item) {
                  return pw.TableRow(
                    children: [
                      _buildCell(item['product_id']?.toString() ?? '-'),
                      _buildCell(
                        item['product_name']?.toString().toUpperCase() ??
                            'PRODUTO',
                      ),
                      _buildCell(
                        item['brand']?.toString().toUpperCase() ?? 'SEM MARCA',
                      ),
                      _buildCell(
                        item['quantity']?.toString() ?? '0',
                        align: pw.TextAlign.right,
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 15),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'QUANTIDADE DE REGISTROS: $totalRecords',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'SUB-TOTAL ROTA:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '$totalItemsQuantity UNIDADES',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Divider(thickness: 0.5),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAIS GERAIS:',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '$totalItemsQuantity ITENS',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
