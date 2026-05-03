import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static const String dbName = 'panaderia_liz.db';
  static const int schemaVersion = 3;

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Database? _database;
  Completer<Database>? _initCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Prevent concurrent initialization
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _initCompleter!.complete(_database!);
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // On web, use the database name directly (sqflite_ffi_web handles storage)
      path = dbName;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, dbName);
    }

    return openDatabase(
      path,
      version: schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de productos
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla de ventas
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        total REAL NOT NULL,
        items_count INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        payment_method TEXT DEFAULT 'cash',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tabla de items de venta
    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // Índices para mejora de rendimiento
    await db.execute(
      'CREATE INDEX idx_sales_user_id ON sales(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sales_created_at ON sales(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id)',
    );

    // Insertar datos iniciales
    await _seedInitialData(db);
  }

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Drop existing tables and recreate
    await db.execute('DROP TABLE IF EXISTS sale_items');
    await db.execute('DROP TABLE IF EXISTS sales');
    await db.execute('DROP TABLE IF EXISTS products');
    await db.execute('DROP TABLE IF EXISTS users');
    
    // Recreate schema
    await _onCreate(db, newVersion);
  }

  Future<void> _seedInitialData(Database db) async {
    // Usuarios iniciales
    await db.insert(
      'users',
      {
        'id': '1',
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.insert(
      'users',
      {
        'id': '2',
        'username': 'empleado',
        'password': '1234',
        'role': 'employee',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Productos iniciales
    final products = [
      {
        'id': '1',
        'name': 'Pan',
        'price': 1.00,
        'stock': 50,
        'category': 'Pan',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'name': 'Barra',
        'price': 0.80,
        'stock': 60,
        'category': 'Pan',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'name': 'Croissant',
        'price': 1.20,
        'stock': 30,
        'category': 'Pastelería',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'name': 'Donut',
        'price': 0.90,
        'stock': 40,
        'category': 'Pastelería',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'name': 'Magdalena',
        'price': 0.70,
        'stock': 35,
        'category': 'Pastelería',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': '6',
        'name': 'Baguette',
        'price': 1.50,
        'stock': 25,
        'category': 'Pan',
        'is_available': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final product in products) {
      await db.insert(
        'products',
        product,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Métodos de utilidad
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('sale_items');
    await db.delete('sales');
    await db.delete('products');
    await db.delete('users');
  }
}
