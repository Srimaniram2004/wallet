// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DBHelper {
//   static Database? _db;

//   // =============================
//   // GET DATABASE
//   // =============================
//   static Future<Database> getDB() async {
//     if (_db != null) return _db!;

//     final path = join(await getDatabasesPath(), 'wallet.db');

//     _db = await openDatabase(
//       path,
//       version: 8,

//       onCreate: (db, version) async {
//         await db.execute('''
//             CREATE TABLE users(
//               id INTEGER PRIMARY KEY AUTOINCREMENT,
//               username TEXT UNIQUE,
//               password TEXT
//             )
//            ''' );


//         // =========================
//         // TRANSACTIONS TABLE
//         // =========================
//         await db.execute('''
//           CREATE TABLE transactions(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             username TEXT,
//             amount REAL,
//             type TEXT,
//             category TEXT,
//             subcategory TEXT,
//             language TEXT,
//             note TEXT,
//             date TEXT
//           )
//         ''');

//         // =========================
//         // CATEGORY TABLE
//         // =========================
//         await db.execute('''
//           CREATE TABLE categories(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT UNIQUE
//           )
//         ''');

//         // =========================
//         // SUBCATEGORY TABLE
//         // =========================
//         await db.execute('''
//           CREATE TABLE subcategories(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             category TEXT,
//             name TEXT,
//             UNIQUE(category, name)
//           )
//         ''');

//         // =========================
//         // DEFAULT CATEGORIES
//         // =========================
//         List<String> defaults = [
//          /* 'food',
//           'travel',*/
//           'salary',
//           /*'shopping',
//           'recharge',
//           'others'*/
//         ];

//         for (var c in defaults) {
//           await db.insert('categories', {'name': c});
//         }
//       },

//      onUpgrade: (db, oldVersion, newVersion) async {
//   if (oldVersion < 7) {
//     await db.execute('''
//       ALTER TABLE transactions ADD COLUMN subcategory TEXT
//     ''');
//   }

//   if (oldVersion < 8) {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS users(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         username TEXT UNIQUE,
//         password TEXT
//       )
//     ''');
//   }
// },

//     );

//     return _db!;
//   }

//   // =============================
//   // INSERT TRANSACTION (PRIVATE)
//   // =============================
//  static Future<void> _insert({
//   required double amount,
//   required String type,
//   required String category,
//   String subcategory = "",
//   required String note,
//   required DateTime date,
// }) async {
//   final db = await getDB();

//   final prefs = await SharedPreferences.getInstance();

//   String username =
//       prefs.getString('username') ?? '';

//   String finalType =
//       (type.toLowerCase() == "income")
//           ? "Income"
//           : "Expense";

//   await db.insert('transactions', {
//     'username': username,
//     'amount': amount,
//     'type': finalType,
//     'category': category,
//     'subcategory': subcategory,
//     'note': note,
//     'date': date.toIso8601String(),
//   });
// }

//   // =============================
//   // TRANSACTIONS
//   // =============================
//   static Future<void> insertTransaction(
//     double amount,
//     String type,
//     String category,
//     String subcategory,
//   ) async {
//     await _insert(
//       amount: amount,
//       type: type,
//       category: category,
//       subcategory: subcategory,
//       note: "Manual Entry",
//       date: DateTime.now(),
//     );
//   }

// static Future<List<Map<String, dynamic>>>getTransactions() async {
//   final db = await getDB();

//   final prefs =
//       await SharedPreferences.getInstance();

//   String username =
//       prefs.getString('username') ?? '';

//   return await db.query(
//     'transactions',
//     where: 'username = ?',
//     whereArgs: [username],
//     orderBy: 'id DESC',
//   );
// }

//   // =============================
//   // CATEGORY (FIXED)
//   // =============================
//   static Future<void> insertCategory(String name) async {
//     final db = await getDB();

//     final key = name.trim().toLowerCase();

//     final existing = await db.query(
//       'categories',
//       where: 'name = ?',
//       whereArgs: [key],
//     );

//     if (existing.isNotEmpty) return;

//     await db.insert('categories', {'name': key});
//   }

//   static Future<List<Map<String, dynamic>>> getCategories() async {
//     final db = await getDB();
//     return db.query('categories', orderBy: 'name ASC');
//   }

//   // =============================
//   // SUBCATEGORY (FIXED)
//   // =============================
//   static Future<void> insertSubCategory(
//       String category, String name) async {
//     final db = await getDB();

//     final catKey = category.trim().toLowerCase();
//     final subKey = name.trim().toLowerCase();

//     final existing = await db.query(
//       'subcategories',
//       where: 'category = ? AND name = ?',
//       whereArgs: [catKey, subKey],
//     );

//     if (existing.isNotEmpty) return;

