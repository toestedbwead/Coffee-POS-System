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

  const ItemCard({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    required this.onTap,
    this.imageUrl,
    this.isAvailable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Card(
            color: isAvailable ? AppColors.white : AppColors.lightGray,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: imageUrl != null
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : Icon(
                          Icons.coffee,
                          size: 48,
                          color: AppColors.accent,
                        ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTypography.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: AppTypography.priceTag,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: AppTypography.h3.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 16),
            // Items Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items:',
                  style: AppTypography.bodyRegular
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  '$itemCount',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal:',
                  style: AppTypography.bodyRegular
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  '₱${subtotal.toStringAsFixed(2)}',
                  style: AppTypography.bodyRegular
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // SC/PWD Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SC/PWD (20% Off):',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.white),
                ),
                Switch(
                  value: isSCPWD,
                  onChanged: onToggleSCPWD,
                  activeColor: AppColors.accent,
                ),
              ],
            ),
            if (isSCPWD) ...[
              const SizedBox(height: 4),
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
            const SizedBox(height: 8),
            // Tax
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (12% VAT):',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.white),
                ),
                Text(
                  isSCPWD ? 'VAT Exempt' : '₱${tax.toStringAsFixed(2)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isSCPWD ? AppColors.accent : AppColors.white,
                    fontWeight: isSCPWD ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.accent, thickness: 1),
            const SizedBox(height: 12),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTypography.h3.copyWith(color: AppColors.white),
                ),
                Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: AppTypography.priceTag.copyWith(
                    color: AppColors.accent,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Buttons
            SizedBox(
              width: double.infinity,
              child: LatteButton(
                label: 'CHECKOUT',
                onPressed: onCheckout,
                backgroundColor: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.accent, width: 2),
                ),
                child: Text(
                  'CLEAR ORDER',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}