import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/product_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    // For Windows desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await getDatabasesPath();
    final path = '$dbPath/latte_pos.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        basePrice REAL NOT NULL,
        categoryId TEXT NOT NULL,
        availableSizes TEXT NOT NULL,
        availableTemperatures TEXT NOT NULL,
        isAvailable INTEGER DEFAULT 1,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        subtotal REAL NOT NULL,
        taxAmount REAL NOT NULL,
        total REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        status TEXT DEFAULT 'Completed',
        customerName TEXT,
        scPwdApplied INTEGER DEFAULT 0,
        discountAmount REAL DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Order items table (line items in each order)
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        selectedSize TEXT NOT NULL,
        selectedTemperature TEXT NOT NULL,
        selectedAddOns TEXT,
        quantity INTEGER NOT NULL,
        itemTotal REAL NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders(id)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_orders_timestamp ON orders(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_order_items_orderId ON order_items(orderId)
    ''');
  }

  // ==================== ORDER OPERATIONS ====================

  // Save order to database
  Future<bool> saveOrder(Order order) async {
    try {
      final db = await database;

      // Save order header
      await db.insert('orders', {
        'id': order.id,
        'timestamp': order.timestamp.toIso8601String(),
        'subtotal': order.subtotal,
        'taxAmount': order.taxAmount,
        'total': order.total,
        'paymentMethod': order.paymentMethod,
        'status': order.status,
      });

      // Save order items
      for (var item in order.items) {
        await db.insert('order_items', {
          'id': item.id,
          'orderId': order.id,
          'productId': item.product.id,
          'productName': item.product.name,
          'selectedSize': item.selectedSize,
          'selectedTemperature': item.selectedTemperature,
          'selectedAddOns': item.selectedAddOns.map((a) => a.name).join(','),
          'quantity': item.quantity,
          'itemTotal': item.getTotal(),
        });
      }

      return true;
    } catch (e) {
      print('Error saving order: $e');
      return false;
    }
  }

  // Get all orders (for reporting)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final db = await database;
      return await db.query('orders', orderBy: 'timestamp DESC');
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // Get orders for a specific date
  Future<List<Map<String, dynamic>>> getOrdersByDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return await db.query(
        'orders',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      print('Error fetching orders by date: $e');
      return [];
    }
  }

  // Get order items for a specific order
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    try {
      final db = await database;
      return await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  // Void an order (mark as voided)
  Future<bool> voidOrder(String orderId) async {
    try {
      final db = await database;
      await db.update(
        'orders',
        {'status': 'Voided'},
        where: 'id = ?',
        whereArgs: [orderId],
      );
      return true;
    } catch (e) {
      print('Error voiding order: $e');
      return false;
    }
  }

  // ==================== REPORTING OPERATIONS ====================

  // Get daily sales summary
  Future<Map<String, dynamic>> getDailySalesSummary(DateTime date) async {
    try {
      final db = await database;
      final orders = await getOrdersByDate(date);

      double totalRevenue = 0;
      double totalTax = 0;
      int totalTransactions = 0;
      int totalItems = 0;

      for (var order in orders) {
        if (order['status'] != 'Voided') {
          totalRevenue += order['total'] as double;
          totalTax += order['taxAmount'] as double;
          totalTransactions++;

          // Count items in this order
          final items = await getOrderItems(order['id'] as String);
          for (var item in items) {
            totalItems += item['quantity'] as int;
          }
        }
      }

      return {
        'date': date,
        'totalRevenue': totalRevenue,
        'totalTax': totalTax,
        'totalTransactions': totalTransactions,
        'totalItems': totalItems,
        'averageTransactionValue': totalTransactions > 0
            ? totalRevenue / totalTransactions
            : 0,
      };
    } catch (e) {
      print('Error calculating daily summary: $e');
      return {};
    }
  }

  // Get top selling items for a date range
  Future<List<Map<String, dynamic>>> getTopSellingItems(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;

      final result = await db.rawQuery('''
        SELECT 
          productName,
          SUM(quantity) as totalQuantity,
          SUM(itemTotal) as totalRevenue
        FROM order_items
        WHERE orderId IN (
          SELECT id FROM orders 
          WHERE timestamp BETWEEN ? AND ? AND status != 'Voided'
        )
        GROUP BY productName
        ORDER BY totalQuantity DESC
        LIMIT 10
      ''', [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);

      return result;
    } catch (e) {
      print('Error fetching top selling items: $e');
      return [];
    }
  }

  // Get hourly sales for chart
  Future<List<Map<String, dynamic>>> getHourlySales(DateTime date) async {
    try {
      final db = await database;

      final result = await db.rawQuery('''
        SELECT 
          CAST(strftime('%H', timestamp) AS INTEGER) as hour,
          COUNT(*) as transactionCount,
          SUM(total) as revenue
        FROM orders
        WHERE DATE(timestamp) = ?
        GROUP BY hour
        ORDER BY hour
      ''', [
        date.toIso8601String().split('T')[0],
      ]);

      return result;
    } catch (e) {
      print('Error fetching hourly sales: $e');
      return [];
    }
  }

  // ==================== MAINTENANCE ====================

  // Clear all test data (for development only)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('order_items');
      await db.delete('orders');
      print('All data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Close database connection
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}