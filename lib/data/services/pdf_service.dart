import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PdfService {
  Future<void> generateInvoice({
    required String orderId,
    required String amount,
    required List<dynamic> items,
    required String customerEmail,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Aaliyah\'s Collection', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Invoice Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(customerEmail),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Order ID: $orderId'),
                      pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // Items Table
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Item', 'Quantity', 'Price', 'Total'],
                data: items.map((item) {
                  final qty = item['quantity'] ?? 1;
                  final price = double.tryParse(item['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
                  return [
                    item['title'] ?? 'Product',
                    qty.toString(),
                    'LKR ${price.toStringAsFixed(2)}',
                    'LKR ${(price * qty).toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
              
              pw.Divider(),
              pw.SizedBox(height: 10),
              
              // Total
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: LKR $amount',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              
              pw.Spacer(),
              pw.Center(child: pw.Text('Thank you for shopping with Aaliyah\'s Collection!')),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Text('This is a computer-generated invoice.', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    // Save and Open PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_$orderId.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await OpenFilex.open(file.path);
  }
}
