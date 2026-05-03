class ProductCategory {
  final String id;
  final String name;
  final String icon;
  final int color;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Categorías predefinidas
  static const ProductCategory panes = ProductCategory(
    id: 'panes',
    name: 'Panes',
    icon: '🍞',
    color: 0xFFE8B757,
  );

  static const ProductCategory pasteles = ProductCategory(
    id: 'pasteles',
    name: 'Pasteles',
    icon: '🎂',
    color: 0xFFE8A87C,
  );

  static const ProductCategory pastas = ProductCategory(
    id: 'pastas',
    name: 'Pastas',
    icon: '🥐',
    color: 0xFFC4991B,
  );

  static const ProductCategory dulces = ProductCategory(
    id: 'dulces',
    name: 'Dulces',
    icon: '🍪',
    color: 0xFFF4A460,
  );

  static const ProductCategory bebidas = ProductCategory(
    id: 'bebidas',
    name: 'Bebidas',
    icon: '☕',
    color: 0xFF8B4513,
  );

  static List<ProductCategory> getAll() => [
        panes,
        pasteles,
        pastas,
        dulces,
        bebidas,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📦',
      color: map['color'] ?? 0xFF000000,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
