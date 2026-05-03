enum DeliveryStatus {
  pending,    // Pedido creado
  preparing,  // En preparación
  onTheWay,   // En camino
  delivered,  // Entregado
  cancelled,  // Cancelado
}

extension DeliveryStatusExt on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pendiente';
      case DeliveryStatus.preparing:
        return 'Preparando';
      case DeliveryStatus.onTheWay:
        return 'En camino';
      case DeliveryStatus.delivered:
        return 'Entregado';
      case DeliveryStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get value => name;

  static DeliveryStatus fromString(String s) {
    switch (s) {
      case 'preparing':
        return DeliveryStatus.preparing;
      case 'onTheWay':
        return DeliveryStatus.onTheWay;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }
}

class DeliveryItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  DeliveryItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory DeliveryItem.fromMap(Map<String, dynamic> map) {
    return DeliveryItem(
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
    };
  }
}

class DeliveryOrder {
  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<DeliveryItem> items;
  final double total;
  final DeliveryStatus status;
  final String? assignedUserId;
  final String? assignedUserName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    this.customerPhone = '',
    required this.address,
    this.latitude,
    this.longitude,
    required this.items,
    required this.total,
    this.status = DeliveryStatus.pending,
    this.assignedUserId,
    this.assignedUserName,
    this.notes,
    DateTime? createdAt,
    this.deliveredAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
      customerPhone: map['customer_phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      items: (map['items'] as List<dynamic>?)
              ?.map((i) => DeliveryItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: DeliveryStatusExt.fromString(map['status'] as String? ?? ''),
      assignedUserId: map['assigned_user_id'] as String?,
      assignedUserName: map['assigned_user_name'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      deliveredAt: map['delivered_at'] != null
          ? DateTime.tryParse(map['delivered_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': status.value,
      'assigned_user_id': assignedUserId,
      'assigned_user_name': assignedUserName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  DeliveryOrder copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? address,
    double? latitude,
    double? longitude,
    List<DeliveryItem>? items,
    double? total,
    DeliveryStatus? status,
    String? assignedUserId,
    String? assignedUserName,
    String? notes,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return DeliveryOrder(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
