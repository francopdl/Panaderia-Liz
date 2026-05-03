import 'package:flutter/foundation.dart';
import 'package:panaderia_liz/models/index.dart';

class CartNotifier extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;
  
  List<CartItem> get items => _cart.items;
  
  double get total => _cart.total;
  
  int get itemCount => _cart.itemCount;
  
  int get totalQuantity => _cart.totalQuantity;

  void addProduct(String productId, String productName, double price) {
    _cart.addProduct(productId, productName, price);
    notifyListeners();
  }

  void removeProduct(String productId) {
    _cart.removeProduct(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    notifyListeners();
  }

  void clear() {
    _cart.clear();
    notifyListeners();
  }

  CartItem? getItem(String productId) {
    try {
      return _cart.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }
}
