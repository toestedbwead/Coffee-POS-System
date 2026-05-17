import 'package:flutter/foundation.dart';
import '../data/mock_menu.dart';
import '../models/product_model.dart';
import '../services/tax_service.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderItem> _items = [];
  bool _applySCPWD = false;
  String? _scPwdID;

  // Store & Compliance Settings State
  String _storeName = 'PROJECT LATTE COFFEE';
  String _storeAddress = '123 Coffee Street, Diliman, Quezon City';
  String _tin = '123-456-789-00000';
  double _vatRate = 0.12;
  double _pwdDiscount = 0.20;

  List<OrderItem> get items => _items;
  bool get applySCPWD => _applySCPWD;
  String? get scPwdID => _scPwdID;
  List<Product> get menuProducts => mockProducts;
  String get storeName => _storeName;
  String get storeAddress => _storeAddress;
  String get tin => _tin;
  double get vatRate => _vatRate;
  double get pwdDiscount => _pwdDiscount;

  // Calculation Getters using TaxService
  double get subtotal => _items.fold(0, (sum, item) => sum + item.getTotal());
  
  Map<String, dynamic> get taxBreakdown => 
      TaxService.getReceiptBreakdown(subtotal, applySCPWD: _applySCPWD, vatRate: _vatRate, pwdDiscount: _pwdDiscount);

  double get vat => taxBreakdown['vat'] as double;
  double get total => taxBreakdown['totalAmount'] as double;
  double get discount => taxBreakdown['scPwdDiscount'] as double;

  // Actions
  void addItem(OrderItem item) {
    // Check if product with same customization already exists
    final existingIndex = _items.indexWhere(
      (o) =>
          o.product.id == item.product.id &&
          o.selectedSize == item.selectedSize &&
          o.selectedTemperature == item.selectedTemperature &&
          _areAddOnsEqual(o.selectedAddOns, item.selectedAddOns),
    );

    if (existingIndex != -1) {
      _items[existingIndex] = OrderItem(
        id: _items[existingIndex].id,
        product: _items[existingIndex].product,
        selectedSize: _items[existingIndex].selectedSize,
        selectedTemperature: _items[existingIndex].selectedTemperature,
        selectedAddOns: _items[existingIndex].selectedAddOns,
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearOrder() {
    _items = [];
    _applySCPWD = false;
    _scPwdID = null;
    notifyListeners();
  }

  void toggleSCPWD(bool value, {String? id}) {
    _applySCPWD = value;
    if (value) _scPwdID = id;
    notifyListeners();
  }

  Future<Order?> processCheckout(String paymentMethod) async {
    if (_items.isEmpty) return null;

    final order = await _orderService.createAndSaveOrder(
      items: _items,
      paymentMethod: paymentMethod,
      applySCPWD: _applySCPWD,
      scPwdID: _scPwdID,
    );

    if (order != null) {
      clearOrder();
      return order;
    }
    return null;
  }

  // Helper for comparing add-ons
  bool _areAddOnsEqual(List<AddOn> a, List<AddOn> b) {
    if (a.length != b.length) return false;
    final aNames = a.map((e) => e.name).toList()..sort();
    final bNames = b.map((e) => e.name).toList()..sort();
    for (int i = 0; i < aNames.length; i++) {
      if (aNames[i] != bNames[i]) return false;
    }
    return true;
  }

  // Menu Management Actions
  void updateProduct(Product updatedProduct) {
    final index = mockProducts.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      mockProducts[index] = updatedProduct;
      _orderService.saveProduct(updatedProduct);
      notifyListeners();
    }
  }

  void addProduct(Product newProduct) {
    mockProducts.add(newProduct);
    _orderService.saveProduct(newProduct);
    notifyListeners();
  }

  void deleteProduct(String productId) {
    mockProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Store Settings Actions
  void updateStoreSettings({
    required String name,
    required String address,
    required String tinNum,
    required double vat,
    required double pwd,
  }) {
    _storeName = name;
    _storeAddress = address;
    _tin = tinNum;
    _vatRate = vat;
    _pwdDiscount = pwd;
    notifyListeners();
  }
}
