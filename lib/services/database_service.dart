import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'estore_favorites.db');
    return await openDatabase(
      path,
      version: 3, // Incremented version for addresses
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS favorites');
          await _createFavoritesTable(db);
        }
        if (oldVersion < 3) {
          await _createAddressesTable(db);
        }
      },
      onCreate: (db, version) async {
        await _createFavoritesTable(db);
        await _createAddressesTable(db);
      },
    );
  }

  Future<void> _createFavoritesTable(Database db) async {
    await db.execute('''
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
  }

  Future<void> _createAddressesTable(Database db) async {
    await db.execute('''
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
  }

  Future<void> addFavorite(Product product) async {
    final db = await database;
    await db.insert(
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
  }

  Future<void> removeFavorite(Product product) async {
    final db = await database;
    if (product.id != null) {
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.delete(
        'favorites',
        where: 'name = ?',
        whereArgs: [product.name],
      );
    }
  }

  Future<List<Product>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        images: List<String>.from(jsonDecode(maps[i]['images'])),
        categoryName: maps[i]['category_name'],
        categoryId: maps[i]['category_id'],
        quantity: maps[i]['quantity'],
      );
    });
  }

  // Address Management
  Future<void> addAddress(Map<String, dynamic> address) async {
    final db = await database;
    await db.insert('addresses', address, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAddresses() async {
    final db = await database;
    return await db.query('addresses');
  }

  Future<void> deleteAddress(int id) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }
}
