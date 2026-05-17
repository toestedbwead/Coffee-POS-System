import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;

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

  // calculate final size price based on official documentation tiers (+20 PHP for second size)
  double getPriceForSize(String size) {
    if (availableSizes.isNotEmpty && size == availableSizes.first) {
      return basePrice;
    }
    if (availableSizes.length > 1 && size == availableSizes[1]) {
      return basePrice + 20.0;
    }
    return basePrice; 
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    String? categoryId,
    List<String>? availableSizes,
    List<String>? availableTemperatures,
    List<AddOn>? addOns,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      categoryId: categoryId ?? this.categoryId,
      availableSizes: availableSizes ?? this.availableSizes,
      availableTemperatures: availableTemperatures ?? this.availableTemperatures,
      addOns: addOns ?? this.addOns,
      isAvailable: isAvailable ?? this.isAvailable,
    );
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
  final bool scPwdApplied;
  final double discountAmount;
  final String? scPwdId;

  Order({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.paymentMethod,
    this.status = 'Completed',
    this.scPwdApplied = false,
    this.discountAmount = 0.0,
    this.scPwdId,
  });
}