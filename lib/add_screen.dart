import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localization.dart';

class AddScreen extends StatefulWidget {
  final List<String> categories;


  final Map<String, List<String>> subCategories;

  const AddScreen({
    super.key,
    required this.categories,
    required this.subCategories,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {

  final controller = TextEditingController();


  String type = "expense";  

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  type ??=
      AppLocalizations.of(context)
          .translate('expense');
}



  //String category = "Food";
  String? category;


  String? subCategory;

 

  String currencySymbol = "₹";

   

    void _setCategoryForType(String selectedType) {
    if (widget.categories.isEmpty) return;

    if (selectedType == "Income") {
      final incomeCategory = widget.categories.firstWhere(
        (e) =>
            e.toLowerCase().contains('salary') ||
            e.toLowerCase().contains('income'),
        orElse: () => widget.categories.first,
      );

      category = incomeCategory;
    } else {
      final expenseCategory = widget.categories.firstWhere(
        (e) =>
            e.toLowerCase().contains('food') ||
            e.toLowerCase().contains('expense'),
        orElse: () => widget.categories.first,
      );

      category = expenseCategory;
    }

    _loadSubCategory();
  }

  @override
  void initState() {
    super.initState();

    loadCurrency();

    if (widget.categories.isNotEmpty) {
      category = null;
      subCategory = null;
}
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
  // LOAD SUBCATEGORY
  //////////////////////////////////////////////////
void _loadSubCategory() {

  if (category == null) {
    subCategory = null;
    return;
  }

  final subs =
      widget.subCategories[category!];

  if (subs != null &&
      subs.isNotEmpty) {

    subCategory = subs[0];

  } else {

    subCategory = null;
  }
}
//save
void save() {

  final amount =
      double.tryParse(controller.text);

  if (amount == null ||
      amount <= 0 ||
      category == null) {
    return;
  }

  Navigator.pop(context, {

    'amount': amount,

    'type': type,

    'category': category,

    'subCategory': subCategory,
  });
}

 

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bgColor =
        isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF5F6FA);

    final cardColor =
        isDark
            ? const Color(0xFF1E1E1E)
            : Colors.white;

    final fieldColor =
        isDark
            ? const Color(0xFF2A2A2A)
            : Colors.grey.shade100;

    final textColor =
        isDark
            ? Colors.white
            : Colors.black;

    final subList =
    category == null
        ? <String>[]
        : widget.subCategories[category!] ?? [];

    return Scaffold(

      backgroundColor: bgColor,


      appBar: AppBar(

          title: Text(
            AppLocalizations.of(context)
                .translate('add_transaction'),
          ),

        centerTitle: true,

        backgroundColor:
            isDark
                ? Colors.black
                : Colors.teal,

        elevation: 0,
      ),

     

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Container(

          padding:
              const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: cardColor,

            borderRadius:
                BorderRadius.circular(18),

            boxShadow: [

              BoxShadow(

                color:
                    isDark
                        ? Colors.black54
                        : Colors.black
                            .withOpacity(0.05),

                blurRadius: 12,

                offset:
                    const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            children: [

              //////////////////////////////////////////////////
              // AMOUNT INPUT
              //////////////////////////////////////////////////

              TextField(

                controller: controller,

                keyboardType:
                    TextInputType.number,

                style:
                    TextStyle(
                  color: textColor,
                ),

                decoration: InputDecoration(

                  labelText: AppLocalizations.of(context)
                    .translate('enter_amount'),

                  labelStyle:
                      TextStyle(
                    color: textColor,
                  ),

                  //////////////////////////////////////////////////
                  // CURRENCY ICON
                  //////////////////////////////////////////////////

                  prefixIcon: Icon(

                    currencySymbol == "₹"
                        ? Icons.currency_rupee

                        : currencySymbol == "\$"
                            ? Icons.attach_money

                            : currencySymbol == "€"
                                ? Icons.euro

                                : currencySymbol == "£"
                                    ? Icons.currency_pound

                                    : Icons.monetization_on,

                    color:
                        isDark
                            ? Colors.tealAccent
                            : Colors.teal,
                  ),

                  //////////////////////////////////////////////////
                  // PREFIX TEXT
                  //////////////////////////////////////////////////

                  prefixText:
                      "$currencySymbol ",

                  prefixStyle:
                      TextStyle(
                    color: textColor,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),

                  filled: true,

                  fillColor: fieldColor,

                  border: OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(12),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // TYPE SELECTOR
              //////////////////////////////////////////////////

              Row(
                children: [

                  //////////////////////////////////////////////////
                  // INCOME
                  //////////////////////////////////////////////////

                  Expanded(
                    child: GestureDetector(

                      onTap: () {
                          setState(() {
                            type = "Income";
                            _setCategoryForType("Income");
                          });
                        },

                      child: Container(

                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color:
                              type == "Income"
                                  ? Colors.green
                                  : fieldColor,

                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: Center(
                          child: Text(

                               AppLocalizations.of(context)
                              .translate('income'),

                            style: TextStyle(

                              color:
                                  type == "Income"
                                      ? Colors.white
                                      : textColor,

                              fontWeight:
                                  FontWeight.bold,
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
                              _setCategoryForType("Expense");
                            });
                          },

                      child: Container(

                        padding:
                            const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color:
                              type == "Expense"
                                  ? Colors.red
                                  : fieldColor,

                          borderRadius:
                              BorderRadius.circular(12),
                        ),

                        child: Center(
                          child: Text(

                            AppLocalizations.of(context)
                            .translate('expense'),

                            style: TextStyle(

                              color:
                                  type == "Expense"
                                      ? Colors.white
                                      : textColor,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

            //category dd

              Container(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                decoration: BoxDecoration(

                  color: fieldColor,

                  borderRadius:
                      BorderRadius.circular(12),
                ),

                child: DropdownButtonHideUnderline(

                  child: DropdownButton<String>(

                  value: category,

                  hint: Text(
                    AppLocalizations.of(context)
                        .translate('select_category'),
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),

                    dropdownColor: cardColor,

                    isExpanded: true,

                    items: widget.categories.map((e) {

                      return DropdownMenuItem<String>(

                        value: e,

                       child: Text(
                        AppLocalizations.of(context)
                            .translate(e.toLowerCase()),
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      );

                  }).toList(),

                  onChanged: (v) {

                    setState(() {

                      category = v;

                      _loadSubCategory();
                    });
                  },
                ),
                ),
              ),

              const SizedBox(height: 15),


              if (subList.isNotEmpty)

                Container(

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  decoration: BoxDecoration(

                    color: fieldColor,

                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: DropdownButtonHideUnderline(

                    child: DropdownButton<String>(

                      value: subCategory,

                      hint:
                          const Text(
                        "Select Subcategory",
                      ),

                      dropdownColor: cardColor,

                      isExpanded: true,

                      items:
                          subList.map((e) {

                        return DropdownMenuItem(

                          value: e,

                          child: Text(

                            e,

                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        );
                      }).toList(),

                      onChanged: (v) {

                        setState(() {

                          subCategory = v;
                        });
                      },
                    ),
                  ),
                ),

              const Spacer(),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: save,

                  icon:
                      const Icon(Icons.save),

                  label:
                    Text(
                          AppLocalizations.of(context)
                              .translate('save_transaction'),
                        ),

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        isDark
                            ? Colors.teal.shade700
                            : Colors.teal,

                    foregroundColor:
                        Colors.white,

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
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