//     await db.insert('subcategories', {
//       'category': catKey,
//       'name': subKey,
//     });
//   }

// static Future<Map<String, List<String>>> getSubCategories() async {
//   final db = await getDB();

//   final result = await db.query(
//     'subcategories',
//     orderBy: 'category ASC',
//   );

//   Map<String, List<String>> data = {};

//   for (var row in result) {
//     String category = row['category'].toString();
//     String name = row['name'].toString();

//     if (!data.containsKey(category)) {
//       data[category] = [];
//     }

//     data[category]!.add(name);
//   }

//   return data;
// }

//   // =============================
//   // DELETE TRANSACTION
//   // =============================
//   static Future<void> deleteTransaction(int id) async {
//     final db = await getDB();
//     await db.delete(
//       'transactions',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// //summary
// static Future<Map<String, double>> getSummary() async {
//   final db = await getDB();

//   final prefs = await SharedPreferences.getInstance();

//   String username =
//       prefs.getString('username') ?? '';

//   final result = await db.rawQuery('''
//     SELECT
//       SUM(CASE WHEN type = 'Income'
//           THEN amount ELSE 0 END) as income,
//       SUM(CASE WHEN type = 'Expense'
//           THEN amount ELSE 0 END) as expense
//     FROM transactions
//     WHERE username = ?
//   ''', [username]);

//   double income =
//       (result[0]['income'] as num?)
//               ?.toDouble() ??
//           0;

//   double expense =
//       (result[0]['expense'] as num?)
//               ?.toDouble() ??
//           0;

//   return {
//     "income": income,
//     "expense": expense,
//     "balance": income - expense,
//   };
// }

// //insert pdf transaction
// static Future<void> insertPDFTransaction({
//   required double amount,
//   required String type,
//   required String category,
//     required String subCategory,
//       required String language,
//   String note = "PDF Import",
//   DateTime? date,
// }) async {
//   final db = await getDB();

//   final prefs = await SharedPreferences.getInstance();

//   String username =
//       prefs.getString('username') ?? '';

//   String finalType =
//       (type.toLowerCase() == "income")
//           ? "Income"
//           : "Expense";

//   await db.insert('transactions', {
//   'username': username,
//   'amount': amount,
//   'type': finalType,
//   'category': category,
//   'subcategory': subCategory,
//   'language': language,
//   'note': note,
  
//   'date': (date ?? DateTime.now()).toIso8601String(),
// });
// }

//   // =============================
//   // DEBUG RESET
//   // =============================
//   static Future<void> clearDB() async {
//     final db = await getDB();
//     await db.delete('transactions');
//   }
//   // =============================
// // REGISTER USER
// // =============================
// static Future<bool> registerUser(
//   String username,
//   String password,
// ) async {
//   final db = await getDB();

//   final existing = await db.query(
//     'users',
//     where: 'username = ?',
//     whereArgs: [username],
//   );

//   if (existing.isNotEmpty) {
//     return false;
//   }

//   await db.insert(
//     'users',
//     {
//       'username': username,
//       'password': password,
//     },
//   );

//   return true;
// }

// // =============================
// // LOGIN USER
// // =============================
// static Future<int?> loginUser(
//   String username,
//   String password,
// ) async {
//   final db = await getDB();

//   final result = await db.query(
//     'users',
//     where: 'username = ? AND password = ?',
//     whereArgs: [username, password],
//   );

//   if (result.isEmpty) {
//     return null;
//   }

//   return result.first['id'] as int;
// }

