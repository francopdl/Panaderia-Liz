/// Ingredient within a recipe — how much of a raw material is needed
class RecipeIngredient {
  final String rawMaterialId;
  final String rawMaterialName;
  final double quantity; // in the raw material's unit

  RecipeIngredient({
    required this.rawMaterialId,
    required this.rawMaterialName,
    required this.quantity,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      rawMaterialId: map['raw_material_id'] as String? ?? '',
      rawMaterialName: map['raw_material_name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'raw_material_id': rawMaterialId,
      'raw_material_name': rawMaterialName,
      'quantity': quantity,
    };
  }
}

/// Recipe links a product to the raw materials needed to produce one unit
class Recipe {
  final String id;
  final String productId;
  final String productName;
  final List<RecipeIngredient> ingredients;
  final int outputQty; // how many units this recipe produces
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.productId,
    required this.productName,
    required this.ingredients,
    this.outputQty = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Recipe.fromMap(Map<String, dynamic> map,
      {List<RecipeIngredient>? ingredients}) {
    return Recipe(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      ingredients: ingredients ??
          (map['ingredients'] as List<dynamic>?)
              ?.map((i) => RecipeIngredient.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      outputQty: (map['yield'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'yield': outputQty,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? productId,
    String? productName,
    List<RecipeIngredient>? ingredients,
    int? outputQty,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      ingredients: ingredients ?? this.ingredients,
      outputQty: outputQty ?? this.outputQty,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
