import 'package:flutter/material.dart';
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
            // Thermal Receipt Paper Body (Scrollable!)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(

                mainAxisSize: MainAxisSize.min,
                children: [
                  // Store Header
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

                  // Receipt Metadata
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
                  const SizedBox(height: 16),

                  // Itemized Lines
                  ...order.items.map((item) {
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
                  }),

                  const SizedBox(height: 8),
                  const Text('----------------------------------------', style: TextStyle(fontFamily: 'Courier', color: Colors.black54)),
                  const SizedBox(height: 16),

                  // Totals Calculation
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
          ), // Closing Flexible

          // Bottom Action Bar (Dark background simulating the POS printer dock)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                      child: const Text('CLOSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.print, size: 24),
                      label: const Text('PRINT ESC/POS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.print, color: Colors.white),
                                SizedBox(width: 12),
                                Text('ESC/POS raw buffer sent to thermal printer port USB001.'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
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
}