// // =============================
// // GET USERS
// // =============================
// static Future<List<Map<String, dynamic>>> getUsers() async {
//   final db = await getDB();
//   return db.query('users');
// }
// } 

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static Database? _db;

  // =============================
  // DEFAULT DATA
  // =============================
  static const Map<String, List<String>> defaultSubCategories = {
    'food': ['breakfast', 'lunch', 'dinner', 'snacks'],
    'travel': ['bus', 'train', 'fuel', 'taxi'],
    'shopping': ['clothes', 'electronics', 'groceries', 'accessories'],
    'bills': ['electricity', 'internet', 'water', 'mobile_recharge'],
    'entertainment': ['movies', 'games', 'music', 'ott'],
    'health': ['medicine', 'doctor', 'gym', 'insurance'],
    'education': ['books', 'fees', 'courses', 'stationery'],
    'salary': ['monthly', 'bonus'],
  };

  static const List<String> defaultCategories = [
    'food',
    'travel',
    'shopping',
    'bills',
    'entertainment',
    'health',
    'education',
    'salary',
  ];

  // =============================
  // GET DATABASE
  // =============================
  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'wallet.db');

    _db = await openDatabase(
      path,
      version: 9,
      onCreate: (db, version) async {
        // USERS
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');

        // TRANSACTIONS
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            subcategory TEXT,
            language TEXT,
            note TEXT,
            date TEXT,
            attachment TEXT
          )
        ''');

        // CATEGORIES
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
          )
        ''');

        // SUBCATEGORIES
        await db.execute('''
          CREATE TABLE subcategories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            name TEXT,
            UNIQUE(category, name)
          )
        ''');

        // SEED DEFAULT DATA
        await _seedDefaults(db);
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
           if (oldVersion < 9) {
            await db.execute(
                'ALTER TABLE transactions ADD COLUMN attachment TEXT'
              );
              
            }
        }

        // Always ensure defaults exist after upgrade
        await _seedDefaults(db);
      },
    );

    return _db!;
  }

  // =============================
  // SEED DEFAULT CATEGORIES + SUBCATEGORIES
  // =============================
  static Future<void> _seedDefaults(Database db) async {
    for (var cat in defaultCategories) {
      await db.insert(
        'categories',
        {'name': cat},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    defaultSubCategories.forEach((category, subs) async {
      for (var sub in subs) {
        await db.insert(
          'subcategories',
          {
            'category': category,
            'name': sub,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  // =============================
  // TRANSACTIONS
  // =============================
  static Future<void> _insert({
    required double amount,
    required String type,
    required String category,
    String subcategory = "",
    required String note,
    required DateTime date,
    String? attachment,
  }) async {
    final db = await getDB();

    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    String finalType =
        (type.toLowerCase() == "income") ? "Income" : "Expense";

    await db.insert('transactions', {
      'username': username,
      'amount': amount,
      'type': finalType,
      'category': category,
      'subcategory': subcategory,
      'note': note,
      'date': date.toIso8601String(),
      'attachment': attachment,
    });
  }

  static Future<void> insertTransaction(
    double amount,
    String type,
    String category,
    String subcategory,
    String? attachment,
  ) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      subcategory: subcategory,
      note: "Manual Entry",
      date: DateTime.now(),
      attachment: attachment,
    );
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await getDB();

    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    return await db.query(
      'transactions',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
  }

  // =============================
  // CATEGORY
  // =============================
  static Future<void> insertCategory(String name) async {
    final db = await getDB();

    final key = name.trim().toLowerCase();

    await db.insert(
      'categories',
      {'name': key},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await getDB();
    return db.query('categories', orderBy: 'name ASC');
  }

  // =============================
  // SUBCATEGORY
  // =============================
  static Future<void> insertSubCategory(
      String category, String name) async {
    final db = await getDB();

    await db.insert(
      'subcategories',
      {
        'category': category.trim().toLowerCase(),
        'name': name.trim().toLowerCase(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<Map<String, List<String>>> getSubCategories() async {
    final db = await getDB();

    final result = await db.query(
      'subcategories',
      orderBy: 'category ASC',
    );

    Map<String, List<String>> data = {};

    for (var row in result) {
      String category = row['category'].toString();
      String name = row['name'].toString();

      data.putIfAbsent(category, () => []);
      data[category]!.add(name);
    }

    return data;
  }

  // =============================
  // SUMMARY
  // =============================
  static Future<Map<String, double>> getSummary() async {
    final db = await getDB();

    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN type = 'Income' THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = 'Expense' THEN amount ELSE 0 END) as expense
      FROM transactions
      WHERE username = ?
    ''', [username]);

    double income = (result[0]['income'] as num?)?.toDouble() ?? 0;
    double expense = (result[0]['expense'] as num?)?.toDouble() ?? 0;

    return {
      "income": income,
      "expense": expense,
      "balance": income - expense,
    };
  }

  // =============================
  // DELETE
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
  // PDF INSERT
  // =============================
  static Future<void> insertPDFTransaction({
    required double amount,
    required String type,
    required String category,
    required String subCategory,
    required String language,
    String note = "PDF Import",
    DateTime? date,
    String? attachment,
  }) async {
    final db = await getDB();

    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    String finalType =
        (type.toLowerCase() == "income") ? "Income" : "Expense";

    await db.insert('transactions', {
      'username': username,
      'amount': amount,
      'type': finalType,
      'category': category,
      'subcategory': subCategory,
      'language': language,
      'note': note,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'attachment': attachment,
    });
  }

  // =============================
  // CLEAR DB
  // =============================
  static Future<void> clearDB() async {
    final db = await getDB();
    await db.delete('transactions');
  }

  // =============================
  // USERS
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

    if (existing.isNotEmpty) return false;

    await db.insert('users', {
      'username': username,
      'password': password,
    });

    return true;
  }

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

    if (result.isEmpty) return null;

    return result.first['id'] as int;
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await getDB();
    return db.query('users');
  }
}