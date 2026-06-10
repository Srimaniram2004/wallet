import 'package:flutter/material.dart';
import 'language_screen.dart';
import 'currency_screen.dart';
import 'chart_screen.dart';
import 'category_screen.dart';
import 'report_screen.dart';


class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final bool isDark;
  final VoidCallback toggleTheme;

  final List<Map<String, dynamic>> transactions;
  final Map<String, List<String>> categories;

  final Future<void> Function(String) onAddCategory;
  final Future<void> Function(String, String) onAddSubCategory;

  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.isDark,
    required this.toggleTheme,
    required this.transactions,
    required this.categories,
    required this.onAddCategory,
    required this.onAddSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 10),

          const Text(
            "Settings",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          //////////////////////////////////////////////////
          // LANGUAGE
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageScreen(
                      onLanguageChanged: onLanguageChanged,
                      isDark: isDark,
                      toggleTheme: toggleTheme,
                    ),
                  ),
                );
              },
            ),
          ),

          //////////////////////////////////////////////////
          // CURRENCY
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text("Currency"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrencyScreen(
                      isDark: isDark,
                      toggleTheme: toggleTheme,
                    ),
                  ),
                );
              },
            ),
          ),

          //////////////////////////////////////////////////
          // REPORT SCREEN
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Reports"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                   builder: (_) => ReportScreen(
                    data: transactions,
                    onRefresh: () async {},
                    ),
                  ),
                );
              },
            ),
          ),

          //////////////////////////////////////////////////
          // CATEGORY SCREEN
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text("Categories"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      categories: categories,
                      onAddCategory: onAddCategory,
                      onAddSubCategory: onAddSubCategory,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}