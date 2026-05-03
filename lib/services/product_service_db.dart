import 'package:panaderia_liz/models/product.dart';
import 'package:panaderia_liz/models/product_category.dart';
import 'package:panaderia_liz/services/firestore_service.dart';

class ProductServiceDB {
  static ProductServiceDB? _instance;
  final FirestoreService _fs = FirestoreService();

  ProductServiceDB._internal();

  factory ProductServiceDB() {
    _instance ??= ProductServiceDB._internal();
    return _instance!;
  }

  Future<List<Product>> getAllProducts() async {
    return _fs.getAllProducts();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    return _fs.getProductsByCategory(category);
  }

  Future<List<String>> getCategories() async {
    return _fs.getCategories();
  }

  Future<Product?> getProductById(String id) async {
    return _fs.getProductById(id);
  }

  Future<Product?> addProduct(
    String id,
    String name,
    double price,
    String category,
    int initialStock,
  ) {
    return _fs.addProduct(id, name, price, category, initialStock);
  }

  Future<bool> updateProduct(Product product) async {
    return _fs.updateProduct(product);
  }

  Future<bool> deleteProduct(String productId) async {
    return _fs.deleteProduct(productId);
  }

  Future<bool> updateStock(String productId, int newStock) async {
    return _fs.updateStock(productId, newStock);
  }

  Future<bool> decreaseStock(String productId, int quantity) async {
    return _fs.decreaseStock(productId, quantity);
  }

  Future<bool> increaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null) return false;
    return updateStock(productId, product.stock + quantity);
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    return _fs.getLowStockProducts(threshold: threshold);
  }
}
