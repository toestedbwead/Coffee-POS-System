import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'latte_components.dart';

class PaymentModalDialog extends StatefulWidget {
  final double totalAmount;
  final Function(String paymentMethod) onConfirm;

  const PaymentModalDialog({
    Key? key,
    required this.totalAmount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<PaymentModalDialog> createState() => _PaymentModalDialogState();
}

class _PaymentModalDialogState extends State<PaymentModalDialog> {
  String selectedMethod = 'Cash'; // 'Cash' or 'e-Wallet'
  double cashReceived = 0.0;
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _refController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default cash received to exact amount initially or 0
    cashReceived = widget.totalAmount;
    _cashController.text = cashReceived.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _updateCash(double amount) {
    setState(() {
      cashReceived = amount;
      _cashController.text = cashReceived.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double changeDue = cashReceived - widget.totalAmount;
    final bool isCashValid = cashReceived >= widget.totalAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Payment Method',
                    style: AppTypography.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Payment Method Tabs
              Row(
                children: [
                  Expanded(
                    child: _buildMethodTab(
                      title: 'Cash',
                      icon: Icons.payments_outlined,
                      isSelected: selectedMethod == 'Cash',
                      onTap: () {
                        setState(() => selectedMethod = 'Cash');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMethodTab(
                      title: 'e-Wallet',
                      icon: Icons.qr_code_scanner,
                      isSelected: selectedMethod == 'e-Wallet',
                      onTap: () {
                        setState(() => selectedMethod = 'e-Wallet');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Total Due Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount Due:',
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₱${widget.totalAmount.toStringAsFixed(2)}',
                      style: AppTypography.priceTag.copyWith(fontSize: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Conditional Content based on Method
              if (selectedMethod == 'Cash') ...[
                Text(
                  'Cash Received',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cashController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.h3.copyWith(color: AppColors.darkGray),
                  decoration: InputDecoration(
                    prefixText: '₱ ',
                    prefixStyle: AppTypography.h3.copyWith(color: AppColors.primary),
                    hintText: '0.00',
                  ),
                  onChanged: (value) {
                    setState(() {
                      cashReceived = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Quick Select Bills
                Text(
                  'Quick Select',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildQuickBillButton('Exact', widget.totalAmount),
                    _buildQuickBillButton('₱100', 100.0),
                    _buildQuickBillButton('₱200', 200.0),
                    _buildQuickBillButton('₱500', 500.0),
                    _buildQuickBillButton('₱1000', 1000.0),
                  ],
                ),
                const SizedBox(height: 28),

                // Change Summary Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCashValid ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCashValid ? AppColors.success.withValues(alpha: 0.5) : AppColors.error.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isCashValid ? 'Change Due' : 'Insufficient Cash',
                        style: AppTypography.labelMedium.copyWith(
                          color: isCashValid ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isCashValid
                            ? '₱${changeDue.toStringAsFixed(2)}'
                            : 'Need ₱${(widget.totalAmount - cashReceived).toStringAsFixed(2)} more',
                        style: AppTypography.h2.copyWith(
                          color: isCashValid ? AppColors.success : AppColors.error,
                          fontSize: isCashValid ? 32 : 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // e-Wallet Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mediumGray.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2, size: 50, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer QR Scan',
                              style: AppTypography.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ask the customer to scan your store GCash or Maya QR code and verify the successful transfer.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reference Number (Optional)',
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _refController,
                  style: AppTypography.bodyRegular,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 000123456789',
                    prefixIcon: Icon(Icons.tag, color: AppColors.primary),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 16),
                  LatteButton(
                    label: 'CONFIRM PAYMENT',
                    width: 200,
                    backgroundColor: (selectedMethod == 'Cash' && !isCashValid)
                        ? AppColors.mediumGray
                        : AppColors.success,
                    onPressed: (selectedMethod == 'Cash' && !isCashValid)
                        ? null
                        : () {
                            String methodStr = selectedMethod == 'Cash'
                                ? 'Cash'
                                : 'e-Wallet (${_refController.text.isNotEmpty ? "Ref: ${_refController.text}" : "GCash/Maya"})';
                            widget.onConfirm(methodStr);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mediumGray.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickBillButton(String label, double amount) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelMedium.copyWith(color: AppColors.primary),
      backgroundColor: AppColors.background,
      side: const BorderSide(color: AppColors.accent, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onPressed: () => _updateCash(amount),
    );
  }
}
