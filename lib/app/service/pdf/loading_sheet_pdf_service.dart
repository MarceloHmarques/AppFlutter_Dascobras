import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LoadingSheetPdfService {
  /// Gera o PDF do Mapa de Carregamento baseado nos itens vendidos/agrupados
  Future<Uint8List> generateLoadingSheet({
    required String companyName,
    required String routeName,
    required List<Map<String, dynamic>> items, 
  }) async {
    final pdf = pw.Document();
    final String currentDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Cálculos dos Totais do Rodapé
    final int totalRecords = items.length;
    final int totalItemsQuantity = items.fold<int>(
      0, (sum, item) => sum + (item['quantity'] as int? ?? 0)
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        // Cabeçalho que se repete caso o relatório tenha mais de uma página
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'LOJA: ${companyName.toUpperCase()} - MATRIZ',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'L3.2.2 LISTAGEM DE PRODUTOS PARA ENTREGA (MAPA DE CARREGAMENTO)',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                main pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('ROTA: ${routeName.toUpperCase()}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text('EMISSÃO: $currentDate', style: pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1, color: PdfColors.black),
              pw.SizedBox(height: 6),
            ],
          );
        },
        // Rodapé com numeração de páginas automático
        footer: (pw.Context context) {
          return pw.Alignment(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Tabela de Produtos Limpa (Apenas dados reais do sistema)
            pw.Table(
              border: const pw.TableBorder(
                bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),  // Código
                1: pw.FlexColumnWidth(6),  // Produto
                2: pw.FlexColumnWidth(3),  // Marca
                3: pw.FlexColumnWidth(2),  // Quantidade
              },
              children: [
                // Linha de Cabeçalho da Tabela
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildCell('CÓDIGO', isHeader: true),
                    _buildCell('PRODUTO', isHeader: true),
                    _buildCell('MARCA', isHeader: true),
                    _buildCell('QUANT', isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Linhas dos Itens do Carregamento
                ...items.map((item) {
                  return pw.TableRow(
                    children: [
                      _buildCell(item['product_id']?.toString() ?? '-'),
                      _buildCell(item['product_name']?.toString().toUpperCase() ?? 'PRODUTO'),
                      _buildCell(item['brand']?.toString().toUpperCase() ?? 'SEM MARCA'),
                      _buildCell(item['quantity']?.toString() ?? '0', align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 15),

            // Bloco de Resumos e Totais IGUAL ao da foto, mas sem os zeros extras
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(top: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'QUANTIDADE DE REGISTROS: $totalRecords',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    main pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'SUB-TOTAL ROTA:',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '$totalItemsQuantity UNIDADES',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Divider(thickness: 0.5, style: pw.BorderStyle.dashed),
                  ),
                  pw.Row(
                    main pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAIS GERAIS:',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '$totalItemsQuantity ITENS',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
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

  // Helper para criar as células com espaçamento correto padrão de relatórios
  static pw.Widget _buildCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}