import 'package:panaderia_liz/models/index.dart';

class Sale {
  final String id;
  final String userId;
  final List<SaleItem> items;
  final double total;
  final DateTime createdAt;
  final String paymentMethod;

  Sale({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    this.paymentMethod = 'cash',
  });

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      items: <SaleItem>[],
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      paymentMethod: map['payment_method'] as String? ?? 'cash',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total': total,
      'items_count': items.length,
      'created_at': createdAt.toIso8601String(),
      'payment_method': paymentMethod,
    };
  }

  Sale copyWith({
    String? id,
    String? userId,
    List<SaleItem>? items,
    double? total,
    DateTime? createdAt,
    String? paymentMethod,
  }) {
    return Sale(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() =>
      'Sale(id: $id, total: $total€, items: ${items.length}, date: $createdAt)';
}
