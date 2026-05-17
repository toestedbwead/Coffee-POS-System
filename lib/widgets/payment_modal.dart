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
    // Default cash received to exact amount initially
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

  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'C') {
        cashReceived = 0.0;
        _cashController.text = '0.00';
      } else if (value == '⌫') {
        String current = _cashController.text;
        // If current is the default exact amount, clear it to 0
        if (current == widget.totalAmount.toStringAsFixed(2)) {
          cashReceived = 0.0;
          _cashController.text = '0.00';
          return;
        }
        if (current.isNotEmpty && current != '0.00') {
          current = current.substring(0, current.length - 1);
          if (current.isEmpty || current == '0.') {
            current = '0.00';
            cashReceived = 0.0;
          } else {
            cashReceived = double.tryParse(current) ?? 0.0;
          }
          _cashController.text = current;
        }
      } else if (value == 'Exact') {
        cashReceived = widget.totalAmount;
        _cashController.text = cashReceived.toStringAsFixed(2);
      } else {
        // Tapping numbers, 00, or dot
        String current = _cashController.text;
        if (current == '0.00' || current == '0' || current == widget.totalAmount.toStringAsFixed(2)) {
          current = value == '.' ? '0.' : value;
        } else {
          // Prevent multiple decimals
          if (value == '.' && current.contains('.')) return;
          // Limit decimal places to 2
          if (current.contains('.')) {
            final parts = current.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return; // already 2 decimal places
          }
          current += value;
        }
        _cashController.text = current;
        cashReceived = double.tryParse(current) ?? 0.0;
      }
    });
  }

  void _onEWalletKeyTap(String key) {
    setState(() {
      if (key == 'C') {
        _refController.text = '';
      } else if (key == '⌫') {
        String current = _refController.text;
        if (current.isNotEmpty) {
          _refController.text = current.substring(0, current.length - 1);
        }
      } else {
        _refController.text += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double changeDue = cashReceived - widget.totalAmount;
    final bool isCashValid = cashReceived >= widget.totalAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 750, // Expanded width for beautiful 2-column Cash layout with Numpad
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Input, Quick Bills, Change Box
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cash Received',
                            style: AppTypography.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cashController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTypography.h3.copyWith(color: AppColors.darkGray, fontSize: 26),
                            decoration: InputDecoration(
                              prefixText: '₱ ',
                              prefixStyle: AppTypography.h3.copyWith(color: AppColors.primary, fontSize: 26),
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
                            'Quick Select Bills',
                            style: AppTypography.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
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
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Right Column: On-Screen Touch Numpad
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Touch Numpad',
                              style: AppTypography.labelMedium,
                            ),
                            const SizedBox(height: 12),
                            _buildNumpadGrid(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // e-Wallet 2-Column Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: QR Scan Box + Reference Input
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                        'Ask customer to scan your store GCash/Maya QR code and verify transfer.',
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
                            style: AppTypography.h3.copyWith(color: AppColors.darkGray, fontSize: 22),
                            decoration: InputDecoration(
                              hintText: 'e.g. 000123456789',
                              prefixIcon: const Icon(Icons.tag, color: AppColors.primary, size: 26),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 28),
                    // Right Column: On-Screen Touch Keyboard for e-Wallet
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'e-Wallet Touch Keyboard',
                              style: AppTypography.labelMedium,
                            ),
                            const SizedBox(height: 12),
                            _buildEWalletKeyboard(),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                    width: 220,
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

  Widget _buildNumpadGrid() {
    final List<List<String>> rows = [
      ['7', '8', '9', '⌫'],
      ['4', '5', '6', 'C'],
      ['1', '2', '3', '.'],
      ['0', '00', 'Exact', ''],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: row.map((btn) {
              if (btn.isEmpty) {
                return Expanded(child: const SizedBox());
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn == 'C' || btn == '⌫'
                          ? AppColors.secondary
                          : btn == 'Exact'
                              ? AppColors.accent
                              : AppColors.white,
                      foregroundColor: btn == 'C' || btn == '⌫' || btn == 'Exact'
                          ? AppColors.white
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: btn == 'C' || btn == '⌫' || btn == 'Exact'
                              ? Colors.transparent
                              : AppColors.mediumGray.withValues(alpha: 0.3),
                        ),
                      ),
                      elevation: btn == 'C' || btn == '⌫' || btn == 'Exact' ? 2 : 1,
                    ),
                    onPressed: () => _onNumpadTap(btn),
                    child: Text(
                      btn,
                      style: AppTypography.h3.copyWith(
                        color: btn == 'C' || btn == '⌫' || btn == 'Exact'
                            ? AppColors.white
                            : AppColors.primary,
                        fontSize: btn == 'Exact' ? 18 : 22,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEWalletKeyboard() {
    final List<List<String>> rows = [
      ['7', '8', '9', '⌫'],
      ['4', '5', '6', 'C'],
      ['1', '2', '3', '00'],
      ['0', 'GCash-', 'Maya-', 'QR-'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: row.map((btn) {
              final bool isSpecial = btn == 'C' || btn == '⌫';
              final bool isPrefix = btn == 'GCash-' || btn == 'Maya-' || btn == 'QR-';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSpecial
                          ? AppColors.secondary
                          : isPrefix
                              ? AppColors.accent
                              : AppColors.white,
                      foregroundColor: isSpecial || isPrefix
                          ? AppColors.white
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSpecial || isPrefix
                              ? Colors.transparent
                              : AppColors.mediumGray.withValues(alpha: 0.3),
                        ),
                      ),
                      elevation: isSpecial || isPrefix ? 2 : 1,
                    ),
                    onPressed: () => _onEWalletKeyTap(btn),
                    child: Text(
                      btn,
                      style: AppTypography.h3.copyWith(
                        color: isSpecial || isPrefix
                            ? AppColors.white
                            : AppColors.primary,
                        fontSize: isPrefix ? 14 : 22,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
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
