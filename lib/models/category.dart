class Category {
  final String id;
  final String name;
  final String icon;
  final int color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Categorías predefinidas
  static const Category panes = Category(
    id: 'panes',
    name: 'Panes',
    icon: '🍞',
    color: 0xFFE8B757,
  );

  static const Category pasteles = Category(
    id: 'pasteles',
    name: 'Pasteles',
    icon: '🎂',
    color: 0xFFE8A87C,
  );

  static const Category pastas = Category(
    id: 'pastas',
    name: 'Pastas',
    icon: '🥐',
    color: 0xFFC4991B,
  );

  static const Category dulces = Category(
    id: 'dulces',
    name: 'Dulces',
    icon: '🍪',
    color: 0xFFF4A460,
  );

  static const Category bebidas = Category(
    id: 'bebidas',
    name: 'Bebidas',
    icon: '☕',
    color: 0xFF8B4513,
  );

  static List<Category> getAll() => [
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

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '📦',
      color: map['color'] ?? 0xFF000000,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
