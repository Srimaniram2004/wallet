import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localization.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'db/db_helper.dart';
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
    //String selectedAccount = 'Personal';
    String selectedProfile = 'Personal';
    Locale? _lastLocale;

    final controller = TextEditingController();


    String type = "expense";  

    @override

void didChangeDependencies() {
  super.didChangeDependencies();

  final currentLocale =
      Localizations.localeOf(context);

  if (_lastLocale != currentLocale) {
    _lastLocale = currentLocale;

    loadCategoriesFromDB();
  }
}



    //String category = "Food";
    String? category;


    String? subCategory;
    String? attachmentPath;

  

    String currencySymbol = "₹";

    
Future<void> pickImage() async {
  final picker = ImagePicker();

  final XFile? image =
      await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image != null) {
    setState(() {
      attachmentPath = image.path;
    });
  }
}

Future<void> pickCamera() async {
  final picker = ImagePicker();

  final XFile? image =
      await picker.pickImage(
    source: ImageSource.camera,
  );

  if (image != null) {
    setState(() {
      attachmentPath = image.path;
    });
  }
}

Future<void> loadSelectedProfile() async {
  final prefs =
      await SharedPreferences.getInstance();

  selectedProfile =
      prefs.getString(
        'selectedProfile',
      ) ??
      'Personal';

  await loadCategoriesFromDB();

  if (mounted) {
    setState(() {});
  }
}

Future<void> pickFile() async {
  final result =
      await FilePicker.platform.pickFiles();

  if (result != null) {
    setState(() {
      attachmentPath =
          result.files.single.path;
    });
  }
}
Future<void> loadCategoriesFromDB() async {
  final cats =
      await DBHelper.getCategories(
    selectedProfile,
  );

  final subs =
      await DBHelper.getSubCategories(
    selectedProfile,
  );

  setState(() {
    widget.categories.clear();

    widget.categories.addAll(
      cats.map(
        (e) => e['name'].toString(),
      ),
    );

    widget.subCategories.clear();
    widget.subCategories.addAll(subs);
  });
}
Future<void> _showAddCategoryDialog() async {
  final TextEditingController categoryController =
      TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(
            hintText: "Category name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
              onPressed: () async{
                final newCategory =
                    categoryController.text.trim();

                if (widget.categories.any(
                  (e) =>
                      e.toLowerCase() ==
                      newCategory.toLowerCase(),
                )) {
                  Navigator.pop(context);
                  return;
                }

                if (newCategory.isNotEmpty) {
                              await DBHelper.insertCategory(
                selectedProfile,
                newCategory,
              );

              setState(() {
                widget.categories.add(newCategory);

                widget.subCategories[
                    newCategory.toLowerCase()] = [];

                category = newCategory;
                subCategory = null;
              });
                                

                  Navigator.pop(context);
                }
              },
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}
Future<void> _showAddSubCategoryDialog() async {
  if (category == null) return;

  final TextEditingController subController =
      TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Add Subcategory"),
        content: TextField(
          controller: subController,
          decoration: const InputDecoration(
            hintText: "Subcategory name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async{
  final newSub =
      subController.text.trim();

  final existing =
      widget.subCategories[
              category!.toLowerCase()] ??
          [];

  if (existing.any(
    (e) =>
        e.toLowerCase() ==
        newSub.toLowerCase(),
  )) {
    Navigator.pop(context);
    return;
  }

  if (newSub.isNotEmpty) {
   await DBHelper.insertSubCategory(
  selectedProfile,
  category!.toLowerCase(),
  newSub,
);

setState(() {
  widget.subCategories
      .putIfAbsent(
        category!.toLowerCase(),
        () => [],
      )
      .add(newSub);

  subCategory = newSub;
});



    Navigator.pop(context);
  }
},
            child: const Text("Add"),
          ),
        ],
      );
    },
  );
}


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
      
      loadSelectedProfile();

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
      widget.subCategories[
        category!.toLowerCase()
      ];

  if (subs != null && subs.isNotEmpty) {
    subCategory = subs.first;
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
      'attachment' : attachmentPath,
      'account': selectedProfile,
      'project': selectedProfile,
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
        : widget.subCategories[
              category!.toLowerCase()
          ] ??
          [];

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
          child: SingleChildScrollView(
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

                    //prefixText:
                      //  "$currencySymbol ",

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
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                     decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A3A)
                            : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.teal,
                          width: 1.5,
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
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Current Profile: ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  TextSpan(
                                    text: selectedProfile,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
                const SizedBox(height: 15),
                
              //category dd
              Row(
  children: [
    Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
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
                  .translate(
                      'select_category'),
              style: TextStyle(
                color: textColor,
              ),
            ),
            dropdownColor: cardColor,
            isExpanded: true,
            items:
                widget.categories.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                AppLocalizations.of(context)
                            .translate(e.toLowerCase()) ==
                        e.toLowerCase()
                    ? e
                    : AppLocalizations.of(context)
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
    ),

    const SizedBox(width: 8),

    IconButton(
      icon: const Icon(
        Icons.add_circle,
        color: Colors.teal,
      ),
      onPressed: _showAddCategoryDialog,
    ),
  ],
),

                const SizedBox(height: 15),

if (category != null)
  Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(
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
              hint: const Text(
                "Select Subcategory",
              ),
              dropdownColor: cardColor,
              isExpanded: true,
              items: subList.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                  AppLocalizations.of(context)
                              .translate(e.toLowerCase()) ==
                          e.toLowerCase()
                      ? e
                      : AppLocalizations.of(context)
                          .translate(e.toLowerCase()),
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
      ),

      const SizedBox(width: 8),

      IconButton(
        icon: const Icon(
          Icons.add_circle,
          color: Colors.teal,
        ),
        onPressed: _showAddSubCategoryDialog,
      ),
    ],
  ),
                  const SizedBox(height: 15),

                    Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Attachments",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [

                    GestureDetector(
                      onTap: pickImage,
                      child: Column(
                        children: const [
                          CircleAvatar(
                            child: Icon(Icons.image),
                          ),
                          SizedBox(height: 5),
                          Text("Gallery"),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: pickCamera,
                      child: Column(
                        children: const [
                          CircleAvatar(
                            child: Icon(Icons.camera_alt),
                          ),
                          SizedBox(height: 5),
                          Text("Camera"),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: pickFile,
                      child: Column(
                        children: const [
                          CircleAvatar(
                            child: Icon(Icons.attach_file),
                          ),
                          SizedBox(height: 5),
                          Text("File"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

                  if (attachmentPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                      children: [

                        if (attachmentPath!
                            .toLowerCase()
                            .endsWith('.jpg') ||
                            attachmentPath!
                            .toLowerCase()
                            .endsWith('.jpeg') ||
                            attachmentPath!
                            .toLowerCase()
                            .endsWith('.png'))
                          SizedBox(
                            height: 120,
                            child: Image.file(
                              File(attachmentPath!),
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 5),

                        Text(
                          attachmentPath!
                              .split('/')
                              .last,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

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
        ),
      );
    }
  }