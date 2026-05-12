import '../models/product_model.dart';

// Mock Categories
final mockCategories = [
  Category(id: '1', name: 'Espresso', icon: '☕'),
  Category(id: '2', name: 'Latte', icon: '☕'),
  Category(id: '3', name: 'Cappuccino', icon: '☕'),
  Category(id: '4', name: 'Cold Brew', icon: '☕'),
  Category(id: '5', name: 'Specialty', icon: '☕'),
];

// Mock Add-ons
final mockAddOns = [
  AddOn(id: 'ao1', name: 'Extra Shot', price: 25),
  AddOn(id: 'ao2', name: 'Vanilla Syrup', price: 15),
  AddOn(id: 'ao3', name: 'Caramel Syrup', price: 15),
  AddOn(id: 'ao4', name: 'Hazelnut Syrup', price: 15),
  AddOn(id: 'ao5', name: 'Whipped Cream', price: 20),
  AddOn(id: 'ao6', name: 'Cinnamon', price: 10),
  AddOn(id: 'ao7', name: 'Honey', price: 10),
  AddOn(id: 'ao8', name: 'Almond Milk', price: 15),
];

// Mock Products
final mockProducts = [
  // Espresso Category
  Product(
    id: 'p1',
    name: 'Americano',
    description: 'Bold and smooth espresso with hot water',
    basePrice: 120,
    categoryId: '1',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p2',
    name: 'Espresso Shot',
    description: 'Pure, concentrated espresso',
    basePrice: 80,
    categoryId: '1',
    availableSizes: ['Small'],
    availableTemperatures: ['Hot'],
    addOns: mockAddOns,
  ),

  // Latte Category
  Product(
    id: 'p3',
    name: 'Classic Latte',
    description: 'Smooth espresso with velvety steamed milk',
    basePrice: 140,
    categoryId: '2',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot', 'Iced'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p4',
    name: 'Vanilla Latte',
    description: 'Latte with creamy vanilla flavor',
    basePrice: 155,
    categoryId: '2',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot', 'Iced'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p5',
    name: 'Caramel Latte',
    description: 'Latte with sweet caramel drizzle',
    basePrice: 155,
    categoryId: '2',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot', 'Iced'],
    addOns: mockAddOns,
  ),

  // Cappuccino Category
  Product(
    id: 'p6',
    name: 'Classic Cappuccino',
    description: 'Equal parts espresso, steamed milk, and foam',
    basePrice: 140,
    categoryId: '3',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p7',
    name: 'Mocha Cappuccino',
    description: 'Cappuccino with rich chocolate',
    basePrice: 160,
    categoryId: '3',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Hot'],
    addOns: mockAddOns,
  ),

  // Cold Brew Category
  Product(
    id: 'p8',
    name: 'Cold Brew',
    description: 'Smooth, cold-steeped coffee',
    basePrice: 140,
    categoryId: '4',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Iced'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p9',
    name: 'Iced Latte',
    description: 'Chilled espresso with cold milk',
    basePrice: 150,
    categoryId: '4',
    availableSizes: ['Small', 'Medium', 'Large'],
    availableTemperatures: ['Iced'],
    addOns: mockAddOns,
  ),

  // Specialty Category
  Product(
    id: 'p10',
    name: 'Affogato',
    description: 'Vanilla ice cream topped with hot espresso',
    basePrice: 180,
    categoryId: '5',
    availableSizes: ['Small', 'Medium'],
    availableTemperatures: ['Hot'],
    addOns: mockAddOns,
  ),
  Product(
    id: 'p11',
    name: 'Cortado',
    description: 'Espresso balanced with steamed milk',
    basePrice: 130,
    categoryId: '5',
    availableSizes: ['Small', 'Medium'],
    availableTemperatures: ['Hot', 'Iced'],
    addOns: mockAddOns,
  ),
];

// Helper function to get products by category
List<Product> getProductsByCategory(String categoryId) {
  return mockProducts.where((p) => p.categoryId == categoryId).toList();
}

// Helper function to get category by id
Category? getCategoryById(String categoryId) {
  try {
    return mockCategories.firstWhere((c) => c.id == categoryId);
  } catch (e) {
    return null;
  }
}