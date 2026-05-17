import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/product_model.dart';
import '../data/mock_menu.dart';

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
        'customerName': order.scPwdId ?? 'Guest',
        'scPwdApplied': order.scPwdApplied ? 1 : 0,
        'discountAmount': order.discountAmount,
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

  // Get filtered orders for CSV exports
  Future<List<Map<String, dynamic>>> getFilteredOrders({
    required DateTime startDate,
    required DateTime endDate,
    required String paymentMethod,
    required String status,
  }) async {
    try {
      final db = await database;
      final start = DateTime(startDate.year, startDate.month, startDate.day).toIso8601String();
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59).toIso8601String();

      List<String> whereClauses = ['timestamp BETWEEN ? AND ?'];
      List<Object> whereArgs = [start, end];

      if (paymentMethod != 'All') {
        if (paymentMethod == 'Cash') {
          whereClauses.add('paymentMethod LIKE ?');
          whereArgs.add('%Cash%');
        } else if (paymentMethod == 'E-Wallet') {
          whereClauses.add('(paymentMethod LIKE ? OR paymentMethod LIKE ? OR paymentMethod LIKE ?)');
          whereArgs.addAll(['%GCash%', '%Maya%', '%Wallet%']);
        } else if (paymentMethod == 'Card') {
          whereClauses.add('(paymentMethod LIKE ? OR paymentMethod LIKE ? OR paymentMethod LIKE ?)');
          whereArgs.addAll(['%Card%', '%Debit%', '%Credit%']);
        }
      }

      if (status != 'All') {
        whereClauses.add('status = ?');
        whereArgs.add(status);
      }

      final whereString = whereClauses.join(' AND ');

      return await db.query(
        'orders',
        where: whereString,
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      print('Error fetching filtered orders: $e');
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

      double totalRevenue = 0; // Gross Revenue
      double totalTax = 0; // VAT
      double totalDiscounts = 0; // SC/PWD
      int totalTransactions = 0;
      int totalItems = 0;

      // Tender breakdown
      double cashSales = 0;
      double ewalletSales = 0; // GCash, Maya, etc.
      double cardSales = 0;

      for (var order in orders) {
        if (order['status'] != 'Voided') {
          final double orderTotal = order['total'] as double;
          totalRevenue += orderTotal;
          totalTax += order['taxAmount'] as double;
          totalDiscounts += (order['discountAmount'] as num?)?.toDouble() ?? 0.0;
          totalTransactions++;

          // Payment tender tracking
          final String method = order['paymentMethod']?.toString().toLowerCase() ?? 'cash';
          if (method.contains('gcash') || method.contains('maya') || method.contains('wallet')) {
            ewalletSales += orderTotal;
          } else if (method.contains('card') || method.contains('debit') || method.contains('credit')) {
            cardSales += orderTotal;
          } else {
            cashSales += orderTotal; // Default to Cash
          }

          // Count items in this order
          final items = await getOrderItems(order['id'] as String);
          for (var item in items) {
            totalItems += item['quantity'] as int;
          }
        }
      }

      final double netRevenue = totalRevenue - totalTax - totalDiscounts;

      return {
        'date': date,
        'totalRevenue': totalRevenue, // Gross
        'netRevenue': netRevenue > 0 ? netRevenue : 0.0,
        'totalTax': totalTax,
        'totalDiscounts': totalDiscounts,
        'totalTransactions': totalTransactions,
        'totalItems': totalItems,
        'averageTransactionValue': totalTransactions > 0 ? totalRevenue / totalTransactions : 0.0,
        'averageItemsPerTicket': totalTransactions > 0 ? totalItems / totalTransactions : 0.0,
        'cashSales': cashSales,
        'ewalletSales': ewalletSales,
        'cardSales': cardSales,
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

  // Save or update product in database
  Future<bool> saveProduct(Product product) async {
    try {
      final db = await database;
      await db.insert('products', {
        'id': product.id,
        'name': product.name,
        'description': product.description ?? '',
        'basePrice': product.basePrice,
        'categoryId': product.categoryId,
        'availableSizes': product.availableSizes.join(','),
        'availableTemperatures': product.availableTemperatures.join(','),
        'isAvailable': product.isAvailable ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      print('Error saving product: $e');
      return false;
    }
  }

  // Get category breakdown for a specific date
  Future<List<Map<String, dynamic>>> getCategoryBreakdown(DateTime date) async {
    try {
      final db = await database;

      // Auto-seed products table if empty to ensure JOIN works perfectly!
      final countRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM products');
      final int count = (countRes.first['cnt'] as num?)?.toInt() ?? 0;
      if (count == 0) {
        for (var p in mockProducts) {
          await db.insert('products', {
            'id': p.id,
            'name': p.name,
            'description': p.description ?? '',
            'basePrice': p.basePrice,
            'categoryId': p.categoryId,
            'availableSizes': p.availableSizes.join(','),
            'availableTemperatures': p.availableTemperatures.join(','),
            'isAvailable': p.isAvailable ? 1 : 0,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final result = await db.rawQuery('''
        SELECT 
          p.categoryId as category,
          SUM(oi.quantity) as totalQuantity,
          SUM(oi.itemTotal) as totalRevenue
        FROM order_items oi
        JOIN products p ON oi.productId = p.id
        WHERE oi.orderId IN (
          SELECT id FROM orders 
          WHERE timestamp BETWEEN ? AND ? AND status != 'Voided'
        )
        GROUP BY p.categoryId
        ORDER BY totalRevenue DESC
      ''', [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ]);

      final List<Map<String, dynamic>> mappedResult = [];
      for (var row in result) {
        final String catId = row['category']?.toString() ?? '';
        String catName = catId;
        
        final matchedCat = mockCategories.where((c) => c.id == catId).toList();
        if (matchedCat.isNotEmpty) {
          catName = matchedCat.first.name;
        } else if (catId == 'c1') { catName = 'Hot Coffee'; }
        else if (catId == 'c2') { catName = 'Iced Coffee'; }
        else if (catId == 'c3') { catName = 'Frappes'; }
        else if (catId == 'c4') { catName = 'Teas & Sodas'; }
        else if (catId == 'c5') { catName = 'Food & Snacks'; }
        else if (catId == 'c6') { catName = 'Add-ons & Fees'; }
        
        mappedResult.add({
          'category': catName,
          'totalQuantity': row['totalQuantity'],
          'totalRevenue': row['totalRevenue'],
        });
      }

      return mappedResult;
    } catch (e) {
      print('Error fetching category breakdown: $e');
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