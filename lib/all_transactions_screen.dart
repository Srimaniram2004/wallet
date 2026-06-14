import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attachment_viewer_screen.dart';


class AllTransactionsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
final Function(int) onDelete;

  const AllTransactionsScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  State<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState
    extends State<AllTransactionsScreen> {
  late List<Map<String, dynamic>> transactions;

  @override
  void initState() {
    super.initState();
    transactions = List.from(widget.transactions);
  }

  double getIncome() {
    return transactions
        .where((t) => t['type'] == "Income")
        .fold(
          0.0,
          (sum, t) =>
              sum + ((t['amount'] ?? 0) as num).toDouble(),
        );
  }

  double getExpense() {
    return transactions
        .where((t) => t['type'] == "Expense")
        .fold(
          0.0,
          (sum, t) =>
              sum + ((t['amount'] ?? 0) as num).toDouble(),
        );
  }
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final income = getIncome();
    final expense = getExpense();
    final balance = income - expense;

    final dateFormat = DateFormat('dd MMM yyyy');

    // ================= SORT TRANSACTIONS =================
    List<Map<String, dynamic>> sortedTransactions =
        List.from(transactions);

    sortedTransactions.sort((a, b) {
      DateTime aDate =
          DateTime.tryParse(a['date'].toString()) ??
              DateTime.now();

      DateTime bDate =
          DateTime.tryParse(b['date'].toString()) ??
              DateTime.now();

      return bDate.compareTo(aDate);
    });

    return Scaffold(
      backgroundColor:
          isDark
              ? const Color(0xFF121212)
              : const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("All Transactions"),
        centerTitle: true,
      ),

      body: sortedTransactions.isEmpty
          ? Center(
              child: Text(
                "No transactions available",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
              ),
            )
          : Column(
              children: [

                //////////////////////////////////////////////////////
                // HEADER CARD
                //////////////////////////////////////////////////////

                Container(
                  width: double.infinity,

                  margin: const EdgeInsets.all(16),

                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F2027),
                        Color(0xFF2C5364),
                      ],
                    ),

                    borderRadius:
                        BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.3),

                        blurRadius: 10,
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Total Balance",

                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "₹ ${balance.toStringAsFixed(0)}",

                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [

                          _miniCard(
                            "Income",
                            income,
                            Colors.green,
                          ),

                          const SizedBox(width: 10),

                          _miniCard(
                            "Expense",
                            expense,
                            Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //////////////////////////////////////////////////////
                // TRANSACTION LIST
                //////////////////////////////////////////////////////

                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    itemCount:
                        sortedTransactions.length,

                    itemBuilder: (_, i) {

                      final tx =
                          sortedTransactions[i];

                      final isIncome =
                          tx['type'] == "Income";

                      return Container(

                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        padding:
                            const EdgeInsets.all(14),

                        decoration: BoxDecoration(

                          color: isDark
                              ? const Color(
                                  0xFF1E1E1E)
                              : Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                  18),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),

                              blurRadius: 6,

                              offset:
                                  const Offset(0, 4),
                            )
                          ],
                        ),

                        child: Row(
                          children: [

                            //////////////////////////////////////////////////
                            // ICON
                            //////////////////////////////////////////////////

                            CircleAvatar(

                              radius: 22,

                              backgroundColor:
                                  isIncome
                                      ? Colors.green
                                          .withOpacity(
                                              0.2)
                                      : Colors.red
                                          .withOpacity(
                                              0.2),

                              child: Icon(

                                isIncome
                                    ? Icons
                                        .arrow_downward
                                    : Icons
                                        .arrow_upward,

                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),

                            const SizedBox(width: 12),

                            //////////////////////////////////////////////////
                            // DETAILS
                            //////////////////////////////////////////////////

                            Expanded(
                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Text(

                                    (tx['subcategory'] !=
                                                    null &&
                                                tx['subcategory'] !=
                                                    "")
                                            ? tx[
                                                'subcategory']
                                            : tx[
                                                'category'] ??
                                                "Unknown",

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(

                                    tx['category'] ??
                                        "",

                                    style: TextStyle(
                                      fontSize: 12,

                                      color: Colors
                                          .grey[600],
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  //////////////////////////////////////////////////
                                  // TYPE BADGE
                                  //////////////////////////////////////////////////

                                  Container(

                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),

                                    decoration:
                                        BoxDecoration(

                                      color: isIncome
                                          ? Colors
                                              .green
                                              .withOpacity(
                                                  0.15)
                                          : Colors
                                              .red
                                              .withOpacity(
                                                  0.15),

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),
                                    ),

                                    child: Text(

                                      isIncome
                                          ? "Income"
                                          : "Expense",

                                      style:
                                          TextStyle(

                                        color:
                                            isIncome
                                                ? Colors
                                                    .green
                                                : Colors
                                                    .red,

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 6),

                                  //////////////////////////////////////////////////
                                  // DATE
                                  //////////////////////////////////////////////////

                                  Text(
                                      tx['date'] != null
                                          ? dateFormat.format(
                                              DateTime.parse(
                                                tx['date'].toString(),
                                              ),
                                            )
                                          : "",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),

                                    if (tx['attachment'] != null &&
                                        tx['attachment'].toString().isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AttachmentViewerScreen(
                                                filePath: tx['attachment'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.attach_file,
                                                size: 14,
                                                color: Colors.blue,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "View Attachment",
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            
                            //////////////////////////////////////////////////
                            // AMOUNT
                            //////////////////////////////////////////////////

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .end,

                              children: [

                                Container(

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color: isIncome
                                        ? Colors.green
                                            .withOpacity(
                                                0.15)
                                        : Colors.red
                                            .withOpacity(
                                                0.15),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                12),
                                  ),

                                  child: Text(

                                    "${isIncome ? "+" : "-"} ₹${tx['amount']}",

                                    style: TextStyle(

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      color: isIncome
                                          ? Colors
                                              .green
                                          : Colors
                                              .red,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

                                //////////////////////////////////////////////////
                                // DELETE
                                //////////////////////////////////////////////////

                                IconButton(

                                  icon: const Icon(
                                    Icons
                                        .delete_outline,
                                  ),

                                  color: Colors.grey,

                                  onPressed: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Transaction'),
                                      content: const Text(
                                        'Are you sure you want to delete this transaction?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (result == true) {
                                         widget.onDelete(tx['id']);

                                  setState(() {
                                    transactions.removeWhere(
                                      (item) => item['id'] == tx['id'],
                                    );
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Transaction deleted"),
                                    ),
                                  );
                                }
                                },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  //////////////////////////////////////////////////////
  // MINI CARD
  //////////////////////////////////////////////////////

  Widget _miniCard(
    String title,
    double amount,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),

          borderRadius:
              BorderRadius.circular(12),
        ),

        child: Column(
          children: [

            Text(
              title,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "₹ ${amount.toStringAsFixed(0)}",

              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}