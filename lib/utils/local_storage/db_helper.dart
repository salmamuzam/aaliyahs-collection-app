import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/product_model.dart';
import 'package:aaliyahs_collection_estore/features/shop/models/cart_item.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Central database helper managing Cart, Wishlist, and Addresses.

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


      await txn.execute('CREATE INDEX idx_cart_ProductModel_id ON cart(productId)');
      await txn.execute('CREATE INDEX idx_fav_ProductModel_id ON favorites(id)');
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {

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

  Future<int> insertCart(CartItem item) async {
    try {
      final Database db = await database;
      return await db.insert('cart', {
        'productId': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price.toString(),
        'image': item.image,
        'CategoryModel': item.categoryName,
        'quantity': item.quantity,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('DB Insert Cart Error: $e');
      return -1;
    }
  }

  Future<int> updateCartQuantity(int productId, int quantity) async {
    try {
      final Database db = await database;
      return await db.update(
        'cart',
        {'quantity': quantity},
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      debugPrint('DB Update Cart Error: $e');
      return -1;
    }
  }

  Future<int> deleteFromCart(int productId) async {
    try {
      final Database db = await database;
      return await db.delete(
        'cart',
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      debugPrint('DB Delete Cart Error: $e');
      return -1;
    }
  }


  Future<void> clearCart() async {
    try {
      final Database db = await database;
      final batch = db.batch();
      batch.delete('cart');
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('DB Clear Cart Error: $e');
    }
  }

  Future<List<CartItem>> getCartItems() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query('cart');

      return maps.map((item) => CartItem(
        id: item['productId'],
        name: item['name'],
        description: item['description'],
        price: double.tryParse(item['price'].toString()) ?? 0.0,
        image: item['image'] ?? '',
        categoryName: item['CategoryModel'],
        quantity: item['quantity'],
      )).toList();
    } catch (e) {
      debugPrint('DB Fetch Cart Error: $e');
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
      debugPrint('DB Insert Favorite Error: $e');
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
      debugPrint('DB Delete Favorite Error: $e');
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
      debugPrint('DB Fetch Favorites Error: $e');
      return [];
    }
  }

  // --- ADDRESS OPERATIONS ---

  Future<int> insertAddress(Map<String, dynamic> address) async {
    try {
      final Database db = await database;
      return await db.insert('addresses', address, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('DB Insert Address Error: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final Database db = await database;
      return await db.query('addresses');
    } catch (e) {
      debugPrint('DB Fetch Address Error: $e');
      return [];
    }
  }

  Future<int> deleteAddress(int id) async {
    try {
      final Database db = await database;
      return await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('DB Delete Address Error: $e');
      return -1;
    }
  }

  /// Close Database 
  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
