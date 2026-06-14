
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
      version: 11,
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
                account TEXT,
                project TEXT,
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

        //projects

        await db.execute('''
            CREATE TABLE projects(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              name TEXT
            )
          ''');


        // CATEGORIES
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT,
            name TEXT UNIQUE
          )
        ''');

        // SUBCATEGORIES
        await db.execute('''
          CREATE TABLE subcategories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            account TEXT,
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
              if (oldVersion < 10) {
                await db.execute(
                  'ALTER TABLE transactions ADD COLUMN account TEXT'
                );
          
              
            }
            if (oldVersion < 11) {
            await db.execute(
              'ALTER TABLE transactions ADD COLUMN project TEXT'
            );

            await db.execute('''
              CREATE TABLE IF NOT EXISTS projects(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                name TEXT
              )
            ''');
}
        }

        // Always ensure defaults exist after upgrade
        await _seedDefaults(db);
      },
    );

    return _db!;
  }


static Future<void> createProject(
  String projectName,
) async {
  final db = await getDB();

  final prefs =
      await SharedPreferences.getInstance();

  String username =
      prefs.getString('username') ?? '';

  await db.insert(
    'projects',
    {
      'username': username,
      'name': projectName,
    },
  );
}


static Future<List<Map<String, dynamic>>>
getProjects() async {
  final db = await getDB();

  final prefs =
      await SharedPreferences.getInstance();

  String username =
      prefs.getString('username') ?? '';

  return await db.query(
    'projects',
    where: 'username = ?',
    whereArgs: [username],
    orderBy: 'name ASC',
  );
}


static Future<void> deleteProject(
  int id,
) async {
  final db = await getDB();

  await db.delete(
    'projects',
    where: 'id = ?',
    whereArgs: [id],
  );
}
  // =============================
  // SEED DEFAULT CATEGORIES + SUBCATEGORIES
  // =============================
  static Future<void> _seedDefaults(Database db) async {

  // PERSONAL DEFAULT CATEGORIES

  for (var cat in defaultCategories) {
    await db.insert(
      'categories',
      {
        'account': 'Personal',
        'name': cat,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // PERSONAL DEFAULT SUBCATEGORIES

  for (var entry in defaultSubCategories.entries) {
    for (var sub in entry.value) {
      await db.insert(
        'subcategories',
        {
          'account': 'Personal',
          'category': entry.key,
          'name': sub,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}

  // =============================
  // TRANSACTIONS
  // =============================
  static Future<void> _insert({
    required double amount,
    required String type,
    required String category,
    required String account,
    required String project,
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
      'account' :account,
      'project': project,
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
     String account,
      String project,
  ) async {
    await _insert(
      amount: amount,
      type: type,
      category: category,
      subcategory: subcategory,
       account: account,
      note: "Manual Entry",
      date: DateTime.now(),
      attachment: attachment,
      project:project,
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
  static Future<List<Map<String, dynamic>>>
getTransactionsByAccount(
  String account,
) async {
  final db = await getDB();

  final prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('username') ?? '';

  return await db.query(
    'transactions',
    where: 'username = ? AND account = ?',
    whereArgs: [username, account],
    orderBy: 'id DESC',
  );
}

  // =============================
  // CATEGORY
  // =============================
static Future<void> insertCategory(
  String account,
  String name,
) async {
  final db = await getDB();

  await db.insert(
    'categories',
    {
      'account': account,
      'name': name.trim().toLowerCase(),
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

 static Future<List<Map<String, dynamic>>>
getCategories(
  String account,
) async {
  final db = await getDB();

  return await db.query(
    'categories',
    where: 'account = ?',
    whereArgs: [account],
    orderBy: 'name ASC',
  );
}
  // =============================
  // SUBCATEGORY
  // =============================
static Future<void> insertSubCategory(
  String account,
  String category,
  String name,
) async {
  final db = await getDB();

  await db.insert(
    'subcategories',
    {
      'account': account,
      'category': category,
      'name': name,
    },
  );
}

  static Future<Map<String, List<String>>>
getSubCategories(
  String account,
) async {
  final db = await getDB();

  final result = await db.query(
    'subcategories',
    where: 'account = ?',
    whereArgs: [account],
  );

  Map<String, List<String>> data = {};

  for (var row in result) {
    String category =
        row['category'].toString();

    String name =
        row['name'].toString();

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