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

    // Define Colors based on App Theme
    const primaryColor = PdfColor.fromInt(0xFF004D61); // aaliyahPrimaryColor
    const secondaryColor = PdfColor.fromInt(0xFF822659); // aaliyahSecondaryColor

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER SECTION ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Aaliyah\'s Collection',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          )),
                      pw.Text('Modest Fashion Excellence',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.grey700,
                          )),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey300,
                          )),
                      pw.Text('Order: #$orderId',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2, color: primaryColor),
              pw.SizedBox(height: 30),

              // --- CLIENT & BUSINESS INFO ---
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILL TO:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: secondaryColor,
                                fontSize: 10)),
                        pw.SizedBox(height: 5),
                        pw.Text(customerEmail,
                            style: const pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('SHIPPED FROM:',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: secondaryColor,
                                fontSize: 10)),
                        pw.SizedBox(height: 5),
                        pw.Text('Aaliyah\'s Collection Store',
                            style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Colombo, Sri Lanka',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),

              // --- ITEMS TABLE ---
              pw.TableHelper.fromTextArray(
                border: null,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                cellHeight: 30,
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
                headers: ['Product Name', 'Qty', 'Unit Price', 'Total'],
                data: items.map((item) {
                  final qty = item['quantity'] ?? 1;
                  final price = double.tryParse(item['price']
                          .toString()
                          .replaceAll(RegExp(r'[^0-9.]'), '')) ??
                      0.0;
                  return [
                    item['title'] ?? 'Product',
                    qty.toString(),
                    price.toStringAsFixed(2),
                    (price * qty).toStringAsFixed(2),
                  ];
                }).toList(),
              ),

              // --- SUMMARY SECTION ---
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Spacer(flex: 2),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text('LKR $amount'),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Divider(color: PdfColors.grey200),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('GRAND TOTAL:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      color: primaryColor)),
                              pw.Text('LKR $amount',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- FOOTER ---
              pw.Spacer(),
              pw.Divider(color: primaryColor),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Thank you for choosing Aaliyah\'s Collection.',
                      style: pw.TextStyle(
                          fontStyle: pw.FontStyle.italic, fontSize: 10)),
                  pw.Text('Payment Method: Cash on Delivery',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated document. No signature required.',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ),
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
