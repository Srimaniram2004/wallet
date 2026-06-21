import 'package:flutter/material.dart';

import 'app_localization.dart';
import 'language_screen.dart';
import 'currency_screen.dart';
import 'category_screen.dart';
import 'report_screen.dart';
import 'profile_management_screen.dart';
import 'package:flutter_switch/flutter_switch.dart';


class SettingsScreen extends StatelessWidget {
  final Function(Locale) onLanguageChanged;
  final bool isDark;
  final VoidCallback toggleTheme;

  final List<Map<String, dynamic>> transactions;
  final Map<String, List<String>> categories;

  final Future<void> Function(String) onAddCategory;
  final Future<void> Function(String, String) onAddSubCategory;

   final Future<void> Function(
    String oldName,
    String newName,
  ) onEditCategory;

  final Future<void> Function(
    String category,
  ) onDeleteCategory;

  final Future<void> Function(
    String category,
    String oldSub,
    String newSub,
  ) onEditSubCategory;

  final Future<void> Function(
    String category,
    String subCategory,
  ) onDeleteSubCategory;

  const SettingsScreen({
  super.key,
  required this.onLanguageChanged,
  required this.isDark,
  required this.toggleTheme,
  required this.transactions,
  required this.categories,
  required this.onAddCategory,
  required this.onAddSubCategory,
  required this.onEditCategory,
  required this.onDeleteCategory,
  required this.onEditSubCategory,
  required this.onDeleteSubCategory,
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
                      fromSettings: true,
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
                       onLocaleChange: onLanguageChanged,
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

                  onAddCategory: onAddCategory,

                  onAddSubCategory: onAddSubCategory,

                  onEditCategory: onEditCategory,

                  onDeleteCategory: onDeleteCategory,

                  onEditSubCategory: onEditSubCategory,

                  onDeleteSubCategory: onDeleteSubCategory,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      const SizedBox(width: 12),
                      Text(tr.tr('dark_mode')),
                    ],
                  ),
                 FlutterSwitch(
                    width: 75,
                    height: 35,
                    value: isDark,
                    showOnOff: true,
                    activeText: "ON",
                    inactiveText: "OFF",
                    onToggle: (val) {
                      toggleTheme();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}