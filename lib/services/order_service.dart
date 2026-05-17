import 'package:uuid/uuid.dart';
import '../data/database.dart';
import '../models/product_model.dart';
import 'tax_service.dart';

class OrderService {
  final DatabaseHelper _db = DatabaseHelper();
  static const uuid = Uuid();

  /// Create and save a complete order
  Future<Order?> createAndSaveOrder({
    required List<OrderItem> items,
    required String paymentMethod,
    bool applySCPWD = false,
    String? scPwdID,
  }) async {
    if (items.isEmpty) {
      print('Cannot create order with no items');
      return null;
    }

    try {
      // Calculate totals
      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + item.getTotal(),
      );

      final taxInfo = TaxService.getReceiptBreakdown(
        subtotal,
        applySCPWD: applySCPWD,
      );

      final order = Order(
        id: uuid.v4(),
        timestamp: DateTime.now(),
        items: items,
        subtotal: taxInfo['discountedAmount'] as double,
        taxAmount: taxInfo['vat'] as double,
        total: taxInfo['totalAmount'] as double,
        paymentMethod: paymentMethod,
        status: 'Completed',
      );

      // Save to database
      final saved = await _db.saveOrder(order);

      if (saved) {
        print('Order saved: ${order.id}');
        return order;
      } else {
        print('Failed to save order');
        return null;
      }
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get order history
  Future<List<Map<String, dynamic>>> getOrderHistory({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      if (fromDate != null && toDate != null) {
        return await _db.getOrdersByDate(fromDate);
      } else {
        return await _db.getAllOrders();
      }
    } catch (e) {
      print('Error fetching order history: $e');
      return [];
    }
  }

  /// Get daily summary (for dashboard)
  Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    try {
      return await _db.getDailySalesSummary(date);
    } catch (e) {
      print('Error fetching daily summary: $e');
      return {};
    }
  }

  /// Get today's sales at a glance
  Future<Map<String, dynamic>> getTodaysSalesSnapshot() async {
    return getDailySummary(DateTime.now());
  }

  /// Void an order (requires admin password - implement later)
  Future<bool> voidOrder(String orderId, {String? adminPassword}) async {
    try {
      // TODO: Validate admin password here
      return await _db.voidOrder(orderId);
    } catch (e) {
      print('Error voiding order: $e');
      return false;
    }
  }

  /// Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _db.getTopSellingItems(startDate, endDate);
    } catch (e) {
      print('Error fetching top selling products: $e');
      return [];
    }
  }

  /// Get hourly sales data for charts
  Future<List<Map<String, dynamic>>> getHourlySalesData(DateTime date) async {
    try {
      return await _db.getHourlySales(date);
    } catch (e) {
      print('Error fetching hourly sales: $e');
      return [];
    }
  }

  /// Calculate change from payment
  double calculateChange(double totalAmount, double paymentAmount) {
    return paymentAmount - totalAmount;
  }

  /// Validate change is not negative
  bool isValidPayment(double totalAmount, double paymentAmount) {
    return paymentAmount >= totalAmount;
  }

  /// Generate receipt ID
  String generateReceiptID() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  /// Format order summary for display
  String getOrderSummaryText(Order order) {
    final itemCount = order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    return '${itemCount} items - ${TaxService.formatCurrency(order.total)}';
  }
}