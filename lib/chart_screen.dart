import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ChartScreen({super.key, required this.transactions});

  // ================= INCOME =================
  double getIncome() {
    return transactions
        .where((t) => t['type'] == "Income")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  // ================= EXPENSE =================
  double getExpense() {
    return transactions
        .where((t) => t['type'] == "Expense")
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0));
  }

  // ================= CATEGORY =================
  Map<String, double> getCategoryData() {
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx['type'] == "Expense") {
        data[tx['category']] =
            (data[tx['category']] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

  // ================= MONTHLY =================
  Map<String, double> getMonthlyExpense() {
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx['type'] == "Expense") {
        DateTime date = DateTime.parse(tx['date']);
        String key = DateFormat('dd-MM').format(date);

        data[key] = (data[key] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

  // ================= YEARLY =================
  Map<String, double> getYearlyExpense() {
    Map<String, double> data = {};

    for (var tx in transactions) {
      if (tx['type'] == "Expense") {
        DateTime date = DateTime.parse(tx['date']);
        String key = DateFormat('MMM').format(date);

        data[key] = (data[key] ?? 0) + (tx['amount'] ?? 0);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subText = isDark ? Colors.grey[400]! : Colors.grey;

    final income = getIncome();
    final expense = getExpense();

    final pieData = getCategoryData();
    final monthlyData = getMonthlyExpense();
    final yearlyData = getYearlyExpense();

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
        title: const Text("Analytics Dashboard"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= SUMMARY =================
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: cardColor,
                    child: ListTile(
                      leading: const Icon(Icons.arrow_downward,
                          color: Colors.green),
                      title: Text("Income",
                          style: TextStyle(color: textColor)),
                      subtitle: Text("₹ ${income.toStringAsFixed(0)}",
                          style: TextStyle(color: subText)),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: cardColor,
                    child: ListTile(
                      leading: const Icon(Icons.arrow_upward,
                          color: Colors.red),
                      title: Text("Expense",
                          style: TextStyle(color: textColor)),
                      subtitle: Text("₹ ${expense.toStringAsFixed(0)}",
                          style: TextStyle(color: subText)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= PIE CHART =================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Category Wise Expense",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              height: 250,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: pieData.isEmpty
                  ? Center(child: Text("No data", style: TextStyle(color: subText)))
                  : PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sections: List.generate(pieData.length, (i) {
                          final e = pieData.entries.toList()[i];

                          return PieChartSectionData(
                            value: e.value,
                            title: e.key,
                            color: colors[i % colors.length],
                            radius: 80,
                            titleStyle: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          );
                        }),
                      ),
                    ),
            ),

            const SizedBox(height: 30),

            _buildChart("Monthly Expense (Day Wise)", monthlyData,
                textColor, subText, cardColor),

            const SizedBox(height: 30),

            _buildChart("Yearly Expense (Month Wise)", yearlyData,
                textColor, subText, cardColor),
          ],
        ),
      ),
    );
  }

  // ================= FIXED CHART =================
  Widget _buildChart(
    String title,
    Map<String, double> data,
    Color textColor,
    Color subText,
    Color cardColor,
  ) {
    double maxY =
        data.values.isEmpty ? 0 : data.values.reduce((a, b) => a > b ? a : b);

    double interval = maxY / 5;
    if (interval <= 0 || interval.isNaN) interval = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor),
        ),
        const SizedBox(height: 15),

        Container(
          height: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: data.isEmpty
              ? Center(child: Text("No data", style: TextStyle(color: subText)))
              : BarChart(
                  BarChartData(
                    maxY: maxY + (maxY * 0.2),
                    borderData: FlBorderData(show: false),

                    titlesData: FlTitlesData(
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 55,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: subText,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final keys = data.keys.toList();

                            if (v.toInt() < keys.length) {
                              return Text(
                                keys[v.toInt()],
                                style: TextStyle(
                                    color: subText, fontSize: 10),
                              );
                            }
                            return const Text("");
                          },
                        ),
                      ),
                    ),

                    barGroups: data.entries.toList().asMap().entries.map((e) {
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value.value,
                            width: 14,
                            color: Colors.teal,
                          )
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