import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panaderia_liz/models/index.dart';

/// Persistent storage for web platform where SQLite is not available.
/// Uses SharedPreferences (localStorage) to survive browser reloads.
class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  factory WebStorageService() => _instance;
  WebStorageService._internal();

  static const _productsKey = 'web_products';
  static const _salesKey = 'web_sales';
  static const _saleItemsKey = 'web_sale_items';

  List<Product> _products = [];
  List<Sale> _sales = [];
  bool _initialized = false;

  /// Must be called once before using the service.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();

    // Load products
    final productsJson = prefs.getString(_productsKey);
    if (productsJson != null) {
      final List<dynamic> list = jsonDecode(productsJson);
      _products = list.map((m) => Product.fromMap(Map<String, dynamic>.from(m))).toList();
    } else {
      _seedInitialData();
      await _saveProducts();
    }

    // Load sales + items
    final salesJson = prefs.getString(_salesKey);
    final itemsJson = prefs.getString(_saleItemsKey);
    if (salesJson != null) {
      final List<dynamic> salesList = jsonDecode(salesJson);
      final Map<String, List<SaleItem>> itemsMap = {};
      if (itemsJson != null) {
        final List<dynamic> itemsList = jsonDecode(itemsJson);
        for (final m in itemsList) {
          final item = SaleItem.fromMap(Map<String, dynamic>.from(m));
          itemsMap.putIfAbsent(item.saleId, () => []).add(item);
        }
      }
      _sales = salesList.map((m) {
        final sale = Sale.fromMap(Map<String, dynamic>.from(m));
        return sale.copyWith(items: itemsMap[sale.id] ?? []);
      }).toList();
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_products.map((p) => p.toMap()).toList());
    await prefs.setString(_productsKey, json);
  }

  Future<void> _saveSales() async {
    final prefs = await SharedPreferences.getInstance();
    final salesJson = jsonEncode(_sales.map((s) => s.toMap()).toList());
    final allItems = _sales.expand((s) => s.items).toList();
    final itemsJson = jsonEncode(allItems.map((i) => i.toMap()).toList());
    await prefs.setString(_salesKey, salesJson);
    await prefs.setString(_saleItemsKey, itemsJson);
  }

  // ── Products ──

  List<Product> get products => List.unmodifiable(_products);

  List<Product> getAvailableProducts() =>
      _products.where((p) => p.isAvailable).toList();

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
  }

  Future<bool> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index == -1) return false;
    _products[index] = product;
    await _saveProducts();
    return true;
  }

  Future<bool> deleteProduct(String productId) async {
    final len = _products.length;
    _products.removeWhere((p) => p.id == productId);
    if (_products.length < len) {
      await _saveProducts();
      return true;
    }
    return false;
  }

  // ── Sales ──

  List<Sale> get sales => List.unmodifiable(_sales);

  List<Sale> getSalesSorted() {
    final sorted = List<Sale>.from(_sales);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> addSale(Sale sale) async {
    _sales.add(sale);
    await _saveSales();
  }

  Sale? getSaleById(String id) {
    try {
      return _sales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  int get salesCount => _sales.length;

  double get totalSalesAmount =>
      _sales.fold(0.0, (sum, s) => sum + s.total);

  double getDailyTotal() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return _sales
        .where((s) => s.createdAt.isAfter(startOfDay))
        .fold(0.0, (sum, s) => sum + s.total);
  }

  // ── Seed Data ──

  void _seedInitialData() {
    _products.addAll([
      Product(id: '1', name: 'Pan', price: 1.00, category: 'Pan', stock: 50, createdAt: DateTime.now()),
      Product(id: '2', name: 'Barra', price: 0.80, category: 'Pan', stock: 60, createdAt: DateTime.now()),
      Product(id: '3', name: 'Croissant', price: 1.20, category: 'Pastelería', stock: 30, createdAt: DateTime.now()),
      Product(id: '4', name: 'Donut', price: 0.90, category: 'Pastelería', stock: 40, createdAt: DateTime.now()),
      Product(id: '5', name: 'Magdalena', price: 0.70, category: 'Pastelería', stock: 35, createdAt: DateTime.now()),
      Product(id: '6', name: 'Baguette', price: 1.50, category: 'Pan', stock: 25, createdAt: DateTime.now()),
    ]);
  }
}
