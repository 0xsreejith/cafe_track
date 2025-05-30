import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/coffee_shop.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'favorite_coffee_shops';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'coffee_shops.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  static Future<int> insertCoffeeShop(CoffeeShop coffeeShop) async {
    final db = await database;
    return await db.insert(tableName, coffeeShop.toMap());
  }

  static Future<List<CoffeeShop>> getFavoriteCoffeeShops() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return CoffeeShop.fromMap(maps[i]);
    });
  }

  static Future<int> deleteCoffeeShop(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> isCoffeeShopFavorite(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    return maps.isNotEmpty;
  }

  static Future<CoffeeShop?> getCoffeeShopByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return CoffeeShop.fromMap(maps.first);
    }
    return null;
  }

  static Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
