import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =============================
  // 📌 GET DATABASE (Singleton)
  // =============================
  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'wallet.db');

    _db = await openDatabase(
      path,
      version: 2, // 🔥 upgraded version (supports schema update)
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');

        // Default categories
        await db.insert('categories', {'name': 'Food'});
        await db.insert('categories', {'name': 'Travel'});
        await db.insert('categories', {'name': 'Salary'});
      },

      // 🔥 handles old database upgrade safely
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE transactions ADD COLUMN date TEXT");
        }
      },
    );

    return _db!;
  }

  // =============================
  // 📌 TRANSACTION METHODS
  // =============================

  static Future<void> insertTransaction(
      double amount, String type, String category) async {
    final db = await getDB();

    await db.insert('transactions', {
      'amount': amount,
      'type': type,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await getDB();
    return db.query('transactions', orderBy: 'date DESC');
  }

  static Future<void> deleteTransaction(int id) async {
    final db = await getDB();
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateTransaction(
      int id, double amount, String type, String category) async {
    final db = await getDB();

    await db.update(
      'transactions',
      {
        'amount': amount,
        'type': type,
        'category': category,
        'date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============================
  // 📌 CATEGORY METHODS
  // =============================

  static Future<void> insertCategory(String name) async {
    final db = await getDB();
    await db.insert('categories', {'name': name});
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await getDB();
    return db.query('categories');
  }
}