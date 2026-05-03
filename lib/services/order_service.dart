import 'package:panaderia_liz/models/index.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  // Mock orders database
  final List<Order> _orders = [];

  /// Save a new order
  Future<Order> saveOrder(
    String userId,
    List<CartItem> items,
    double total, {
    String paymentMethod = 'cash',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final order = Order(
      id: const Uuid().v4(),
      userId: userId,
      items: items
          .map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'price': item.price,
            'quantity': item.quantity,
            'total': item.total,
          })
          .toList(),
      total: total,
      createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
    );

    _orders.add(order);
    return order;
  }

  /// Get all orders
  Future<List<Order>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_orders);
  }

  /// Get orders by user
  Future<List<Order>> getOrdersByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.where((order) => order.userId == userId).toList();
  }

  /// Get order by id
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Get total sales
  Future<double> getTotalSales() async {
    await Future.delayed(const Duration(milliseconds: 300));
    double total = 0.0;
    for (final order in _orders) {
      total += order.total;
    }
    return total;
  }

  /// Get sales count
  Future<int> getSalesCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _orders.length;
  }
}
