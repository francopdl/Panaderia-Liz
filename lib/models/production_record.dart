/// A record of a production run — what was produced, when, by whom
class ProductionRecord {
  final String id;
  final String productId;
  final String productName;
  final String? recipeId;
  final int quantity; // units produced
  final String userId;
  final String userName;
  final String? notes;
  final DateTime createdAt;

  ProductionRecord({
    required this.id,
    required this.productId,
    required this.productName,
    this.recipeId,
    required this.quantity,
    required this.userId,
    required this.userName,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductionRecord.fromMap(Map<String, dynamic> map) {
    return ProductionRecord(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String? ?? '',
      productName: map['product_name'] as String? ?? '',
      recipeId: map['recipe_id'] as String?,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'recipe_id': recipeId,
      'quantity': quantity,
      'user_id': userId,
      'user_name': userName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
