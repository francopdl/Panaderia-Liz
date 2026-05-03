import 'package:panaderia_liz/models/index.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  // Mock products database
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Pan',
      price: 1.00,
      category: 'Pan',
      stock: 50,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Barra',
      price: 0.80,
      category: 'Pan',
      stock: 60,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: 'Croissant',
      price: 1.20,
      category: 'Pastelería',
      stock: 30,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '4',
      name: 'Donut',
      price: 0.90,
      category: 'Pastelería',
      stock: 40,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '5',
      name: 'Magdalena',
      price: 0.70,
      category: 'Pastelería',
      stock: 35,
      createdAt: DateTime.now(),
    ),
    Product(
      id: '6',
      name: 'Baguette',
      price: 1.50,
      category: 'Pan',
      stock: 25,
      createdAt: DateTime.now(),
    ),
  ];

  /// Get all available products
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_products);
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _products.where((p) => p.category == category).toList();
  }

  /// Get unique categories
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final categories = <String>{};
    for (final product in _products) {
      categories.add(product.category);
    }
    return categories.toList();
  }

  /// Get product by id
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add new product
  Future<Product> addProduct(
    String name,
    double price,
    String category,
  ) async {
    final newProduct = Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      category: category,
      stock: 0,
      createdAt: DateTime.now(),
    );
    _products.add(newProduct);
    return newProduct;
  }

  /// Update product
  Future<bool> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      return true;
    }
    return false;
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products.removeAt(index);
      return true;
    }
    return false;
  }
}
