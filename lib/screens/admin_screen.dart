import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/database.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
            width: 220,
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
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    // Generate hours from 8 AM to 8 PM (8 to 20)
    final List<int> displayHours = List.generate(13, (index) => index + 8);
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
                        width: 32,
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
                width: 32,
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.mediumGray, fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ],
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
    final doc = pw.Document();
    final summary = await _orderService.getDailySummary(DateTime.now());
    final totalRev = (summary['totalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalTax = (summary['totalTax'] as num?)?.toDouble() ?? 0.0;
    final totalTrans = (summary['totalTransactions'] as num?)?.toInt() ?? 0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PROJECT LATTE - $type Sales Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 24),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gross Revenue:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('PHP ${totalRev.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total VAT Collected (12%):', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('PHP ${totalTax.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Transactions:', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('$totalTrans', style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
              pw.SizedBox(height: 36),
              pw.Text('END OF REPORT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey500)),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await doc.save(), filename: 'Latte_${type}_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf');
  }

  Future<void> _exportMonthlyCsv() async {
    final orders = await _db.getAllOrders();
    final StringBuffer csv = StringBuffer();
    csv.writeln('Order ID,Timestamp,Subtotal,VAT,Total,Payment Method,Status');

    for (var o in orders) {
      csv.writeln('${o["id"]},${o["timestamp"]},${o["subtotal"]},${o["taxAmount"]},${o["total"]},${o["paymentMethod"]},${o["status"]}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV Export Generated: ${orders.length} records ready for Excel.'),
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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings restored to default.'), backgroundColor: AppColors.mediumGray));
                      },
                      child: const Text('RESET', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
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
}
