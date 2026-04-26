import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_screen.dart';
import 'chart_screen.dart';
import 'category_screen.dart';
import 'report_screen.dart';

void main() {
  runApp(const WalletApp());
}

class WalletApp extends StatefulWidget {
  const WalletApp({super.key});

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),

      home: MainScreen(
        isDark: isDark,
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  List<Map<String, dynamic>> transactions = [];
  List<String> categories = [];

  double income = 0;
  double expense = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final tx = await DBHelper.getTransactions();
    final cat = await DBHelper.getCategories();

    double inc = 0;
    double exp = 0;

    for (var t in tx) {
      if (t['type'] == "Income") {
        inc += (t['amount'] ?? 0);
      } else {
        exp += (t['amount'] ?? 0);
      }
    }

    setState(() {
      transactions = tx;
      categories = cat.map((e) => e['name'].toString()).toList();
      income = inc;
      expense = exp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = income - expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      HomeDashboard(
        income: income,
        expense: expense,
        balance: balance,
        transactions: transactions,
        onDelete: (id) async {
          await DBHelper.deleteTransaction(id);
          loadData();
        },
      ),
      ChartScreen(transactions: transactions),
      CategoryScreen(
        categories: categories,
        onAdd: (name) async {
          await DBHelper.insertCategory(name);
          loadData();
        },
      ),
      ReportScreen(data: transactions),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet App"),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),

      body: pages[index],

      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal,
              icon: const Icon(Icons.add),
              label: const Text("Add"),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddScreen(categories: categories),
                  ),
                );

                if (res != null) {
                  await DBHelper.insertTransaction(
                    res['amount'],
                    res['type'],
                    res['category'],
                  );
                  loadData();
                }
              },
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: "Stats"),
          NavigationDestination(icon: Icon(Icons.category), label: "Category"),
          NavigationDestination(icon: Icon(Icons.file_copy), label: "Report"),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ⭐ HOME DASHBOARD (DARK SAFE + PREMIUM FIXED)
//////////////////////////////////////////////////////////////

class HomeDashboard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final List<Map<String, dynamic>> transactions;
  final Function(int) onDelete;

  const HomeDashboard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "My Wallet",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "₹ ${balance.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _buildCard("Income", income, Colors.green, cardColor),
                const SizedBox(width: 10),
                _buildCard("Expense", expense, Colors.red, cardColor),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, i) {
                  final tx = transactions[i];

                  return Card(
                    color: cardColor,
                    child: ListTile(
                      title: Text("${tx['category']} - ₹${tx['amount']}"),
                      subtitle: Text(tx['type']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(tx['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, double value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color)),
            const SizedBox(height: 5),
            Text(
              "₹ ${value.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}