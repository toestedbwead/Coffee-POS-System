import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';


class ReceiptPreviewModal extends StatelessWidget {
  final Order order;
  final String paymentMethod;

  const ReceiptPreviewModal({
    super.key,
    required this.order,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final String timestampStr = order.timestamp.toLocal().toString().substring(0, 16);
    final String orNumber = 'OR# ${order.id.substring(0, 12).toUpperCase()}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent, // transparent so the paper roll looks like it's floating!
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6), // Warm off-white receipt paper color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thermal Receipt Paper Header (FIXED!)
            Padding(
              padding: const EdgeInsets.only(top: 28, left: 28, right: 28, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PROJECT LATTE COFFEE',
                    style: TextStyle(fontFamily: 'Courier', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '123 Coffee Street, Diliman\nQuezon City, Metro Manila\nVAT REG TIN: 123-456-789-00000',
                    style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(orNumber, style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(timestampStr, style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CASHIER: Terminal 01', style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                      Text(order.scPwdId != null ? 'SC/PWD: ${order.scPwdId}' : 'CUSTOMER: Guest', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                ],
              ),
            ),

            // Thermal Receipt Items List (COMPACT & CONSTRAINED!)
            Container(
              constraints: const BoxConstraints(maxHeight: 160), // Perfectly fits 3-4 items, scrolls only if more!
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                              Text(
                                '₱${item.getTotal().toStringAsFixed(2)}',
                                style: const TextStyle(fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '   ${item.selectedSize.toUpperCase()} • ${item.selectedTemperature.toUpperCase()}',
                            style: const TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.black87),
                          ),
                          if (item.selectedAddOns != null && item.selectedAddOns!.isNotEmpty)
                            Text(
                              '   Add-ons: ${item.selectedAddOns!.map((a) => a.name).join(", ")}',
                              style: const TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.black54),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Thermal Receipt Totals & QR Code (FIXED!)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 28, right: 28, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('SUBTOTAL (VAT Excl):', style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                      Text('₱${order.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  if (order.scPwdApplied) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SC/PWD DISCOUNT (20%):', style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                        Text('-₱${order.discountAmount.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('12% VAT:', style: TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                      Text(order.scPwdApplied ? 'VAT Exempt' : '₱${order.taxAmount.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL AMOUNT DUE:', style: TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('₱${order.total.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PAID VIA (${paymentMethod.split(" ")[0]}):', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                      Text('₱${order.total.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Courier', fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                  const SizedBox(height: 16),

                  // Footer Barcode / Message
                  const Text('THIS SERVES AS AN OFFICIAL RECEIPT', style: TextStyle(fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 4),
                  const Text('Thank you for having coffee with us!', style: TextStyle(fontFamily: 'Courier', fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 16),
                  const Icon(Icons.qr_code_2, size: 64, color: Colors.black),
                  const SizedBox(height: 4),
                  Text(order.id.substring(0, 16), style: const TextStyle(fontFamily: 'Courier', fontSize: 10, color: Colors.black54)),
                ],
              ),
            ),

          // Bottom Action Bar (Dark background simulating the POS printer dock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.darkGray,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.mediumGray),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CLOSE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('SAVE PDF', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await _savePdfReceiptDirectly(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.print, size: 20),
                      label: const Text('PRINT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await _printPdfReceipt(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  pw.Document _generatePdfDocument() {
    final String timestampStr = order.timestamp.toLocal().toString().substring(0, 16);
    final String orNumber = 'OR# ${order.id.substring(0, 12).toUpperCase()}';

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // 80mm thermal roll format!
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('PROJECT LATTE COFFEE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('123 Coffee Street, Diliman\nQuezon City, Metro Manila\nVAT REG TIN: 123-456-789-00000', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 12),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(orNumber, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(timestampStr, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CASHIER: Terminal 01', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(order.scPwdId != null ? 'SC/PWD: ${order.scPwdId}' : 'CUSTOMER: Guest', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 12),

              // Items
              ...order.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(child: pw.Text('${item.quantity}x ${item.product.name}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold))),
                          pw.Text('PHP ${item.getTotal().toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('   ${item.selectedSize.toUpperCase()} | ${item.selectedTemperature.toUpperCase()}', style: const pw.TextStyle(fontSize: 9)),
                      if (item.selectedAddOns != null && item.selectedAddOns!.isNotEmpty)
                        pw.Text('   Add-ons: ${item.selectedAddOns!.map((a) => a.name).join(", ")}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 12),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('SUBTOTAL (VAT Excl):', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('PHP ${order.subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              if (order.scPwdApplied) ...[
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('SC/PWD DISCOUNT (20%):', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('-PHP ${order.discountAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('12% VAT:', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(order.scPwdApplied ? 'VAT Exempt' : 'PHP ${order.taxAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL AMOUNT DUE:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('PHP ${order.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PAID VIA (${paymentMethod.split(" ")[0]}):', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('PHP ${order.total.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 12),

              pw.Text('THIS SERVES AS AN OFFICIAL RECEIPT', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text('Thank you for having coffee with us!', style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 16),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: order.id,
                width: 60,
                height: 60,
              ),
              pw.SizedBox(height: 4),
              pw.Text(order.id.substring(0, 16), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ],
          );
        },
      ),
    );

    return doc;
  }

  Future<void> _printPdfReceipt(BuildContext context) async {
    final doc = _generatePdfDocument();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Receipt_${order.id.substring(0, 8)}',
    );
  }

  Future<void> _savePdfReceiptDirectly(BuildContext context) async {
    final doc = _generatePdfDocument();
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Receipt_${order.id.substring(0, 8)}.pdf',
    );
  }
}

