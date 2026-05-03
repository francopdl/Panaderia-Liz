class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final bool isAvailable;
  final DateTime createdAt;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    this.isAvailable = true,
    required this.createdAt,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      stock: map['stock'] as int? ?? 0,
      isAvailable: ((map['is_available'] ?? map['isAvailable']) as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String? ?? map['createdAt'] as String),
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    int? stock,
    bool? isAvailable,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price€, stock: $stock)';
}
