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
      version: 2, // Incremented version
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS favorites');
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
      },
      onCreate: (db, version) async {
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
      },
    );
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
}
