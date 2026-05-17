import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'latte_components.dart';

class SCPWDInputDialog extends StatefulWidget {
  final Function(String idNumber) onConfirm;
  final VoidCallback onCancel;

  const SCPWDInputDialog({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<SCPWDInputDialog> createState() => _SCPWDInputDialogState();
}

class _SCPWDInputDialogState extends State<SCPWDInputDialog> {
  final TextEditingController _idController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _validate(String value) {
    setState(() {
      // Basic validation: at least 5 characters for an ID
      _isValid = value.trim().length >= 5;
    });
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == 'CLEAR') {
        _idController.text = '';
      } else if (key == '⌫') {
        String current = _idController.text;
        if (current.isNotEmpty) {
          _idController.text = current.substring(0, current.length - 1);
        }
      } else if (key == 'SPACE') {
        _idController.text += ' ';
      } else {
        _idController.text += key;
      }
      _validate(_idController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 750, // Expanded width for beautiful Touch Keyboard layout
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.card_membership, size: 32, color: AppColors.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'SC / PWD Verification',
                      style: AppTypography.h2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'ID Number',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _idController,
                style: AppTypography.h3.copyWith(color: AppColors.darkGray, fontSize: 24),
                decoration: InputDecoration(
                  hintText: 'e.g. SC-2026-123456',
                  prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.primary, size: 28),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: _validate,
                autofocus: true,
              ),
              const SizedBox(height: 28),

              // On-Screen Touch Keyboard Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Touch Keyboard',
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildKeyboard(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 16),
                  LatteButton(
                    label: 'VERIFY & APPLY',
                    width: 200,
                    backgroundColor: _isValid ? AppColors.success : AppColors.mediumGray,
                    onPressed: _isValid
                        ? () {
                            widget.onConfirm(_idController.text.trim());
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final List<List<String>> rows = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-'],
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
      ['CLEAR', 'SC-', 'PWD-', 'SPACE'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((btn) {
              final bool isSpecial = btn == 'CLEAR' || btn == '⌫' || btn == 'SPACE' || btn == 'SC-' || btn == 'PWD-';
              final bool isPrefix = btn == 'SC-' || btn == 'PWD-';

              return Expanded(
                flex: btn == 'SPACE' ? 4 : (isSpecial ? 2 : 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btn == '⌫' || btn == 'CLEAR'
                          ? AppColors.secondary
                          : isPrefix
                              ? AppColors.accent
                              : AppColors.white,
                      foregroundColor: btn == '⌫' || btn == 'CLEAR' || isPrefix
                          ? AppColors.white
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: btn == '⌫' || btn == 'CLEAR' || isPrefix
                              ? Colors.transparent
                              : AppColors.mediumGray.withValues(alpha: 0.3),
                        ),
                      ),
                      elevation: btn == '⌫' || btn == 'CLEAR' || isPrefix ? 2 : 1,
                    ),
                    onPressed: () => _onKeyTap(btn),
                    child: Text(
                      btn,
                      style: AppTypography.labelLarge.copyWith(
                        color: btn == '⌫' || btn == 'CLEAR' || isPrefix
                            ? AppColors.white
                            : AppColors.primary,
                        fontSize: isSpecial ? 14 : 18,
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
}
