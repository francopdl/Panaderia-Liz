class RawMaterial {
  final String id;
  final String name;
  final String unit; // kg, litros, unidades
  final double stock;
  final double minStock;
  final double pricePerUnit;
  final DateTime createdAt;
  final String? imageUrl;

  RawMaterial({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    this.minStock = 5.0,
    this.pricePerUnit = 0.0,
    DateTime? createdAt,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RawMaterial.fromMap(Map<String, dynamic> map) {
    return RawMaterial(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      unit: map['unit'] as String? ?? 'kg',
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      minStock: (map['min_stock'] as num?)?.toDouble() ?? 5.0,
      pricePerUnit: (map['price_per_unit'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'stock': stock,
      'min_stock': minStock,
      'price_per_unit': pricePerUnit,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  RawMaterial copyWith({
    String? id,
    String? name,
    String? unit,
    double? stock,
    double? minStock,
    double? pricePerUnit,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return RawMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  bool get isLowStock => stock <= minStock;
}
