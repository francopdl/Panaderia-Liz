class CartItem {
  final String productId;
  final String productName;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() =>
      'CartItem(productId: $productId, quantity: $quantity, total: $total€)';
}

class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  void addProduct(String productId, String productName, double price) {
    try {
      final existingItem = items.firstWhere(
        (item) => item.productId == productId,
      );
      existingItem.quantity++;
    } catch (e) {
      items.add(
        CartItem(
          productId: productId,
          productName: productName,
          price: price,
          quantity: 1,
        ),
      );
    }
  }

  void removeProduct(String productId) {
    items.removeWhere((item) => item.productId == productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    try {
      final item = items.firstWhere((item) => item.productId == productId);
      item.quantity = quantity;
    } catch (e) {
      // Item not found
    }
  }

  void clear() {
    items.clear();
  }

  double get total {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  int get itemCount {
    return items.length;
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  String toString() =>
      'Cart(items: ${items.length}, total: $total€, quantity: $totalQuantity)';
}
