import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  final List<String> categories;

  const AddScreen({super.key, required this.categories});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final controller = TextEditingController();

  String type = "Expense";
  String category = "Food";

  @override
  void initState() {
    super.initState();

    if (widget.categories.isNotEmpty) {
      category = widget.categories[0];
    }
  }

  void save() {
    if (controller.text.isEmpty) return;

    Navigator.pop(context, {
      'amount': double.parse(controller.text),
      'type': type,
      'category': category,
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA);

    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final fieldColor =
        isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;

    final textColor =
        isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text("Add Transaction"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.teal,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black54
                    : Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            children: [

              // 💰 AMOUNT INPUT
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Enter Amount",
                  labelStyle: TextStyle(color: textColor),
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: isDark ? Colors.tealAccent : Colors.teal,
                  ),
                  filled: true,
                  fillColor: fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔄 TYPE SELECTOR
              Row(
                children: [

                  // INCOME
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "Income";
                          category = "Salary";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: type == "Income"
                              ? Colors.green
                              : fieldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Income",
                            style: TextStyle(
                              color: type == "Income"
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // EXPENSE
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          type = "Expense";
                          category = "Food";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: type == "Expense"
                              ? Colors.red
                              : fieldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Expense",
                            style: TextStyle(
                              color: type == "Expense"
                                  ? Colors.white
                                  : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📂 CATEGORY DROPDOWN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: category,
                    dropdownColor: cardColor,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    items: widget.categories.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() => category = v!);
                    },
                  ),
                ),
              ),

              const Spacer(),

              // 💾 SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: save,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Transaction"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.teal.shade700 : Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}