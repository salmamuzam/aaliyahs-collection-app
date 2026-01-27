import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aaliyahs_collection_estore/src/features/shop/models/product.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Central database helper managing Cart, Wishlist, and Addresses.
/// Refined with Batch Operations, Indexing, and robust Error Handling.
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  /// Singleton database instance with Lazy Initialization.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'aaliyahs_collection_v2.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Optimization: Using Transactions for table creation
    await db.transaction((txn) async {
      // 1. Cart Table
      await txn.execute('''
        CREATE TABLE cart(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER,
          name TEXT UNIQUE,
          description TEXT,
          price TEXT,
          image TEXT,
          category TEXT,
          quantity INTEGER
        )
      ''');

      // 2. Favorites Table
      await txn.execute('''
        CREATE TABLE favorites (
          local_id INTEGER PRIMARY KEY AUTOINCREMENT,
          id INTEGER,
          name TEXT UNIQUE,
          description TEXT,
          price TEXT,
          images TEXT,
          category_name TEXT,
          category_id INTEGER,
          quantity INTEGER
        )
      ''');

      // 3. Addresses Table
      await txn.execute('''
        CREATE TABLE addresses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          label TEXT,
          address TEXT,
          city TEXT,
          state TEXT,
          zip TEXT,
          phone TEXT
        )
      ''');

      // Optimization: Add Indices for frequently searched columns (if not already unique)
      await txn.execute('CREATE INDEX idx_cart_product_id ON cart(productId)');
      await txn.execute('CREATE INDEX idx_fav_product_id ON favorites(id)');
    });
  }

  // --- CART OPERATIONS ---

  Future<int> insertCart(Product product) async {
    try {
      final Database db = await database;
      return await db.insert('cart', {
        'productId': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'image': product.image,
        'category': product.categoryName,
        'quantity': product.quantity,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint("DB Insert Cart Error: $e");
      return -1;
    }
  }

  Future<int> updateCartQuantity(String name, int quantity) async {
    try {
      final Database db = await database;
      return await db.update(
        'cart',
        {'quantity': quantity},
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      debugPrint("DB Update Cart Error: $e");
      return -1;
    }
  }

  Future<int> deleteFromCart(String name) async {
    try {
      final Database db = await database;
      return await db.delete(
        'cart',
        where: 'name = ?',
        whereArgs: [name],
      );
    } catch (e) {
      debugPrint("DB Delete Cart Error: $e");
      return -1;
    }
  }

  /// Optimization: Using Batch for clearing large datasets if needed
  Future<void> clearCart() async {
    try {
      final Database db = await database;
      final batch = db.batch();
      batch.delete('cart');
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint("DB Clear Cart Error: $e");
    }
  }

  Future<List<Product>> getCartItems() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('cart');

      return maps.map((item) => Product(
        id: item['productId'],
        name: item['name'],
        description: item['description'],
        price: item['price'],
        images: [item['image'] ?? ''],
        categoryName: item['category'],
        quantity: item['quantity'],
      )).toList();
    } catch (e) {
      debugPrint("DB Fetch Cart Error: $e");
      return [];
    }
  }

  // --- FAVORITES OPERATIONS ---

  Future<int> insertFavorite(Product product) async {
    try {
      final Database db = await database;
      return await db.insert(
        'favorites',
        {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'images': jsonEncode(product.images),
          'category_name': product.categoryName,
          'category_id': product.categoryId,
          'quantity': product.quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("DB Insert Favorite Error: $e");
      return -1;
    }
  }

  Future<int> deleteFavorite(Product product) async {
    try {
      final Database db = await database;
      if (product.id != null) {
        return await db.delete(
          'favorites',
          where: 'id = ?',
          whereArgs: [product.id],
        );
      } else {
        return await db.delete(
          'favorites',
          where: 'name = ?',
          whereArgs: [product.name],
        );
      }
    } catch (e) {
      debugPrint("DB Delete Favorite Error: $e");
      return -1;
    }
  }

  Future<List<Product>> getFavorites() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('favorites');

      return maps.map((item) => Product(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        price: item['price'],
        images: item['images'] != null ? List<String>.from(jsonDecode(item['images'])) : [],
        categoryName: item['category_name'],
        categoryId: item['category_id'],
        quantity: item['quantity'],
      )).toList();
    } catch (e) {
      debugPrint("DB Fetch Favorites Error: $e");
      return [];
    }
  }

  // --- ADDRESS OPERATIONS ---

  Future<int> insertAddress(Map<String, dynamic> address) async {
    try {
      final Database db = await database;
      return await db.insert('addresses', address, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint("DB Insert Address Error: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final Database db = await database;
      return await db.query('addresses');
    } catch (e) {
      debugPrint("DB Fetch Address Error: $e");
      return [];
    }
  }

  Future<int> deleteAddress(int id) async {
    try {
      final Database db = await database;
      return await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("DB Delete Address Error: $e");
      return -1;
    }
  }

  /// Explicitly Close Database to free up local resources.
  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
