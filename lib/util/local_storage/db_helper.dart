import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aaliyahs_collection_estore/data/models/product_model.dart';
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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
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
          CategoryModel TEXT,
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
          CategoryModel_name TEXT,
          CategoryModel_id INTEGER,
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
      await txn.execute('CREATE INDEX idx_cart_ProductModel_id ON cart(productId)');
      await txn.execute('CREATE INDEX idx_fav_ProductModel_id ON favorites(id)');
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Handle missing columns in favorites table from version 1
      final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(favorites)');
      final bool hasCategoryName = columns.any((column) => column['name'] == 'CategoryModel_name');
      final bool hasCategoryId = columns.any((column) => column['name'] == 'CategoryModel_id');

      if (!hasCategoryName) {
        await db.execute('ALTER TABLE favorites ADD COLUMN CategoryModel_name TEXT');
      }
      if (!hasCategoryId) {
        await db.execute('ALTER TABLE favorites ADD COLUMN CategoryModel_id INTEGER');
      }
    }
  }

  // --- CART OPERATIONS ---

  Future<int> insertCart(ProductModel productModel) async {
    try {
      final Database db = await database;
      return await db.insert('cart', {
        'productId': productModel.id,
        'name': productModel.name,
        'description': productModel.description,
        'price': productModel.price,
        'image': productModel.image,
        'CategoryModel': productModel.categoryName,
        'quantity': productModel.quantity,
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

  Future<List<ProductModel>> getCartItems() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('cart');

      return maps.map((item) => ProductModel(
        id: item['productId'],
        name: item['name'],
        description: item['description'],
        price: item['price'],
        images: [item['image'] ?? ''],
        categoryName: item['CategoryModel'],
        quantity: item['quantity'],
      )).toList();
    } catch (e) {
      debugPrint("DB Fetch Cart Error: $e");
      return [];
    }
  }

  // --- FAVORITES OPERATIONS ---

  Future<int> insertFavorite(ProductModel productModel) async {
    try {
      final Database db = await database;
      return await db.insert(
        'favorites',
        {
          'id': productModel.id,
          'name': productModel.name,
          'description': productModel.description,
          'price': productModel.price,
          'images': jsonEncode(productModel.images),
          'CategoryModel_name': productModel.categoryName,
          'CategoryModel_id': productModel.categoryId,
          'quantity': productModel.quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint("DB Insert Favorite Error: $e");
      return -1;
    }
  }

  Future<int> deleteFavorite(ProductModel productModel) async {
    try {
      final Database db = await database;
      if (productModel.id != null) {
        return await db.delete(
          'favorites',
          where: 'id = ?',
          whereArgs: [productModel.id],
        );
      } else {
        return await db.delete(
          'favorites',
          where: 'name = ?',
          whereArgs: [productModel.name],
        );
      }
    } catch (e) {
      debugPrint("DB Delete Favorite Error: $e");
      return -1;
    }
  }

  Future<List<ProductModel>> getFavorites() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('favorites');

      return maps.map((item) => ProductModel(
        id: item['id'],
        name: item['name'],
        description: item['description'],
        price: item['price'],
        images: item['images'] != null ? List<String>.from(jsonDecode(item['images'])) : [],
        categoryName: item['CategoryModel_name'],
        categoryId: item['CategoryModel_id'],
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
