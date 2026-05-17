import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// LatteButton - Primary Action Button
class LatteButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;

  const LatteButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

// CategoryPill - Category Selection Chip
class CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryPill({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.mediumGray,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ItemCard - Product Display Card
class ItemCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final VoidCallback onTap;
  final String? imageUrl;
  final bool isAvailable;

  final String code;

  const ItemCard({
    Key? key,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.onTap,
    this.imageUrl,
    this.isAvailable = true,
  }) : super(key: key);

  Color _getBadgeColor(String code) {
    return AppColors.primary; // Espresso for ALL categories!
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Card(
            color: isAvailable ? AppColors.background : AppColors.lightGray,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: SKU Code Badge & Price Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(code),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          code.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        price,
                        style: AppTypography.priceTag.copyWith(color: AppColors.accent, fontSize: 16),
                      ),
                    ],
                  ),
                  // Bottom Row: Item Name
                  Text(
                    name,
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (!isAvailable)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Text(
                      'UNAVAILABLE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// OrderSummaryCard - Right Column Summary
class OrderSummaryCard extends StatelessWidget {
  final int itemCount;
  final double subtotal;
  final double tax;
  final double total;
  final double discount;
  final bool isSCPWD;
  final Function(bool value) onToggleSCPWD;
  final VoidCallback onCheckout;
  final VoidCallback onClear;

  const OrderSummaryCard({
    Key? key,
    required this.itemCount,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.discount,
    required this.isSCPWD,
    required this.onToggleSCPWD,
    required this.onCheckout,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Items Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items:',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.darkGray),
                ),
                Text(
                  '$itemCount',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.darkGray),
                ),
                Text(
                  '₱${subtotal.toStringAsFixed(2)}',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.darkGray),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // SC/PWD Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SC/PWD (20% Off):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkGray),
                ),
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: isSCPWD,
                    onChanged: onToggleSCPWD,
                    activeColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (isSCPWD) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SC/PWD Discount:',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.accent),
                  ),
                  Text(
                    '-₱${discount.toStringAsFixed(2)}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            // Tax
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (12% VAT):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkGray),
                ),
                Text(
                  isSCPWD ? 'VAT Exempt' : '₱${tax.toStringAsFixed(2)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isSCPWD ? AppColors.accent : AppColors.darkGray,
                    fontWeight: isSCPWD ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: AppColors.primary.withValues(alpha: 0.15), thickness: 1),
            const SizedBox(height: 8),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTypography.h3.copyWith(color: AppColors.primary),
                ),
                Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: AppTypography.priceTag.copyWith(
                    color: AppColors.primary,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Buttons Side-by-Side
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'CLEAR',
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: LatteButton(
                    label: 'CHECKOUT',
                    onPressed: onCheckout,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}