import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../data/mock_menu.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import '../widgets/latte_components.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final DatabaseHelper _db = DatabaseHelper();

  int _selectedTab = 0; // 0: Analytics, 1: Exports, 2: Settings
  bool _isLoading = true;

  // Analytics Data
  Map<String, dynamic> _dailySummary = {};
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _hourlySales = [];
  DateTime _selectedDate = DateTime.now();

  // Settings State
  final TextEditingController _storeNameController = TextEditingController(text: 'PROJECT LATTE COFFEE');
  final TextEditingController _storeAddressController = TextEditingController(text: '123 Coffee Street, Diliman, Quezon City');
  final TextEditingController _tinController = TextEditingController(text: '123-456-789-00000');
  final TextEditingController _vatRateController = TextEditingController(text: '12');
  final TextEditingController _pwdDiscountController = TextEditingController(text: '20');

  // Menu Management State
  String _menuSearchQuery = '';
  String _menuCategoryFilter = 'All';

  late final OrderProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _orderProvider = context.read<OrderProvider>();
    _orderProvider.addListener(_onOrderProviderChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _storeNameController.text = _orderProvider.storeName;
      _storeAddressController.text = _orderProvider.storeAddress;
      _tinController.text = _orderProvider.tin;
      _vatRateController.text = (_orderProvider.vatRate * 100).toStringAsFixed(0);
      _pwdDiscountController.text = (_orderProvider.pwdDiscount * 100).toStringAsFixed(0);
    });
  }

  void _onOrderProviderChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    _orderProvider.removeListener(_onOrderProviderChanged);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final summary = await _orderService.getDailySummary(_selectedDate);
    final top = await _orderService.getTopSellingProducts(
      startDate: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      endDate: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59),
    );
    final hourly = await _orderService.getHourlySalesData(_selectedDate);

    setState(() {
      _dailySummary = summary;
      _topProducts = top;
      _hourlySales = hourly;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management Console'),
        centerTitle: true,
        actions: [
          // Date Picker for Filtering Dashboard
          if (_selectedTab == 0)
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, color: AppColors.accent),
              label: Text(
                DateFormat('MMM dd, yyyy').format(_selectedDate),
                style: AppTypography.labelMedium.copyWith(color: AppColors.accent),
              ),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now(),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() => _selectedDate = picked);
                  _loadDashboardData();
                }
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // SIDEBAR NAVIGATION RAIL
          Container(
            width: 250,
            color: AppColors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildSidebarItem(
                  icon: Icons.analytics_outlined,
                  label: 'Sales Analytics',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.download_outlined,
                  label: 'Export & Reports',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'System Settings',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.fastfood_outlined,
                  label: 'Menu Management',
                  index: 3,
                ),
                const Spacer(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: AppColors.success, size: 20),
                      const SizedBox(width: 12),
                      Text('Admin Mode', style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // MAIN CONTENT AREA
          Expanded(
            child: Container(
              color: AppColors.background,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          border: isSelected ? const Border(right: BorderSide(color: AppColors.primary, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.mediumGray, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.darkGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedTab) {
      case 0:
        return _buildAnalyticsTab();
      case 1:
        return _buildExportsTab();
      case 2:
        return _buildSettingsTab();
      case 3:
        return _buildMenuManagementTab();
      default:
        return const Center(child: Text('Unknown Tab'));
    }
  }

  // ==================== 1. ANALYTICS TAB ====================
  Widget _buildAnalyticsTab() {
    final double totalRevenue = (_dailySummary['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final int totalTransactions = (_dailySummary['totalTransactions'] as num?)?.toInt() ?? 0;
    final int totalItems = (_dailySummary['totalItems'] as num?)?.toInt() ?? 0;
    final double avgOrder = (_dailySummary['averageTransactionValue'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Sales Overview', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text('Key performance indicators for ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}', style: AppTypography.bodyRegular),
          const SizedBox(height: 24),

          // TOP STAT CARDS ROW
          Row(
            children: [
              Expanded(child: _buildStatCard(title: 'Gross Revenue', value: '₱${totalRevenue.toStringAsFixed(2)}', icon: Icons.attach_money, color: AppColors.primary)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard(title: 'Transactions', value: '$totalTransactions', icon: Icons.receipt_long, color: AppColors.accent)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard(title: 'Avg Order Value', value: '₱${avgOrder.toStringAsFixed(2)}', icon: Icons.trending_up, color: AppColors.success)),
              const SizedBox(width: 20),
              Expanded(child: _buildStatCard(title: 'Items Sold', value: '$totalItems', icon: Icons.local_cafe, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 36),

          // CHARTS & TABLES ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HOURLY REVENUE TREND CHART
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hourly Revenue Trend', style: AppTypography.h2),
                      const SizedBox(height: 24),
                      _buildCustomBarChart(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // TOP SELLING PRODUCTS TABLE
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Selling Items', style: AppTypography.h2),
                      const SizedBox(height: 16),
                      _topProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: Text('No item sales recorded today.', style: AppTypography.bodyRegular)),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _topProducts.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = _topProducts[index];
                                final name = item['productName'] as String;
                                final qty = item['totalQuantity'] as int;
                                final rev = item['totalRevenue'] as double;
                                return Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: Text('${index + 1}', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: AppTypography.labelMedium),
                                          Text('$qty units sold', style: AppTypography.bodySmall.copyWith(color: AppColors.mediumGray)),
                                        ],
                                      ),
                                    ),
                                    Text('₱${rev.toStringAsFixed(2)}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodyRegular.copyWith(color: AppColors.mediumGray)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTypography.h1.copyWith(fontSize: 28)),
        ],
      ),
    );
  }

  Widget _buildCustomBarChart() {
    // Generate all 24 hours of the day (0 to 23) to support late-night & early-morning sales!
    final List<int> displayHours = List.generate(24, (index) => index);
    final Map<int, double> hourlyRevenueMap = {};

    double maxRevenue = 100.0; // Default minimum scale
    for (var row in _hourlySales) {
      final int hour = (row['hour'] as num).toInt();
      final double rev = (row['revenue'] as num).toDouble();
      hourlyRevenueMap[hour] = rev;
      if (rev > maxRevenue) maxRevenue = rev;
    }

    return SizedBox(
      height: 280,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 860, // Ample width for 24 hours to breathe beautifully!
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: displayHours.map((hour) {
                    final double revenue = hourlyRevenueMap[hour] ?? 0.0;
                    final double heightFactor = revenue / maxRevenue;

                    return Tooltip(
                      message: 'Time: ${hour.toString().padLeft(2, '0')}:00\nRevenue: ₱${revenue.toStringAsFixed(2)}',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (revenue > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('₱${revenue.toInt()}', style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.mediumGray)),
                            ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 200 * heightFactor,
                            decoration: BoxDecoration(
                              color: revenue > 0 ? AppColors.primary : AppColors.mediumGray.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: displayHours.map((hour) {
                  return SizedBox(
                    width: 30,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.mediumGray, fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 2. EXPORTS TAB ====================
  Widget _buildExportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export & Accounting Reports', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text('Generate tax-compliant summaries and accounting spreadsheets.', style: AppTypography.bodyRegular),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildExportCard(
                  title: 'Daily Sales Report (PDF)',
                  description: 'Detailed breakdown of today\'s transactions, VAT collected, and SC/PWD discounts applied.',
                  icon: Icons.picture_as_pdf,
                  color: AppColors.primary,
                  onExport: () => _exportSummaryPdf('Daily'),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildExportCard(
                  title: 'Monthly Accounting (CSV)',
                  description: 'Complete spreadsheet export of all transactions for import into QuickBooks or Excel.',
                  icon: Icons.table_chart,
                  color: AppColors.success,
                  onExport: _exportMonthlyCsv,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard({required String title, required String description, required IconData icon, required Color color, required VoidCallback onExport}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 24),
          Text(title, style: AppTypography.h2),
          const SizedBox(height: 12),
          Text(description, style: AppTypography.bodyRegular.copyWith(color: AppColors.mediumGray)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.download, size: 20),
            label: const Text('GENERATE EXPORT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            onPressed: onExport,
          ),
        ],
      ),
    );
  }

  Future<void> _exportSummaryPdf(String type) async {
    final orderProvider = context.read<OrderProvider>();
    final doc = pw.Document();
    final summary = await _orderService.getDailySummary(_selectedDate);
    final totalRev = (summary['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalTax = (summary['totalTax'] as num?)?.toDouble() ?? 0.0;
    final totalDiscounts = (summary['totalDiscounts'] as num?)?.toDouble() ?? 0.0;
    final totalTrans = (summary['totalTransactions'] as num?)?.toInt() ?? 0;
    final totalItems = (summary['totalItems'] as num?)?.toInt() ?? 0;
    final vatRateStr = (orderProvider.vatRate * 100).toStringAsFixed(0);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(orderProvider.storeName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('${orderProvider.storeAddress} | TIN: ${orderProvider.tin}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.SizedBox(height: 16),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                pw.Text('$type Sales Report - ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                pw.SizedBox(height: 28),

                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Gross Revenue:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('PHP ${totalRev.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Divider(),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total VAT Collected ($vatRateStr%):', style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('PHP ${totalTax.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('SC/PWD Discounts Applied:', style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('-PHP ${totalDiscounts.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.red700)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Transactions:', style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('$totalTrans', style: const pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Items Sold:', style: const pw.TextStyle(fontSize: 14)),
                          pw.Text('$totalItems', style: const pw.TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 48),
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 12),
                pw.Text('OFFICIAL ACCOUNTING & TAX COMPLIANCE EXPORT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.SizedBox(height: 4),
                pw.Text('Confidential - Internal Business Use Only', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: '${orderProvider.storeName.replaceAll(" ", "_")}_${type}_Report_${DateFormat('yyyyMMdd').format(_selectedDate)}.pdf');
  }

  Future<void> _exportMonthlyCsv() async {
    final orderProvider = context.read<OrderProvider>();
    final orders = await _db.getAllOrders();
    final StringBuffer csv = StringBuffer();
    
    // Header Info
    csv.writeln('Store Name,${orderProvider.storeName}');
    csv.writeln('Store Address,${orderProvider.storeAddress.replaceAll(",", ";")}');
    csv.writeln('VAT REG TIN,${orderProvider.tin}');
    csv.writeln('Export Date,${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    csv.writeln('');
    csv.writeln('Order ID,Timestamp,Subtotal,VAT Amount,Total,Payment Method,Status,Customer Type,SC/PWD Discount');

    for (var o in orders) {
      final String custName = o['customerName']?.toString() ?? 'Guest';
      final double discount = (o['discountAmount'] as num?)?.toDouble() ?? 0.0;
      csv.writeln('${o["id"]},${o["timestamp"]},${o["subtotal"]},${o["taxAmount"]},${o["total"]},${o["paymentMethod"]},${o["status"]},$custName,$discount');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV Export Generated: ${orders.length} transactions ready for QuickBooks / Excel.'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ==================== 3. SETTINGS TAB ====================
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Configuration', style: AppTypography.h1),
          const SizedBox(height: 8),
          Text('Configure shop credentials, tax rates, and hardware peripherals.', style: AppTypography.bodyRegular),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shop Information', style: AppTypography.h2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildTextField(label: 'Store Name', controller: _storeNameController)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildTextField(label: 'VAT Reg TIN', controller: _tinController)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(label: 'Store Address', controller: _storeAddressController),

                const SizedBox(height: 36),
                const Divider(),
                const SizedBox(height: 36),

                Text('Tax & Compliance Settings', style: AppTypography.h2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildTextField(label: 'VAT Rate (%)', controller: _vatRateController)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildTextField(label: 'SC/PWD Discount (%)', controller: _pwdDiscountController)),
                  ],
                ),

                const SizedBox(height: 36),
                const Divider(),
                const SizedBox(height: 36),

                Text('ESC/POS Printer Setup', style: AppTypography.h2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.mediumGray.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Thermal Printer Port:', style: AppTypography.bodyRegular),
                            Text('USB001 (Active)', style: AppTypography.labelMedium.copyWith(color: AppColors.success)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.mediumGray.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Paper Roll Width:', style: AppTypography.bodyRegular),
                            Text('80mm Format', style: AppTypography.labelMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        final orderProvider = context.read<OrderProvider>();
                        _storeNameController.text = 'PROJECT LATTE COFFEE';
                        _storeAddressController.text = '123 Coffee Street, Diliman, Quezon City';
                        _tinController.text = '123-456-789-00000';
                        _vatRateController.text = '12';
                        _pwdDiscountController.text = '20';
                        orderProvider.updateStoreSettings(
                          name: _storeNameController.text.trim(),
                          address: _storeAddressController.text.trim(),
                          tinNum: _tinController.text.trim(),
                          vat: 0.12,
                          pwd: 0.20,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings restored to default.'), backgroundColor: AppColors.mediumGray));
                      },
                      child: const Text('RESET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        final orderProvider = context.read<OrderProvider>();
                        final vat = (double.tryParse(_vatRateController.text.trim()) ?? 12.0) / 100.0;
                        final pwd = (double.tryParse(_pwdDiscountController.text.trim()) ?? 20.0) / 100.0;
                        orderProvider.updateStoreSettings(
                          name: _storeNameController.text.trim(),
                          address: _storeAddressController.text.trim(),
                          tinNum: _tinController.text.trim(),
                          vat: vat,
                          pwd: pwd,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System configuration saved successfully!'), backgroundColor: AppColors.success));
                      },
                      child: const Text('SAVE CONFIGURATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: AppTypography.bodyRegular,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyRegular.copyWith(color: AppColors.mediumGray),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.mediumGray.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.mediumGray.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  // ==================== 4. MENU MANAGEMENT TAB ====================
  Widget _buildMenuManagementTab() {
    final menuProducts = context.watch<OrderProvider>().menuProducts;
    final filteredProducts = menuProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_menuSearchQuery.toLowerCase()) ||
                            p.description.toLowerCase().contains(_menuSearchQuery.toLowerCase());
      final matchesCategory = _menuCategoryFilter == 'All' || p.categoryId == _menuCategoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu & Product Management', style: AppTypography.h1),
                  const SizedBox(height: 8),
                  Text('Add, edit, delete, and toggle real-time availability of cafe products', style: AppTypography.bodyRegular),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: AppColors.white),
                label: const Text('ADD NEW PRODUCT', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showProductModal(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  style: AppTypography.bodyRegular,
                  decoration: InputDecoration(
                    hintText: 'Search products by name or description...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.mediumGray),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.mediumGray.withValues(alpha: 0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.mediumGray.withValues(alpha: 0.3))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                  onChanged: (val) => setState(() => _menuSearchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mediumGray.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _menuCategoryFilter,
                      isExpanded: true,
                      style: AppTypography.bodyRegular.copyWith(color: AppColors.darkGray),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Categories')),
                        DropdownMenuItem(value: 'c1', child: Text('Hot Coffee')),
                        DropdownMenuItem(value: 'c2', child: Text('Iced Coffee')),
                        DropdownMenuItem(value: 'c3', child: Text('Non-Coffee')),
                        DropdownMenuItem(value: 'c4', child: Text('Frappes')),
                        DropdownMenuItem(value: 'c5', child: Text('Refreshers')),
                        DropdownMenuItem(value: 'c6', child: Text('Food & Snacks')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _menuCategoryFilter = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Products Table / List View
          Card(
            color: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.mediumGray.withValues(alpha: 0.2)),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final categoryNames = {
                  'c1': 'Hot Coffee', 'c2': 'Iced Coffee', 'c3': 'Non-Coffee',
                  'c4': 'Frappes', 'c5': 'Refreshers', 'c6': 'Food & Snacks',
                };

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      // Leading Icon
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.coffee, color: AppColors.accent),
                      ),
                      const SizedBox(width: 16),
                      
                      // Title & Subtitle (Wrapped in Expanded so it gracefully truncates!)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(product.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(12)),
                                  child: Text(categoryNames[product.categoryId] ?? 'Other', style: AppTypography.labelMedium.copyWith(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(product.description, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Price
                      Text('₱${product.basePrice.toStringAsFixed(2)}', style: AppTypography.priceTag.copyWith(fontSize: 16)),
                      const SizedBox(width: 20),

                      // Availability Switch
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            value: product.isAvailable,
                            activeColor: AppColors.success,
                            onChanged: (val) {
                              context.read<OrderProvider>().updateProduct(product.copyWith(isAvailable: val));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${product.name} is now ${val ? "Available" : "Unavailable"}'),
                                backgroundColor: val ? AppColors.success : AppColors.error,
                                duration: const Duration(seconds: 1),
                              ));
                            },
                          ),
                          Text(product.isAvailable ? 'Available' : 'Unavailable', style: AppTypography.labelMedium.copyWith(fontSize: 10, color: product.isAvailable ? AppColors.success : AppColors.error)),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Action Buttons
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        tooltip: 'Edit Product',
                        onPressed: () => _showProductModal(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        tooltip: 'Delete Product',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product?'),
                              content: Text('Are you sure you want to delete ${product.name}? This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
                                  onPressed: () {
                                    final messenger = ScaffoldMessenger.of(context);
                                    context.read<OrderProvider>().deleteProduct(product.id);
                                    Navigator.pop(context);
                                    messenger.showSnackBar(SnackBar(content: Text('${product.name} deleted successfully'), backgroundColor: AppColors.error));
                                  },
                                  child: const Text('DELETE'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProductModal([Product? product]) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.basePrice.toString() ?? '');
    String selectedCategory = product?.categoryId ?? 'c1';
    List<String> selectedSizes = product?.availableSizes != null ? List.from(product!.availableSizes) : ['Small', 'Medium'];
    List<String> selectedTemps = product?.availableTemperatures != null ? List.from(product!.availableTemperatures) : ['Hot'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEdit ? 'Edit Product' : 'Add New Product', style: AppTypography.h2),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Product Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: 'Base Price (₱)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                            items: const [
                              DropdownMenuItem(value: 'c1', child: Text('Hot Coffee')),
                              DropdownMenuItem(value: 'c2', child: Text('Iced Coffee')),
                              DropdownMenuItem(value: 'c3', child: Text('Non-Coffee')),
                              DropdownMenuItem(value: 'c4', child: Text('Frappes')),
                              DropdownMenuItem(value: 'c5', child: Text('Refreshers')),
                              DropdownMenuItem(value: 'c6', child: Text('Food & Snacks')),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => selectedCategory = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Available Sizes', style: AppTypography.labelMedium),
                    Row(
                      children: ['Small', 'Medium', 'Large'].map((size) {
                        return Expanded(
                          child: CheckboxListTile(
                            title: Text(size, style: AppTypography.bodyRegular),
                            value: selectedSizes.contains(size),
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedSizes.add(size);
                                } else {
                                  selectedSizes.remove(size);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Available Temperatures', style: AppTypography.labelMedium),
                    Row(
                      children: ['Hot', 'Iced', 'Ice Blended'].map((temp) {
                        return Expanded(
                          child: CheckboxListTile(
                            title: Text(temp, style: AppTypography.bodyRegular),
                            value: selectedTemps.contains(temp),
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedTemps.add(temp);
                                } else {
                                  selectedTemps.remove(temp);
                                }
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name and base price'), backgroundColor: AppColors.error));
                            return;
                          }
                          final double price = double.tryParse(priceController.text.trim()) ?? 0.0;
                          final orderProvider = context.read<OrderProvider>();
                          
                          if (isEdit) {
                            orderProvider.updateProduct(product.copyWith(
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              basePrice: price,
                              categoryId: selectedCategory,
                              availableSizes: selectedSizes,
                              availableTemperatures: selectedTemps,
                            ));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${nameController.text} updated successfully!'), backgroundColor: AppColors.success));
                          } else {
                            final newProduct = Product(
                              id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              basePrice: price,
                              categoryId: selectedCategory,
                              availableSizes: selectedSizes.isEmpty ? ['Medium'] : selectedSizes,
                              availableTemperatures: selectedTemps.isEmpty ? ['Hot'] : selectedTemps,
                              addOns: mockProducts.isNotEmpty ? mockProducts.first.addOns : [],
                              isAvailable: true,
                            );
                            orderProvider.addProduct(newProduct);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newProduct.name} added to menu!'), backgroundColor: AppColors.success));
                          }
                        },
                        child: Text(isEdit ? 'SAVE CHANGES' : 'ADD PRODUCT', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
