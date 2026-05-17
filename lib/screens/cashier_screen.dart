import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_menu.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/latte_components.dart';
import '../widgets/payment_modal.dart';
import '../widgets/scpwd_dialog.dart';
import '../widgets/receipt_preview.dart';
import 'history_screen.dart';


class CashierScreen extends StatefulWidget {
  const CashierScreen({Key? key}) : super(key: key);

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  String selectedCategoryId = '1'; // Default to Espresso

  // Get products for selected category
  List<Product> getDisplayProducts() {
    return getProductsByCategory(selectedCategoryId);
  }

  // Add item to order
  void addToOrder(Product product) {
    final orderProvider = context.read<OrderProvider>();
    showDialog(
      context: context,
      builder: (context) => ProductSelectionDialog(
        product: product,
        onAdd: (OrderItem item) {
          orderProvider.addItem(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  // Remove item from order
  void removeFromOrder(int index) {
    context.read<OrderProvider>().removeItem(index);
  }

  void clearOrder() {
    context.read<OrderProvider>().clearOrder();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orderItems = orderProvider.items;
    final subtotal = orderProvider.subtotal;
    final tax = orderProvider.vat;
    final total = orderProvider.total;
    final discount = orderProvider.discount;
    final isSCPWD = orderProvider.applySCPWD;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Latte POS'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_sharp, size: 28),
            tooltip: 'Transaction History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: Row(
        children: [
          // LEFT COLUMN: Categories
          Container(
            width: 120,
            color: AppColors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Categories',
                    style: AppTypography.labelMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mockCategories.length,
                    itemBuilder: (context, index) {
                      final category = mockCategories[index];
                      final isSelected = category.id == selectedCategoryId;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  category.name,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.primary,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // DIVIDER
          const VerticalDivider(width: 1),

          // CENTER COLUMN: Products Grid
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    getCategoryById(selectedCategoryId)?.name ?? 'Products',
                    style: AppTypography.h2,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: getDisplayProducts().length,
                    itemBuilder: (context, index) {
                      final product = getDisplayProducts()[index];
                      return ItemCard(
                        name: product.name,
                        description: product.description,
                        price: '₱${product.basePrice}',
                        onTap: () => addToOrder(product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // DIVIDER
          const VerticalDivider(width: 1),

          // RIGHT COLUMN: Order Summary
          Container(
            width: 300,
            color: AppColors.background,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Order',
                            style: AppTypography.h3
                                .copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          if (orderItems.isEmpty)
                            Center(
                              child: Text(
                                'No items yet',
                                style: AppTypography.bodyRegular
                                    .copyWith(color: AppColors.primary),
                              ),
                            )
                          else
                            ...List.generate(
                              orderItems.length,
                              (index) {
                                final item = orderItems[index];
                                return OrderItemCard(
                                  item: item,
                                  onRemove: () => removeFromOrder(index),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OrderSummaryCard(
                    itemCount: orderItems.length,
                    subtotal: subtotal,
                    tax: tax,
                    total: total,
                    discount: discount,
                    isSCPWD: isSCPWD,
                    onToggleSCPWD: (value) {
                      if (value) {
                        showDialog(
                          context: context,
                          builder: (context) => SCPWDInputDialog(
                            onConfirm: (idNumber) {
                              Navigator.pop(context);
                              orderProvider.toggleSCPWD(true, id: idNumber);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('SC/PWD Discount applied (ID: $idNumber)'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      } else {
                        orderProvider.toggleSCPWD(false);
                      }
                    },
                    onCheckout: () {
                      if (orderItems.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot checkout an empty order.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) => PaymentModalDialog(
                          totalAmount: total,
                          onConfirm: (paymentMethod) async {
                            Navigator.pop(context); // Close modal
                            final order = await orderProvider.processCheckout(paymentMethod);
                            if (order != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => ReceiptPreviewModal(
                                    order: order,
                                    paymentMethod: paymentMethod,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to save order.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                    onClear: clearOrder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Product Selection Dialog (Size, Temperature, Add-ons)
class ProductSelectionDialog extends StatefulWidget {
  final Product product;
  final Function(OrderItem) onAdd;

  const ProductSelectionDialog({
    Key? key,
    required this.product,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  late String selectedSize;
  late String selectedTemperature;
  List<AddOn> selectedAddOns = [];

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.availableSizes.first;
    selectedTemperature = widget.product.availableTemperatures.first;
  }

  double getDialogItemPrice() {
    double price = widget.product.getPriceForSize(selectedSize);
    double addOnsTotal =
        selectedAddOns.fold(0, (sum, addOn) => sum + addOn.price);
    return price + addOnsTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.product.name,
                style: AppTypography.h2,
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.description,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 24),

              // SIZE SELECTION
              Text(
                'Size',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.product.availableSizes.map((size) {
                  final isSelected = size == selectedSize;
                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedSize = size);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // TEMPERATURE SELECTION
              Text(
                'Temperature',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: widget.product.availableTemperatures.map((temp) {
                  final isSelected = temp == selectedTemperature;
                  return ChoiceChip(
                    label: Text(temp),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedTemperature = temp);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ADD-ONS SELECTION
              Text(
                'Add-ons (Optional)',
                style: AppTypography.labelMedium,
              ),
              const SizedBox(height: 8),
              ...widget.product.addOns.map((addOn) {
                final isSelected = selectedAddOns.contains(addOn);
                return CheckboxListTile(
                  title: Text(addOn.name),
                  subtitle: Text('₱${addOn.price}'),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedAddOns.add(addOn);
                      } else {
                        selectedAddOns.remove(addOn);
                      }
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 24),

              // Price & Buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: AppTypography.labelMedium,
                        ),
                        Text(
                          '₱${getDialogItemPrice().toStringAsFixed(2)}',
                          style: AppTypography.priceTag,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        LatteButton(
                          label: 'ADD TO ORDER',
                          onPressed: () {
                            final newItem = OrderItem(
                              id: DateTime.now().toString(),
                              product: widget.product,
                              selectedSize: selectedSize,
                              selectedTemperature: selectedTemperature,
                              selectedAddOns: selectedAddOns,
                              quantity: 1,
                            );
                            widget.onAdd(newItem);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Order Item Display Card (in right column)
class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onRemove;

  const OrderItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.darkGray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.selectedSize} • ${item.selectedTemperature}',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onRemove,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          if (item.selectedAddOns.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.selectedAddOns.map((a) => a.name).join(', '),
              style: AppTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'x${item.quantity}',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.white),
              ),
              Text(
                '₱${item.getTotal().toStringAsFixed(2)}',
                style:
                    AppTypography.labelMedium.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}