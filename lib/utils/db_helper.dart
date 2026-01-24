import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:aaliyahs_collection_estore/src/features/core/models/product.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'cart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId INTEGER,
            name TEXT,
            description TEXT,
            price TEXT,
            image TEXT,
            category TEXT,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insert(Product product) async {
    final db = await database;
    return await db.insert('cart', {
      'productId': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'image': product.image, // Gets first image
      'category': product.categoryName,
      'quantity': product.quantity,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateQuantity(String name, int quantity) async {
    final db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<int> delete(String name) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<List<Product>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['productId'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        images: [maps[i]['image'] ?? ''], // Wrap in list
        categoryName: maps[i]['category'],
        quantity: maps[i]['quantity'],
      );
    });
  }
}
