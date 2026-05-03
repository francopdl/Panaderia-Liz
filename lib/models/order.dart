// Este archivo se mantiene por compatibilidad
// Usar Sale y SaleItem en su lugar

import 'package:panaderia_liz/models/index.dart';

@Deprecated('Usar Sale en su lugar')
class Order {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime createdAt;
  final String paymentMethod;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    this.paymentMethod = 'cash',
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      userId: map['userId'] as String,
      items: List<Map<String, dynamic>>.from(
        (map['items'] as List).cast<Map<String, dynamic>>(),
      ),
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }

  @override
  String toString() =>
      'Order(id: $id, total: $total€, items: ${items.length}, createdAt: $createdAt)';
}
