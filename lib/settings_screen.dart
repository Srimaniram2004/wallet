import 'package:flutter/material.dart';

import 'app_localization.dart';
import 'language_screen.dart';
import 'currency_screen.dart';
import 'category_screen.dart';
import 'report_screen.dart';
import 'profile_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final bool isDark;
  final VoidCallback toggleTheme;

  final List<Map<String, dynamic>> transactions;
  final Map<String, List<String>> categories;

  final Future<void> Function(String) onAddCategory;
  final Future<void> Function(String, String) onAddSubCategory;
Future<void> addCategory(String category) async {
  }

  Future<void> addSubCategory(
    String category,
    String subCategory,
  ) async {
  }

  Future<void> editCategory(
    String oldName,
    String newName,
  ) async {
  }

  Future<void> deleteCategory(
    String category,
  ) async {
  }

  Future<void> editSubCategory(
    String category,
    String oldSub,
    String newSub,
  ) async {
  }

  Future<void> deleteSubCategory(
    String category,
    String subCategory,
  ) async {
  }

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
    final tr = AppLocalizations.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 10),

          Text(
            tr.tr('settings'),
            style: const TextStyle(
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
              leading:  Icon(Icons.language),
              title: Text(tr.tr('language')),
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
              title: Text(tr.tr('currency')),
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
          // MANAGE PROFILES
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.switch_account),
              title: Text(tr.tr('manage_profiles')),
              subtitle: Text(
                tr.tr('manage_profiles_desc'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ProfileManagementScreen(),
                  ),
                );
              },
            ),
          ),

          //////////////////////////////////////////////////
          // REPORTS
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(tr.tr('reports')),
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
          // CATEGORIES
          //////////////////////////////////////////////////

          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: Text(tr.tr('categories')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>CategoryScreen(
                      categories: categories,

                      onAddCategory: addCategory,

                      onAddSubCategory: addSubCategory,

                      onEditCategory: editCategory,

                      onDeleteCategory: deleteCategory,

                      onEditSubCategory: editSubCategory,

                      onDeleteSubCategory: deleteSubCategory,
                    )
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          //////////////////////////////////////////////////
          // DARK MODE
          //////////////////////////////////////////////////

          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: Text(tr.tr('dark_mode')),
              value: isDark,
              onChanged: (_) {
                toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}