/*import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =============================
  // GET DATABASE
  // =============================
  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'wallet.db');

    _db = await openDatabase(
      path,
      version: 7,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            type TEXT,
            category TEXT,
            subcategory TEXT,
            note TEXT,
            date TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE subcategories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            name TEXT,
            UNIQUE(category, name)
          )
        ''');

        // Default categories
        List<String> defaults = [
          'Food', 'Travel', 'Salary',
          'Shopping', 'Recharge', 'Others'
        ];

        for (var c in defaults) {
          await db.insert('categories', {'name': c});
        }
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS subcategories(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT,
              name TEXT,
              UNIQUE(category, name)
            )
          ''');
        }

        if (oldVersion < 7) {
          await db.execute('''
            ALTER TABLE transactions ADD COLUMN subcategory TEXT
          ''');
        }
      },
    );

    return _db!; 
  }

  // =============================
  // COMMON INSERT
  // =============================
  static Future<void> _insert({
    required double amount,
    required String type,
    required String category,
    String subcategory = "",
    required String note,
    required DateTime date,
  }) async {
    final db = await getDB();

    String finalType =
        (type.toLowerCase() == "income") ? "Income" : "Expense";

    await db.insert('transactions', {
      'amount': amount,
      'type': finalType,
      'category': category,
      'subcategory': subcategory,
      'note': note,
      'date': date.toIso8601String(),
    });
  }

  // =============================
  // INSERT METHODS
  // =============================
  static Future<void> insertTransaction(
    double amount,
    String type,
    String category,
    String subcategory,
  ) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      subcategory: subcategory,
      note: "Manual Entry",
      date: DateTime.now(),
    );
  }

  static Future<void> insertSMSTransaction({
    required double amount,
    required String type,
    required String category,
    required String note,
    required DateTime date,
  }) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      note: note,
      date: date,
    );
  }

  static Future<void> insertPDFTransaction({
    required double amount,
    required String type,
    required String category,
    String note = "PDF Import",
    DateTime? date,
  }) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      note: note,
      date: date ?? DateTime.now(),
    );
  }

  // =============================
  // GET DATA
  // =============================
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await getDB();
    return db.query('transactions', orderBy: 'date DESC');
  }

  // 🔥 NEW: FILTER BY DATE
  static Future<List<Map<String, dynamic>>> getTransactionsByDate(
    DateTime from,
    DateTime to,
  ) async {
    final db = await getDB();

    return db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        from.toIso8601String(),
        to.toIso8601String()
      ],
    );
  }

  // =============================
  // DELETE
  // =============================
  static Future<void> deleteTransaction(int id) async {
    final db = await getDB();
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // =============================
  // SUMMARY
  // =============================
  static Future<Map<String, double>> getSummary() async {
    final db = await getDB();

    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = "Income" THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = "Expense" THEN amount ELSE 0 END) as expense
      FROM transactions
    ''');

    double income = (result[0]['income'] as num?)?.toDouble() ?? 0.0;
    double expense = (result[0]['expense'] as num?)?.toDouble() ?? 0.0;

    return {
      "income": income,
      "expense": expense,
      "balance": income - expense,
    };
  }

  // =============================
  // CATEGORY
  // =============================
  static Future<void> insertCategory(String name) async {
    final db = await getDB();
    await db.insert('categories', {'name': name});
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await getDB();
    return db.query('categories');
  }

  // =============================
  // SUBCATEGORY
  // =============================
  static Future<void> insertSubCategory(
      String category, String name) async {
    final db = await getDB();

    try {
      await db.insert('subcategories', {
        'category': category,
        'name': name,
      });
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getSubCategories() async {
    final db = await getDB();
    return db.query('subcategories');
  }

  static Future<void> deleteSubCategory(int id) async {
    final db = await getDB();
    await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
  }

  // =============================
  // 🔥 DEBUG RESET
  // =============================
  static Future<void> clearDB() async {
    final db = await getDB();
    await db.delete('transactions');
  }
}*/
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =============================
  // GET DATABASE
  // =============================
  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'wallet.db');

    _db = await openDatabase(
      path,
      version: 8,

      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE,
              password TEXT
            )
           ''' );


        // =========================
        // TRANSACTIONS TABLE
        // =========================
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            subcategory TEXT,
            note TEXT,
            date TEXT
          )
        ''');

        // =========================
        // CATEGORY TABLE
        // =========================
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
          )
        ''');

        // =========================
        // SUBCATEGORY TABLE
        // =========================
        await db.execute('''
          CREATE TABLE subcategories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            name TEXT,
            UNIQUE(category, name)
          )
        ''');

        // =========================
        // DEFAULT CATEGORIES
        // =========================
        List<String> defaults = [
          'food',
          'travel',
          'salary',
          'shopping',
          'recharge',
          'others'
        ];

        for (var c in defaults) {
          await db.insert('categories', {'name': c});
        }
      },

     onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 7) {
    await db.execute('''
      ALTER TABLE transactions ADD COLUMN subcategory TEXT
    ''');
  }

  if (oldVersion < 8) {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');
  }
},

    );

    return _db!;
  }

  // =============================
  // INSERT TRANSACTION (PRIVATE)
  // =============================
  static Future<void> _insert({
    required double amount,
    required String type,
    required String category,
    String subcategory = "",
    required String note,
    required DateTime date,
  }) async {
    final db = await getDB();

    String finalType =
        (type.toLowerCase() == "income") ? "Income" : "Expense";

    await db.insert('transactions', {
      'username' : username,
      'amount': amount,
      'type': finalType,
      'category': category,
      'subcategory': subcategory,
      'note': note,
      'date': date.toIso8601String(),
    });
  }

  // =============================
  // TRANSACTIONS
  // =============================
  static Future<void> insertTransaction(
    double amount,
    String type,
    String category,
    String subcategory,
  ) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      subcategory: subcategory,
      note: "Manual Entry",
      date: DateTime.now(),
    );
  }

static Future<List<Map<String, dynamic>>>getTransactions() async {
  final db = await getDB();

  final prefs =
      await SharedPreferences.getInstance();

  String username =
      prefs.getString('username') ?? '';

  return await db.query(
    'transactions',
    where: 'username = ?',
    whereArgs: [username],
    orderBy: 'id DESC',
  );
}

  // =============================
  // CATEGORY (FIXED)
  // =============================
  static Future<void> insertCategory(String name) async {
    final db = await getDB();

    final key = name.trim().toLowerCase();

    final existing = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [key],
    );

    if (existing.isNotEmpty) return;

    await db.insert('categories', {'name': key});
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await getDB();
    return db.query('categories', orderBy: 'name ASC');
  }

  // =============================
  // SUBCATEGORY (FIXED)
  // =============================
  static Future<void> insertSubCategory(
      String category, String name) async {
    final db = await getDB();

    final catKey = category.trim().toLowerCase();
    final subKey = name.trim().toLowerCase();

    final existing = await db.query(
      'subcategories',
      where: 'category = ? AND name = ?',
      whereArgs: [catKey, subKey],
    );

    if (existing.isNotEmpty) return;

    await db.insert('subcategories', {
      'category': catKey,
      'name': subKey,
    });
  }

  static Future<List<Map<String, dynamic>>> getSubCategories() async {
    final db = await getDB();
    return db.query('subcategories', orderBy: 'category ASC');
  }

  static Future<void> deleteSubCategory(int id) async {
    final db = await getDB();
    await db.delete(
      'subcategories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============================
  // DELETE TRANSACTION
  // =============================
  static Future<void> deleteTransaction(int id) async {
    final db = await getDB();
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =============================
  // SUMMARY
  // =============================
  static Future<Map<String, double>> getSummary() async {
    final db = await getDB();

    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = "Income" THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = "Expense" THEN amount ELSE 0 END) as expense
      FROM transactions
    ''');

    double income =
        (result[0]['income'] as num?)?.toDouble() ?? 0.0;

    double expense =
        (result[0]['expense'] as num?)?.toDouble() ?? 0.0;

    return {
      "income": income,
      "expense": expense,
      "balance": income - expense,
    };
  }
  static Future<void> insertPDFTransaction({
  required double amount,
  required String type,
  required String category,
  String note = "PDF Import",
  DateTime? date,
}) async {
  final db = await getDB();

  String finalType =
      (type.toLowerCase() == "income") ? "Income" : "Expense";

  await db.insert('transactions', {
    'amount': amount,
    'type': finalType,
    'category': category,
    'subcategory': "",
    'note': note,
    'date': (date ?? DateTime.now()).toIso8601String(),
  });
}

  // =============================
  // DEBUG RESET
  // =============================
  static Future<void> clearDB() async {
    final db = await getDB();
    await db.delete('transactions');
  }
  // =============================
// REGISTER USER
// =============================
static Future<bool> registerUser(
  String username,
  String password,
) async {
  final db = await getDB();

  final existing = await db.query(
    'users',
    where: 'username = ?',
    whereArgs: [username],
  );

  if (existing.isNotEmpty) {
    return false;
  }

  await db.insert(
    'users',
    {
      'username': username,
      'password': password,
    },
  );

  return true;
}

// =============================
// LOGIN USER
// =============================
static Future<int?> loginUser(
  String username,
  String password,
) async {
  final db = await getDB();

  final result = await db.query(
    'users',
    where: 'username = ? AND password = ?',
    whereArgs: [username, password],
  );

  if (result.isEmpty) {
    return null;
  }

  return result.first['id'] as int;
}

// =============================
// GET USERS
// =============================
static Future<List<Map<String, dynamic>>> getUsers() async {
  final db = await getDB();
  return db.query('users');
}
} 

