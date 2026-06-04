/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/db_helper.dart';

class ChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const ChartScreen({
    super.key,
    required this.transactions,
  });

  @override
  State<ChartScreen> createState() =>
      _ChartScreenState();
}

class _ChartScreenState
    extends State<ChartScreen> {

  //////////////////////////////////////////////////
  // TRANSACTIONS
  //////////////////////////////////////////////////

  List<Map<String, dynamic>> transactions =
      [];

  //////////////////////////////////////////////////
  // CURRENCY SYMBOL
  //////////////////////////////////////////////////

  String currencySymbol = "₹";

  @override
  void initState() {
    super.initState();

    loadCurrency();
    loadData();
  }

  //////////////////////////////////////////////////
  // LOAD CURRENCY
  //////////////////////////////////////////////////

  Future<void> loadCurrency() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {

      currencySymbol =
          prefs.getString('currency') ?? "₹";
    });
  }

  //////////////////////////////////////////////////
  // LOAD DATA
  //////////////////////////////////////////////////

  Future<void> loadData() async {

    final data =
        await DBHelper.getTransactions();

    setState(() {

      transactions = data;
    });
  }

  //////////////////////////////////////////////////
  // SAFE DATE PARSE
  //////////////////////////////////////////////////

  DateTime parseDate(dynamic date) {

    try {

      return DateTime.parse(
        date.toString(),
      );

    } catch (_) {

      return DateTime.now();
    }
  }

  //////////////////////////////////////////////////
  // TOTAL INCOME
  //////////////////////////////////////////////////

  double getIncome() {

    return transactions
        .where(
          (t) => t['type'] == "Income",
        )
        .fold(
          0.0,
          (sum, t) =>
              sum + (t['amount'] ?? 0),
        );
  }

  //////////////////////////////////////////////////
  // TOTAL EXPENSE
  //////////////////////////////////////////////////

  double getExpense() {

    return transactions
        .where(
          (t) => t['type'] == "Expense",
        )
        .fold(
          0.0,
          (sum, t) =>
              sum + (t['amount'] ?? 0),
        );
  }

  //////////////////////////////////////////////////
  // CATEGORY DATA
  //////////////////////////////////////////////////

  Map<String, double>
      getCategoryData() {

    Map<String, double> data = {};

    for (var tx in transactions) {

      if (tx['type'] == "Expense") {

        String category =
            tx['category'] ??
                "Others";

        data[category] =
            (data[category] ?? 0) +
                (tx['amount'] ?? 0);
      }
    }

    return data;
  }

  //////////////////////////////////////////////////
  // MONTHLY EXPENSE
  //////////////////////////////////////////////////

  Map<String, double>
      getMonthlyExpense() {

    Map<String, double> data = {};

    for (var tx in transactions) {

      if (tx['type'] == "Expense") {

        DateTime date =
            parseDate(tx['date']);

        String key =
            DateFormat('MMM')
                .format(date);

        data[key] =
            (data[key] ?? 0) +
                (tx['amount'] ?? 0);
      }
    }

    return data;
  }

  //////////////////////////////////////////////////
  // DAILY EXPENSE
  //////////////////////////////////////////////////

  Map<String, double>
      getDailyExpense() {

    Map<String, double> data = {};

    for (var tx in transactions) {

      if (tx['type'] == "Expense") {

        DateTime date =
            parseDate(tx['date']);

        String key =
            DateFormat('dd MMM')
                .format(date);

        data[key] =
            (data[key] ?? 0) +
                (tx['amount'] ?? 0);
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context)
                .brightness ==
            Brightness.dark;

    final bgColor = isDark

        ? const Color(0xFF121212)

        : const Color(0xFFF5F6FA);

    final textColor = isDark

        ? Colors.white

        : Colors.black;

    final subText = isDark

        ? Colors.grey[400]!

        : Colors.grey;

    final income =
        getIncome();

    final expense =
        getExpense();

    final pieData =
        getCategoryData();

    final monthlyData =
        getMonthlyExpense();

    final dailyData =
        getDailyExpense();

    final colors = [

      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(

      backgroundColor:
          bgColor,

      //////////////////////////////////////////////////
      // APP BAR
      //////////////////////////////////////////////////

      appBar: AppBar(

        title:
            const Text("Analytics"),

        centerTitle: true,

        actions: [

          IconButton(

            icon:
                const Icon(Icons.refresh),

            onPressed: () async {

              await loadCurrency();

              await loadData();
            },
          ),
        ],
      ),

      //////////////////////////////////////////////////
      // BODY
      //////////////////////////////////////////////////

      body: transactions.isEmpty

          ? const Center(
              child: Text(
                "No data available",
              ),
            )

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Column(
                children: [

                  //////////////////////////////////////////////////
                  // HEADER
                  //////////////////////////////////////////////////

                  Container(

                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                            20),

                    decoration:
                        BoxDecoration(

                      gradient:
                          const LinearGradient(
                        colors: [

                          Color(0xFF0F2027),
                          Color(0xFF2C5364),
                        ],
                      ),

                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        const Text(

                          "Financial Overview",

                          style: TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        Text(

                          "$currencySymbol ${(income - expense).toStringAsFixed(0)}",

                          style:
                              const TextStyle(

                            fontSize: 28,

                            fontWeight:
                                FontWeight.bold,

                            color:
                                Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  //////////////////////////////////////////////////
                  // SUMMARY
                  //////////////////////////////////////////////////

                  Row(
                    children: [

                      _summaryCard(

                        "Income",

                        income,

                        Colors.green,

                        Icons.arrow_downward,
                      ),

                      const SizedBox(
                          width: 10),

                      _summaryCard(

                        "Expense",

                        expense,

                        Colors.red,

                        Icons.arrow_upward,
                      ),
                    ],
                  ),

                  const SizedBox(
                      height: 25),

                  //////////////////////////////////////////////////
                  // PIE TITLE
                  //////////////////////////////////////////////////

                  _sectionTitle(
                    "Category Expense",
                    textColor,
                  ),

                  const SizedBox(
                      height: 10),

                  //////////////////////////////////////////////////
                  // PIE CHART
                  //////////////////////////////////////////////////

                  _glassContainer(

                    child: pieData.isEmpty

                        ? Center(
                            child: Text(
                              "No data",
                              style: TextStyle(
                                color: subText,
                              ),
                            ),
                          )

                        : Column(
                            children: [

                              Expanded(
                                child: PieChart(

                                  PieChartData(

                                    centerSpaceRadius:
                                        45,

                                    sections:
                                        List.generate(

                                      pieData.length,

                                      (i) {

                                        final e =
                                            pieData
                                                .entries
                                                .toList()[i];

                                        double total =
                                            pieData
                                                .values
                                                .fold(
                                                  0,
                                                  (a, b) =>
                                                      a + b,
                                                );

                                        return PieChartSectionData(

                                          value:
                                              e.value,

                                          title:
                                              "${(e.value / total * 100).toStringAsFixed(1)}%",

                                          color:
                                              colors[
                                                  i %
                                                      colors.length],

                                          radius:
                                              90,

                                          titleStyle:
                                              const TextStyle(

                                            color:
                                                Colors.white,

                                            fontSize:
                                                12,

                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  height: 10),

                              //////////////////////////////////////////////////
                              // LEGEND
                              //////////////////////////////////////////////////

                              Wrap(

                                spacing: 12,

                                children:
                                    pieData.entries
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((e) {

                                  return Row(

                                    mainAxisSize:
                                        MainAxisSize
                                            .min,

                                    children: [

                                      Container(

                                        width: 10,

                                        height: 10,

                                        color:
                                            colors[
                                                e.key %
                                                    colors.length],
                                      ),

                                      const SizedBox(
                                          width: 5),

                                      Text(

                                        e.value.key,

                                        style:
                                            TextStyle(
                                          color:
                                              textColor,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(
                      height: 25),

                  //////////////////////////////////////////////////
                  // DAILY CHART
                  //////////////////////////////////////////////////

                  _buildChart(

                    "Daily Expense",

                    dailyData,

                    textColor,

                    subText,
                  ),

                  const SizedBox(
                      height: 25),

                  //////////////////////////////////////////////////
                  // MONTHLY CHART
                  //////////////////////////////////////////////////

                  _buildChart(

                    "Monthly Expense",

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

    String title,

    double amount,

    Color color,

    IconData icon,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(16),

        decoration:
            BoxDecoration(

          gradient:
              LinearGradient(
            colors: [

              color.withOpacity(0.8),

              color.withOpacity(0.5),
            ],
          ),

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Column(
          children: [

            Icon(
              icon,
              color: Colors.white,
            ),

            const SizedBox(height: 6),

            Text(

              title,

              style: const TextStyle(
                color: Colors.white70,
              ),
            ),

            Text(

              "$currencySymbol ${amount.toStringAsFixed(0)}",

              style: const TextStyle(

                color: Colors.white,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // SECTION TITLE
  //////////////////////////////////////////////////

  Widget _sectionTitle(
    String text,
    Color color,
  ) {

    return Align(

      alignment:
          Alignment.centerLeft,

      child: Text(

        text,

        style: TextStyle(

          fontSize: 18,

          fontWeight:
              FontWeight.bold,

          color: color,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // GLASS CONTAINER
  //////////////////////////////////////////////////

  Widget _glassContainer({
    required Widget child,
  }) {

    return Container(

      height: 300,

      padding:
          const EdgeInsets.all(12),

      decoration:
          BoxDecoration(

        borderRadius:
            BorderRadius.circular(20),

        color: Colors.white
            .withOpacity(0.05),
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

    double maxY = data.values.isEmpty

        ? 0

        : data.values.reduce(
            (a, b) =>
                a > b ? a : b,
          );

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        _sectionTitle(
          title,
          textColor,
        ),

        const SizedBox(height: 10),

        Container(

          height: 260,

          padding:
              const EdgeInsets.all(12),

          decoration:
              BoxDecoration(

            borderRadius:
                BorderRadius.circular(
                    20),

            color: Colors.white
                .withOpacity(0.05),
          ),

          child: data.isEmpty

              ? Center(
                  child: Text(
                    "No data",
                    style: TextStyle(
                      color: subText,
                    ),
                  ),
                )

              : BarChart(

                  BarChartData(

                    maxY:
                        maxY + (maxY * 0.2),

                    titlesData:
                        FlTitlesData(

                      leftTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          interval:
                              maxY / 5 == 0
                                  ? 1
                                  : maxY / 5,

                          getTitlesWidget:
                              (value, _) {

                            return Text(

                              "$currencySymbol${value.toInt()}",

                              style: TextStyle(
                                color:
                                    subText,
                                fontSize:
                                    10,
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles:
                          AxisTitles(

                        sideTitles:
                            SideTitles(

                          showTitles:
                              true,

                          getTitlesWidget:
                              (v, _) {

                            final keys =
                                data.keys
                                    .toList();

                            if (v.toInt() <
                                keys.length) {

                              return Text(

                                keys[v.toInt()],

                                style:
                                    TextStyle(
                                  color:
                                      subText,
                                  fontSize:
                                      10,
                                ),
                              );
                            }

                            return const Text(
                                "");
                          },
                        ),
                      ),

                      rightTitles:
                          const AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
                        ),
                      ),

                      topTitles:
                          const AxisTitles(
                        sideTitles:
                            SideTitles(
                          showTitles:
                              false,
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

                            toY:
                                e.value.value,

                            width: 14,

                            borderRadius:
                                BorderRadius
                                    .circular(
                                        6),

                            color:
                                Colors.teal,
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
}*/

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

  @override
  void initState() {
    super.initState();
    loadCurrency();
    loadData();
  }

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currencySymbol = prefs.getString('currency') ?? "₹";
    });
  }

  Future<void> loadData() async {
    final data = await DBHelper.getTransactions();
    setState(() {
      transactions = data;
    });
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
    return transactions
        .where((t) => t['type'] == "Income")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  //////////////////////////////////////////////////
  // EXPENSE
  //////////////////////////////////////////////////

  double getExpense() {
    return transactions
        .where((t) => t['type'] == "Expense")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  //////////////////////////////////////////////////
  // CATEGORY DATA
  //////////////////////////////////////////////////

  Map<String, double> getCategoryData() {
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx['type'] == "Expense") {
        String category = tx['category'] ?? "Others";
        data[category] =
            (data[category] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

  //////////////////////////////////////////////////
  // MONTHLY DATA
  //////////////////////////////////////////////////

  Map<String, double> getMonthlyExpense() {
    Map<String, double> data = {};

    for (var tx in transactions) {
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

    for (var tx in transactions) {
      if (tx['type'] == "Expense") {
        DateTime date = parseDate(tx['date']);
        String key = DateFormat('dd MMM').format(date);

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
              await loadData();
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
                        ? Center(child: Text(t.translate("no_data")))
                        : PieChart(
                            PieChartData(
                              centerSpaceRadius: 45,
                              sections: List.generate(
                                pieData.length,
                                (i) {
                                  final e = pieData.entries.toList()[i];
                                  double total = pieData.values
                                      .fold(0, (a, b) => a + b);

                                  return PieChartSectionData(
                                    value: e.value,
                                    title:
                                        "${(e.value / total * 100).toStringAsFixed(1)}%",
                                    color: colors[i % colors.length],
                                    radius: 90,
                                  );
                                },
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 25),

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
      height: 300,
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
              ? Center(child: Text("No data", style: TextStyle(color: subText)))
              : BarChart(
                  BarChartData(
                    maxY: maxY + (maxY * 0.2),
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