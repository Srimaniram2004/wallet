import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/db_helper.dart';
import 'app_localization.dart';

class ChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const ChartScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  //////////////////////////////////////////////////
  // STATE
  //////////////////////////////////////////////////

  List<Map<String, dynamic>> transactions = [];
  String currencySymbol = "₹";
String selectedProfile = "Personal";

  @override
  void initState() {
    super.initState();
    loadCurrency();
    loadSelectedProfile();
    transactions = widget.transactions;
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currencySymbol = prefs.getString('currency') ?? "₹";
    });
  }
Future<void> loadSelectedProfile() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    selectedProfile =
        prefs.getString('selectedProfile') ??
        'Personal';
  });
}

List<Map<String, dynamic>> get filteredTransactions {
  return transactions.where((tx) {
    return tx['account'] == selectedProfile;
  }).toList();
}
  
 
  //////////////////////////////////////////////////
  // SAFE DATE PARSE
  //////////////////////////////////////////////////

  DateTime parseDate(dynamic date) {
    try {
      return DateTime.parse(date.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  //////////////////////////////////////////////////
  // INCOME
  //////////////////////////////////////////////////

  double getIncome() {
    return filteredTransactions
        .where((t) => t['type'] == "Income")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  //////////////////////////////////////////////////
  // EXPENSE
  //////////////////////////////////////////////////

  double getExpense() {
    return filteredTransactions
        .where((t) => t['type'] == "Expense")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  //////////////////////////////////////////////////
  // CATEGORY DATA
  //////////////////////////////////////////////////

  Map<String, double> getCategoryData() {
    Map<String, double> data = {};

    for (var tx in filteredTransactions){
      if (tx['type'] == "Expense") {
        String category = tx['category'] ?? "Others";
        data[category] =
           (data[category] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

//sub category
 Map<String, double> getSubCategoryData() {
  Map<String, double> data = {};

  for (var tx in filteredTransactions) {
    if (tx['type'] == "Expense") {
      String category = tx['category'] ?? "Others";
      String subCategory = tx['subcategory'] ?? "General";

      String key = "$category → $subCategory";

      data[key] = (data[key] ?? 0) + (tx['amount'] ?? 0);
    }
  }

  return data;

}

  //////////////////////////////////////////////////
  // MONTHLY DATA
  //////////////////////////////////////////////////

  Map<String, double> getMonthlyExpense() {
    Map<String, double> data = {};

    for (var tx in filteredTransactions){
      if (tx['type'] == "Expense") {
        DateTime date = parseDate(tx['date']);
        String key = DateFormat('MMM').format(date);

        data[key] = (data[key] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

  //////////////////////////////////////////////////
  // DAILY DATA
  //////////////////////////////////////////////////

  Map<String, double> getDailyExpense() {
  Map<String, double> data = {};

  for (var tx in filteredTransactions) {
    if (tx['type'] == "Expense") {
      DateTime date = DateTime.parse(tx['date']);

      // Example: 20 Jun 2026
      String key = DateFormat('dd MMM yyyy').format(date);

      data[key] = (data[key] ?? 0) + (tx['amount'] ?? 0);
    }
  }

  return data;
}
  //////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA);

    final textColor = isDark ? Colors.white : Colors.black;

    final subText = isDark ? Colors.grey[400]! : Colors.grey;

    final income = getIncome();
    final expense = getExpense();

    final pieData = getCategoryData();
    final monthlyData = getMonthlyExpense();
    final dailyData = getDailyExpense();
   final subCategoryData = getSubCategoryData();

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: Text(t.translate("analytics")),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await loadCurrency();

              setState(() {
                transactions = widget.transactions;
              });
            },
          ),
        ],
      ),

      body: transactions.isEmpty
          ? Center(child: Text(t.translate("no_data")))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  //////////////////////////////////////////////////
                  // HEADER
                  //////////////////////////////////////////////////
                  const SizedBox(height: 20),

                         Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.teal,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selectedProfile == "Business"
                                      ? Icons.business
                                      : Icons.person,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Profile : $selectedProfile",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0F2027),
                          Color(0xFF2C5364),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate("financial_overview"),
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$currencySymbol ${(income - expense).toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  //////////////////////////////////////////////////
                  // SUMMARY LABELS
                  //////////////////////////////////////////////////

                  Row(
                    children: [
                      _summaryCard(
                        t.translate("income"),
                        income,
                        Colors.green,
                        Icons.arrow_downward,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        t.translate("expense"),
                        expense,
                        Colors.red,
                        Icons.arrow_upward,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _sectionTitle(
                      t.translate("category_expense"), textColor),

                  const SizedBox(height: 10),



                  _glassContainer(
  child: pieData.isEmpty
      ? Center(
          child: Text(
            t.translate("no_data"),
          ),
        )
      : Column(
          children: [

            Expanded(
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 45,
                  sections: List.generate(
                    pieData.length,
                    (i) {
                      final e =
                          pieData.entries.toList()[i];

                      double total =
                          pieData.values.fold(
                        0,
                        (a, b) => a + b,
                      );

                      return PieChartSectionData(
                        value: e.value,
                        title:
                            "${(e.value / total * 100).toStringAsFixed(1)}%",
                        color:
                            colors[i % colors.length],
                        radius: 90,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

                const SizedBox(height: 25),

              _sectionTitle(
                AppLocalizations.of(context).tr('category_expense'),
                textColor,
              ),

              const SizedBox(height: 10),

              
           Wrap(
              spacing: 10,
              runSpacing: 10,
              children: pieData.entries
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[entry.key % colors.length],
                    ),
                    const SizedBox(width: 5),
                    Text(
                     AppLocalizations.of(context).tr(entry.value.key),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          
          ],
        ),
        
),

const SizedBox(height: 25),
 //const SizedBox(height: 20),

_sectionTitle(
  AppLocalizations.of(context).tr('sub_category_expenses'),
  textColor,
),

const SizedBox(height: 10),

Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    children: subCategoryData.entries.map((entry) {
      final parts = entry.key.split("→");

      String category = parts[0].trim();
      String subCategory = parts.length > 1 ? parts[1].trim() : "";

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${AppLocalizations.of(context).tr(category)} → ${AppLocalizations.of(context).tr(subCategory)}",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
            Text(
              "$currencySymbol ${entry.value.toStringAsFixed(0)}",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  ),
),

                  _buildChart(
                    t.translate("daily_expense"),
                    dailyData,
                    textColor,
                    subText,
                  ),

                  const SizedBox(height: 25),

                  _buildChart(
                    t.translate("monthly_expense"),
                    monthlyData,
                    textColor,
                    subText,
                  ),
                ],
              ),
            ),
    );
  }

  //////////////////////////////////////////////////
  // SUMMARY CARD
  //////////////////////////////////////////////////

  Widget _summaryCard(
      String title, double amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text(
              "$currencySymbol ${amount.toStringAsFixed(0)}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // TITLE
  //////////////////////////////////////////////////

  Widget _sectionTitle(String text, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
      ),
      child: child,
    );
  }

  //////////////////////////////////////////////////
  // BAR CHART
  //////////////////////////////////////////////////

  Widget _buildChart(
    String title,
    Map<String, double> data,
    Color textColor,
    Color subText,
  ) {
    double maxY =
        data.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title, textColor),
        const SizedBox(height: 10),
          Container(
  height: 260,
  padding: const EdgeInsets.all(12),
  child: data.isEmpty
      ? Center(
          child: Text(
            "No data",
            style: TextStyle(color: subText),
          ),
        )
      : BarChart(
          BarChartData(
            maxY: maxY + (maxY * 0.2),

            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 70,
                ),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    final keys = data.keys.toList();

                    if (value.toInt() >= 0 &&
                        value.toInt() < keys.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          keys[value.toInt()],
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),

            barGroups: data.entries
                .toList()
                .asMap()
                .entries
                .map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.value,
                    width: 14,
                    color: Colors.teal,
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
),
      ],
    );
  }
}

