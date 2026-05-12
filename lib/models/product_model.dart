class Category {
  final String id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class Product {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String categoryId;
  final List<String> availableSizes; // Small, Medium, Large
  final List<String> availableTemperatures; // Hot, Iced
  final List<AddOn> addOns;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    required this.availableSizes,
    required this.availableTemperatures,
    required this.addOns,
    this.isAvailable = true,
  });

  // calculate final sized base on price
  double getPriceForSize(String size) {
    switch (size) {
      case 'Small':
        return basePrice;
      case 'Medium':
        return basePrice + 15;
      case 'Large':
        return basePrice + 30;
      default:
        return basePrice; 
    }
  }
}

class AddOn {
  final String id;
  final String name;
  final double price;

  AddOn({
    required this.id,
    required this.name,
    required this.price,
  });
}

class OrderItem {
  final String id;
  final Product product;
  final String selectedSize;
  final String selectedTemperature;
  final List<AddOn> selectedAddOns;
  final int quantity;

  OrderItem({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedTemperature,
    required this.selectedAddOns,
    this.quantity = 1,
  });

  // calculate total price for this order item
  double getTotal() {
    double itemPrice = product.getPriceForSize(selectedSize);
    double addOnsTotal = 
        selectedAddOns.fold(0, (sum, addOn) => sum + addOn.price);
    return (itemPrice + addOnsTotal) * quantity;
  }
}

class Order {
  final String id;
  final DateTime timestamp;
  final List<OrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String paymentMethod; // cash, ewallet
  final String status; // pending, completed, voided

  Order({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    this.status = 'Completed'
  });
}