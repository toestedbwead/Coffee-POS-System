import 'package:flutter/material.dart';
import '../data/database.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import '../widgets/latte_components.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final OrderService _orderService = OrderService();
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  
  // Touch-Friendly Filter States
  String _dateFilter = 'All Time'; // 'Today', 'This Month', 'All Time'
  String _methodFilter = 'All Methods'; // 'All Methods', 'Cash', 'e-Wallet'
  String _statusFilter = 'All Status'; // 'All Status', 'Completed', 'Voided'

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _orderService.getOrderHistory();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  Future<void> _voidOrder(String orderId) async {
    final TextEditingController pinController = TextEditingController();
    bool isPinValid = false;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security, size: 32, color: AppColors.error),
                      const SizedBox(width: 16),
                      Text(
                        'Admin Authorization',
                        style: AppTypography.h2.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Voiding a transaction requires an Admin PIN. Please enter your 4-digit PIN below (Default: 1234).',
                    style: AppTypography.bodyRegular,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    style: AppTypography.h3.copyWith(letterSpacing: 8, fontSize: 28),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '••••',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isPinValid = value.trim() == '1234';
                      });
                    },
                    autofocus: true,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      LatteButton(
                        label: 'AUTHORIZE VOID',
                        width: 180,
                        backgroundColor: isPinValid ? AppColors.error : AppColors.mediumGray,
                        onPressed: isPinValid ? () => Navigator.pop(context, true) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (confirm == true) {
      final success = await _orderService.voidOrder(orderId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction successfully voided.'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to void transaction.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showOrderDetails(Map<String, dynamic> order) async {
    final items = await _db.getOrderItems(order['id'] as String);
    final bool isVoided = order['status'] == 'Voided';
    final bool scPwdApplied = (order['scPwdApplied'] as int?) == 1;
    final double discountAmount = (order['discountAmount'] as double?) ?? 0.0;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt Details',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${order['id']}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Scrollable Body (Badges, Items List, Totals Summary Box)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isVoided ? AppColors.error : AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['status'] as String,
                              style: AppTypography.labelMedium.copyWith(color: AppColors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['paymentMethod'] as String,
                              style: AppTypography.labelMedium.copyWith(color: AppColors.white),
                            ),
                          ),
                          if (scPwdApplied) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SC/PWD Applied',
                                style: AppTypography.labelMedium.copyWith(color: AppColors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Items List
                      Text(
                        'Itemized Breakdown',
                        style: AppTypography.labelMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ListTile(
                              title: Text(
                                '${item['quantity']}x ${item['productName']}',
                                style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${item['selectedSize']} • ${item['selectedTemperature']}\nAdd-ons: ${item['selectedAddOns'].toString().isEmpty ? "None" : item['selectedAddOns']}',
                                style: AppTypography.bodySmall,
                              ),
                              trailing: Text(
                                '₱${(item['itemTotal'] as double).toStringAsFixed(2)}',
                                style: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Totals Summary Box
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal:', style: AppTypography.bodyRegular),
                                Text('₱${(order['subtotal'] as double).toStringAsFixed(2)}', style: AppTypography.bodyRegular),
                              ],
                            ),
                            if (scPwdApplied) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('SC/PWD Discount:', style: AppTypography.bodyRegular.copyWith(color: AppColors.accent)),
                                  Text('-₱${discountAmount.toStringAsFixed(2)}', style: AppTypography.bodyRegular.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax (12% VAT):', style: AppTypography.bodySmall),
                                Text(scPwdApplied ? 'VAT Exempt' : '₱${(order['taxAmount'] as double).toStringAsFixed(2)}', style: AppTypography.bodySmall),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.mediumGray),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Paid:', style: AppTypography.h3),
                                Text(
                                  '₱${(order['total'] as double).toStringAsFixed(2)}',
                                  style: AppTypography.priceTag.copyWith(fontSize: 28),
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
              const SizedBox(height: 28),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: LatteButton(
                  label: 'CLOSE',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      final orderDate = DateTime.parse(order['timestamp'] as String).toLocal();
      final now = DateTime.now();

      // Date Filter
      if (_dateFilter == 'Today') {
        if (orderDate.year != now.year || orderDate.month != now.month || orderDate.day != now.day) {
          return false;
        }
      } else if (_dateFilter == 'This Month') {
        if (orderDate.year != now.year || orderDate.month != now.month) {
          return false;
        }
      }

      // Method Filter
      final method = order['paymentMethod'].toString().toLowerCase();
      if (_methodFilter == 'Cash' && !method.contains('cash')) return false;
      if (_methodFilter == 'e-Wallet' && !method.contains('e-wallet')) return false;

      // Status Filter
      final status = order['status'].toString();
      if (_statusFilter == 'Completed' && status != 'Completed') return false;
      if (_statusFilter == 'Voided' && status != 'Voided') return false;

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // MINIMALIST DESKTOP HEADER (Crema Background)
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Back Button & Title
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.primary),
                        label: Text('Back to Cashier', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history_rounded, color: AppColors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Transaction History',
                        style: AppTypography.h1.copyWith(color: AppColors.primary, fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dropdown Filters Row (Crema Background)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 1)),
              ),
              child: Row(
                children: [
                  _buildDropdownFilter(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    value: _dateFilter,
                    items: ['All Time', 'Today', 'This Month'],
                    onChanged: (val) { if (val != null) setState(() => _dateFilter = val); },
                  ),
                  const SizedBox(width: 20),
                  _buildDropdownFilter(
                    label: 'Method',
                    icon: Icons.payment,
                    value: _methodFilter,
                    items: ['All Methods', 'Cash', 'e-Wallet'],
                    onChanged: (val) { if (val != null) setState(() => _methodFilter = val); },
                  ),
                  const SizedBox(width: 20),
                  _buildDropdownFilter(
                    label: 'Status',
                    icon: Icons.flag_outlined,
                    value: _statusFilter,
                    items: ['All Status', 'Completed', 'Voided'],
                    onChanged: (val) { if (val != null) setState(() => _statusFilter = val); },
                  ),
                  const Spacer(),
                  // Quick Reset Button
                  if (_dateFilter != 'All Time' || _methodFilter != 'All Methods' || _statusFilter != 'All Status')
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, color: AppColors.accent),
                      label: Text('Reset Filters', style: AppTypography.labelMedium.copyWith(color: AppColors.accent)),
                      onPressed: () {
                        setState(() {
                          _dateFilter = 'All Time';
                          _methodFilter = 'All Methods';
                          _statusFilter = 'All Status';
                        });
                      },
                    ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions match the selected filters.',
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.mediumGray),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final bool isVoided = order['status'] == 'Voided';
                            final bool scPwdApplied = (order['scPwdApplied'] as int?) == 1;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: AppColors.background,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isVoided
                                      ? AppColors.error.withValues(alpha: 0.4)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Icon Badge
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isVoided
                                            ? AppColors.error.withValues(alpha: 0.1)
                                            : AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        isVoided ? Icons.block : Icons.receipt_long_rounded,
                                        size: 32,
                                        color: isVoided ? AppColors.error : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Order Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Order #${order['id'].toString().substring(0, 8)}...',
                                                style: AppTypography.h3.copyWith(
                                                  color: isVoided ? AppColors.mediumGray : AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isVoided ? AppColors.error : AppColors.success,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  order['status'] as String,
                                                  style: AppTypography.labelSmall.copyWith(color: AppColors.white),
                                                ),
                                              ),
                                              if (scPwdApplied) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.accent,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'SC/PWD',
                                                    style: AppTypography.labelSmall.copyWith(color: AppColors.white),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Date: ${DateTime.parse(order['timestamp'] as String).toLocal().toString().substring(0, 16)} • Paid via ${order['paymentMethod']}',
                                            style: AppTypography.bodySmall.copyWith(color: AppColors.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Total Price
                                    Text(
                                      '₱${(order['total'] as double).toStringAsFixed(2)}',
                                      style: AppTypography.priceTag.copyWith(
                                        color: isVoided ? AppColors.mediumGray : AppColors.accent,
                                        fontSize: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 24),

                                    // Actions
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.visibility_rounded, size: 18),
                                      label: const Text('Details'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        textStyle: AppTypography.labelSmall,
                                      ),
                                      onPressed: () => _showOrderDetails(order),
                                    ),
                                    if (!isVoided) ...[
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.cancel_outlined, size: 18),
                                        label: const Text('Void'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: AppColors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          textStyle: AppTypography.labelSmall,
                                          elevation: 0,
                                        ),
                                        onPressed: () => _voidOrder(order['id'] as String),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text('$label:', style: AppTypography.labelSmall.copyWith(color: AppColors.darkGray)),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

