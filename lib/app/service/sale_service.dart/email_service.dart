import 'dart:io';

import 'package:share_plus/share_plus.dart';

class EmailService {
  static Future<void> sendSaleEmail({
    required String email,
    required String customerName,
    required File pdfFile,
  }) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: 'Comprovante de Compra',
      text: '''
Olá $customerName,

Obrigado pela sua compra.

Segue em anexo o comprovante da venda.

E-mail do cliente: $email
''',
    );
  }
}