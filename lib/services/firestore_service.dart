import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panaderia_liz/models/index.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════
  // PRODUCTS
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _db.collection('products');

  Future<List<Product>> getAllProducts() async {
    final snap = await _productsRef
        .where('is_available', isEqualTo: 1)
        .get();
    final products = snap.docs.map((d) => Product.fromMap({'id': d.id, ...d.data()})).toList();
    products.sort((a, b) => a.name.compareTo(b.name));
    return products;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final snap = await _productsRef
        .where('category', isEqualTo: category)
        .where('is_available', isEqualTo: 1)
        .get();
    return snap.docs.map((d) => Product.fromMap({'id': d.id, ...d.data()})).toList();
  }

  Future<List<String>> getCategories() async {
    final products = await getAllProducts();
    return products.map((p) => p.category).toSet().toList()..sort();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<Product?> addProduct(String id, String name, double price, String category, int stock) async {
    final product = Product(
      id: id,
      name: name,
      price: price,
      category: category,
      stock: stock,
      createdAt: DateTime.now(),
    );
    await _productsRef.doc(id).set(_productToFirestore(product));
    return product;
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productsRef.doc(product.id).update(_productToFirestore(product));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _productsRef.doc(productId).update({'stock': newStock});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> decreaseStock(String productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null || product.stock < quantity) return false;
    return updateStock(productId, product.stock - quantity);
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    final snap = await _productsRef
        .where('is_available', isEqualTo: 1)
        .where('stock', isLessThanOrEqualTo: threshold)
        .get();
    final products = snap.docs.map((d) => Product.fromMap({'id': d.id, ...d.data()})).toList();
    products.sort((a, b) => a.stock.compareTo(b.stock));
    return products;
  }

  Map<String, dynamic> _productToFirestore(Product p) => {
    'name': p.name,
    'price': p.price,
    'category': p.category,
    'stock': p.stock,
    'is_available': p.isAvailable ? 1 : 0,
    'created_at': p.createdAt.toIso8601String(),
    'image_url': p.imageUrl,
  };

  // ══════════════════════════════════════════════
  // SALES
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _salesRef =>
      _db.collection('sales');

  Future<Sale?> saveSaleWithTransaction(
    String userId,
    List<CartItem> cartItems,
    double total, {
    String paymentMethod = 'cash',
  }) async {
    try {
      final saleId = _db.collection('_').doc().id; // auto-id
      final saleItems = <SaleItem>[];

      for (final cartItem in cartItems) {
        saleItems.add(SaleItem(
          id: _db.collection('_').doc().id,
          saleId: saleId,
          productId: cartItem.productId,
          productName: cartItem.productName,
          quantity: cartItem.quantity,
          unitPrice: cartItem.price,
          total: cartItem.total,
        ));
      }

      final sale = Sale(
        id: saleId,
        userId: userId,
        items: saleItems,
        total: total,
        createdAt: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      // Use a batch to write sale + deduct stock atomically
      final batch = _db.batch();

      batch.set(_salesRef.doc(saleId), {
        'user_id': userId,
        'total': total,
        'items_count': cartItems.length,
        'created_at': sale.createdAt.toIso8601String(),
        'payment_method': paymentMethod,
      });

      // Write each sale item as a subcollection doc
      for (final item in saleItems) {
        batch.set(
          _salesRef.doc(saleId).collection('items').doc(item.id),
          item.toMap(),
        );
      }

      // Deduct stock
      for (final cartItem in cartItems) {
        final productDoc = await _productsRef.doc(cartItem.productId).get();
        if (!productDoc.exists) {
          throw Exception('Producto no encontrado: ${cartItem.productId}');
        }
        final currentStock = productDoc.data()!['stock'] as int;
        if (currentStock < cartItem.quantity) {
          throw Exception('Stock insuficiente para ${cartItem.productName}');
        }
        batch.update(
          _productsRef.doc(cartItem.productId),
          {'stock': currentStock - cartItem.quantity},
        );
      }

      await batch.commit();
      return sale;
    } catch (e) {
      return null;
    }
  }

  Future<List<Sale>> getAllSales() async {
    final snap = await _salesRef.orderBy('created_at', descending: true).get();
    final sales = <Sale>[];

    for (final doc in snap.docs) {
      final sale = Sale.fromMap({'id': doc.id, ...doc.data()});
      // Load items subcollection
      final itemsSnap = await doc.reference.collection('items').get();
      final items = itemsSnap.docs.map((d) => SaleItem.fromMap(d.data())).toList();
      sales.add(sale.copyWith(items: items));
    }

    return sales;
  }

  Future<Sale?> getSaleById(String saleId) async {
    final doc = await _salesRef.doc(saleId).get();
    if (!doc.exists) return null;
    final sale = Sale.fromMap({'id': doc.id, ...doc.data()!});
    final itemsSnap = await doc.reference.collection('items').get();
    final items = itemsSnap.docs.map((d) => SaleItem.fromMap(d.data())).toList();
    return sale.copyWith(items: items);
  }

  Future<int> getSalesCount() async {
    final snap = await _salesRef.count().get();
    return snap.count ?? 0;
  }

  Future<double> getTotalSalesAmount() async {
    final snap = await _salesRef.get();
    return snap.docs.fold<double>(0.0, (sum, doc) => sum + ((doc.data()['total'] as num?)?.toDouble() ?? 0));
  }

  Future<double> getDailyTotal() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final snap = await _salesRef
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .get();
    return snap.docs.fold<double>(0.0, (sum, doc) => sum + ((doc.data()['total'] as num?)?.toDouble() ?? 0));
  }

  // ══════════════════════════════════════════════
  // USERS (for Firebase Auth custom claims alternative)
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final snap = await _usersRef.where('username', isEqualTo: username).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return {'id': snap.docs.first.id, ...snap.docs.first.data()};
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snap = await _usersRef.get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> addUser(String id, String username, String password, String role) async {
    await _usersRef.doc(id).set({
      'username': username,
      'password': password,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _usersRef.doc(userId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(userId).update(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════
  // SEED DATA
  // ══════════════════════════════════════════════

  Future<void> seedIfEmpty() async {
    final productsSnap = await _productsRef.limit(1).get();
    if (productsSnap.docs.isNotEmpty) return; // Already has data

    final batch = _db.batch();

    // Seed products
    final seedProducts = [
      {'id': '1', 'name': 'Pan', 'price': 1.00, 'category': 'Pan', 'stock': 50},
      {'id': '2', 'name': 'Barra', 'price': 0.80, 'category': 'Pan', 'stock': 60},
      {'id': '3', 'name': 'Croissant', 'price': 1.20, 'category': 'Pastelería', 'stock': 30},
      {'id': '4', 'name': 'Donut', 'price': 0.90, 'category': 'Pastelería', 'stock': 40},
      {'id': '5', 'name': 'Magdalena', 'price': 0.70, 'category': 'Pastelería', 'stock': 35},
      {'id': '6', 'name': 'Baguette', 'price': 1.50, 'category': 'Pan', 'stock': 25},
    ];

    for (final p in seedProducts) {
      batch.set(_productsRef.doc(p['id'] as String), {
        'name': p['name'],
        'price': p['price'],
        'category': p['category'],
        'stock': p['stock'],
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Seed users
    batch.set(_usersRef.doc('1'), {
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin',
      'created_at': DateTime.now().toIso8601String(),
    });
    batch.set(_usersRef.doc('2'), {
      'username': 'empleado',
      'password': '1234',
      'role': 'employee',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Seed raw materials
    final seedMaterials = [
      {'id': 'rm1', 'name': 'Harina', 'unit': 'kg', 'stock': 100.0, 'min_stock': 20.0, 'price_per_unit': 0.80},
      {'id': 'rm2', 'name': 'Azúcar', 'unit': 'kg', 'stock': 50.0, 'min_stock': 10.0, 'price_per_unit': 1.00},
      {'id': 'rm3', 'name': 'Levadura', 'unit': 'kg', 'stock': 10.0, 'min_stock': 2.0, 'price_per_unit': 3.50},
      {'id': 'rm4', 'name': 'Mantequilla', 'unit': 'kg', 'stock': 30.0, 'min_stock': 5.0, 'price_per_unit': 5.00},
      {'id': 'rm5', 'name': 'Huevos', 'unit': 'unidades', 'stock': 200.0, 'min_stock': 30.0, 'price_per_unit': 0.15},
      {'id': 'rm6', 'name': 'Sal', 'unit': 'kg', 'stock': 20.0, 'min_stock': 3.0, 'price_per_unit': 0.50},
      {'id': 'rm7', 'name': 'Leche', 'unit': 'litros', 'stock': 40.0, 'min_stock': 10.0, 'price_per_unit': 0.90},
    ];

    for (final m in seedMaterials) {
      batch.set(_rawMaterialsRef.doc(m['id'] as String), {
        'name': m['name'],
        'unit': m['unit'],
        'stock': m['stock'],
        'min_stock': m['min_stock'],
        'price_per_unit': m['price_per_unit'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();

    // Seed recipes (need sub-collections, must be done separately)
    await _recipesRef.doc('rec1').set({
      'product_id': '1',
      'product_name': 'Pan',
      'yield': 10,
      'ingredients': [
        {'raw_material_id': 'rm1', 'raw_material_name': 'Harina', 'quantity': 1.0},
        {'raw_material_id': 'rm3', 'raw_material_name': 'Levadura', 'quantity': 0.02},
        {'raw_material_id': 'rm6', 'raw_material_name': 'Sal', 'quantity': 0.02},
        {'raw_material_id': 'rm7', 'raw_material_name': 'Leche', 'quantity': 0.3},
      ],
      'created_at': DateTime.now().toIso8601String(),
    });

    await _recipesRef.doc('rec2').set({
      'product_id': '3',
      'product_name': 'Croissant',
      'yield': 12,
      'ingredients': [
        {'raw_material_id': 'rm1', 'raw_material_name': 'Harina', 'quantity': 0.5},
        {'raw_material_id': 'rm4', 'raw_material_name': 'Mantequilla', 'quantity': 0.3},
        {'raw_material_id': 'rm2', 'raw_material_name': 'Azúcar', 'quantity': 0.1},
        {'raw_material_id': 'rm5', 'raw_material_name': 'Huevos', 'quantity': 3.0},
        {'raw_material_id': 'rm3', 'raw_material_name': 'Levadura', 'quantity': 0.01},
      ],
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ══════════════════════════════════════════════
  // RAW MATERIALS
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _rawMaterialsRef =>
      _db.collection('raw_materials');

  Future<List<RawMaterial>> getAllRawMaterials() async {
    final snap = await _rawMaterialsRef.get();
    final materials = snap.docs
        .map((d) => RawMaterial.fromMap({'id': d.id, ...d.data()}))
        .toList();
    materials.sort((a, b) => a.name.compareTo(b.name));
    return materials;
  }

  Future<RawMaterial?> getRawMaterialById(String id) async {
    final doc = await _rawMaterialsRef.doc(id).get();
    if (!doc.exists) return null;
    return RawMaterial.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<void> addRawMaterial(RawMaterial material) async {
    await _rawMaterialsRef.doc(material.id).set({
      'name': material.name,
      'unit': material.unit,
      'stock': material.stock,
      'min_stock': material.minStock,
      'price_per_unit': material.pricePerUnit,
      'created_at': material.createdAt.toIso8601String(),
    });
  }

  Future<void> updateRawMaterial(RawMaterial material) async {
    await _rawMaterialsRef.doc(material.id).update({
      'name': material.name,
      'unit': material.unit,
      'stock': material.stock,
      'min_stock': material.minStock,
      'price_per_unit': material.pricePerUnit,
    });
  }

  Future<void> deleteRawMaterial(String id) async {
    await _rawMaterialsRef.doc(id).delete();
  }

  Future<List<RawMaterial>> getLowStockMaterials() async {
    final all = await getAllRawMaterials();
    return all.where((m) => m.isLowStock).toList();
  }

  // ══════════════════════════════════════════════
  // RECIPES
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _recipesRef =>
      _db.collection('recipes');

  Future<List<Recipe>> getAllRecipes() async {
    final snap = await _recipesRef.get();
    return snap.docs.map((d) {
      final data = d.data();
      return Recipe.fromMap({'id': d.id, ...data});
    }).toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    final doc = await _recipesRef.doc(id).get();
    if (!doc.exists) return null;
    return Recipe.fromMap({'id': doc.id, ...doc.data()!});
  }

  Future<Recipe?> getRecipeByProductId(String productId) async {
    final snap = await _recipesRef
        .where('product_id', isEqualTo: productId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Recipe.fromMap({'id': snap.docs.first.id, ...snap.docs.first.data()});
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipesRef.doc(recipe.id).set({
      'product_id': recipe.productId,
      'product_name': recipe.productName,
      'yield': recipe.outputQty,
      'ingredients': recipe.ingredients.map((i) => i.toMap()).toList(),
      'created_at': recipe.createdAt.toIso8601String(),
    });
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipesRef.doc(recipe.id).update({
      'product_id': recipe.productId,
      'product_name': recipe.productName,
      'yield': recipe.outputQty,
      'ingredients': recipe.ingredients.map((i) => i.toMap()).toList(),
    });
  }

  Future<void> deleteRecipe(String id) async {
    await _recipesRef.doc(id).delete();
  }

  // ══════════════════════════════════════════════
  // PRODUCTION
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _productionRef =>
      _db.collection('production');

  /// Register a production run:
  /// 1. Validates raw material stock
  /// 2. Deducts raw materials
  /// 3. Adds product stock
  /// 4. Saves production record
  Future<ProductionRecord?> registerProduction({
    required String productId,
    required String productName,
    required String recipeId,
    required int batches,
    required String userId,
    required String userName,
    String? notes,
  }) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) throw Exception('Receta no encontrada');

      final totalUnits = recipe.outputQty * batches;

      // Validate raw material stock
      for (final ing in recipe.ingredients) {
        final needed = ing.quantity * batches;
        final material = await getRawMaterialById(ing.rawMaterialId);
        if (material == null) {
          throw Exception('Materia prima "${ing.rawMaterialName}" no encontrada');
        }
        if (material.stock < needed) {
          throw Exception(
            'Stock insuficiente de ${ing.rawMaterialName}: '
            'necesitas ${needed.toStringAsFixed(2)} ${material.unit}, '
            'hay ${material.stock.toStringAsFixed(2)} ${material.unit}',
          );
        }
      }

      final batch = _db.batch();

      // Deduct raw materials
      for (final ing in recipe.ingredients) {
        final needed = ing.quantity * batches;
        final material = (await getRawMaterialById(ing.rawMaterialId))!;
        batch.update(_rawMaterialsRef.doc(ing.rawMaterialId), {
          'stock': material.stock - needed,
        });
      }

      // Add product stock
      final product = await getProductById(productId);
      if (product != null) {
        batch.update(_productsRef.doc(productId), {
          'stock': product.stock + totalUnits,
        });
      }

      // Save production record
      final recordId = _db.collection('_').doc().id;
      final record = ProductionRecord(
        id: recordId,
        productId: productId,
        productName: productName,
        recipeId: recipeId,
        quantity: totalUnits,
        userId: userId,
        userName: userName,
        notes: notes,
      );
      batch.set(_productionRef.doc(recordId), record.toMap());

      await batch.commit();
      return record;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductionRecord>> getAllProduction() async {
    final snap = await _productionRef.orderBy('created_at', descending: true).get();
    return snap.docs
        .map((d) => ProductionRecord.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<ProductionRecord>> getTodayProduction() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final snap = await _productionRef
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .get();
    final records = snap.docs
        .map((d) => ProductionRecord.fromMap({'id': d.id, ...d.data()}))
        .toList();
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  // ══════════════════════════════════════════════
  // DELIVERY ORDERS (Reparto)
  // ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> get _deliveriesRef =>
      _db.collection('deliveries');

  Future<DeliveryOrder?> createDeliveryOrder(DeliveryOrder order) async {
    try {
      await _deliveriesRef.doc(order.id).set(order.toMap()..remove('id'));
      return order;
    } catch (e) {
      return null;
    }
  }

  Future<List<DeliveryOrder>> getAllDeliveryOrders() async {
    final snap = await _deliveriesRef.get();
    final orders = snap.docs
        .map((d) => DeliveryOrder.fromMap({'id': d.id, ...d.data()}))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<List<DeliveryOrder>> getActiveDeliveryOrders() async {
    final all = await getAllDeliveryOrders();
    return all
        .where((o) =>
            o.status != DeliveryStatus.delivered &&
            o.status != DeliveryStatus.cancelled)
        .toList();
  }

  Future<List<DeliveryOrder>> getTodayDeliveryOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final snap = await _deliveriesRef
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .get();
    final orders = snap.docs
        .map((d) => DeliveryOrder.fromMap({'id': d.id, ...d.data()}))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Future<bool> updateDeliveryStatus(String orderId, DeliveryStatus status) async {
    try {
      final data = <String, dynamic>{'status': status.value};
      if (status == DeliveryStatus.delivered) {
        data['delivered_at'] = DateTime.now().toIso8601String();
      }
      await _deliveriesRef.doc(orderId).update(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignDelivery(
      String orderId, String userId, String userName) async {
    try {
      await _deliveriesRef.doc(orderId).update({
        'assigned_user_id': userId,
        'assigned_user_name': userName,
        'status': DeliveryStatus.preparing.value,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateDeliveryOrder(DeliveryOrder order) async {
    try {
      await _deliveriesRef.doc(order.id).update(order.toMap()..remove('id'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDeliveryOrder(String orderId) async {
    try {
      await _deliveriesRef.doc(orderId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
