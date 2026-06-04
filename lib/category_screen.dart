import 'package:flutter/material.dart';
import 'app_localization.dart';

class CategoryScreen extends StatefulWidget {
  final Map<String, List<String>> categories;
  final Future<void> Function(String) onAddCategory;
  final Future<void> Function(String, String)
      onAddSubCategory;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onAddSubCategory,
  });

  @override
  State<CategoryScreen> createState() =>
      _CategoryScreenState();
}

class _CategoryScreenState
    extends State<CategoryScreen> {

  final categoryController =
      TextEditingController();

  final subCategoryController =
      TextEditingController();

  String? selectedCategory;

  bool loading = false;

  //////////////////////////////////////////////////
  // DUMMY SUBCATEGORIES
  //////////////////////////////////////////////////

  late Map<String, List<String>>
      dummySubCategories;

  @override
  void initState() {

    super.initState();

    //////////////////////////////////////////////////
    // LOAD AFTER BUILD
    //////////////////////////////////////////////////

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {

      final tr =
          AppLocalizations.of(context);

      //////////////////////////////////////////////////
      // LOCALIZED DATA
      //////////////////////////////////////////////////

      dummySubCategories = {

        tr.tr('food'): [

          tr.tr('breakfast'),

          tr.tr('lunch'),

          tr.tr('dinner'),

          tr.tr('snacks'),
        ],

        tr.tr('travel'): [

          tr.tr('bus'),

          tr.tr('train'),

          tr.tr('fuel'),

          tr.tr('taxi'),
        ],

        tr.tr('shopping'): [

          tr.tr('clothes'),

          tr.tr('electronics'),

          tr.tr('groceries'),

          tr.tr('accessories'),
        ],

        tr.tr('bills'): [

          tr.tr('electricity'),

          tr.tr('internet'),

          tr.tr('water'),

          tr.tr('mobile_recharge'),
        ],

        tr.tr('entertainment'): [

          tr.tr('movies'),

          tr.tr('games'),

          tr.tr('music'),

          tr.tr('ott'),
        ],

        tr.tr('health'): [

          tr.tr('medicine'),

          tr.tr('doctor'),

          tr.tr('gym'),

          tr.tr('insurance'),
        ],

        tr.tr('education'): [

          tr.tr('books'),

          tr.tr('fees'),

          tr.tr('courses'),

          tr.tr('stationery'),
        ],
      };

      //////////////////////////////////////////////////
      // INSERT DATA
      //////////////////////////////////////////////////

      for (var entry
          in dummySubCategories.entries) {

        if (!widget.categories
            .containsKey(entry.key)) {

          await widget.onAddCategory(
              entry.key);
        }

        for (var sub in entry.value) {

          final existingSubs =
              widget.categories[entry.key] ??
                  [];

          if (!existingSubs.contains(sub)) {

            await widget.onAddSubCategory(
              entry.key,
              sub,
            );
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {

    categoryController.dispose();

    subCategoryController.dispose();

    super.dispose();
  }

  bool isDark(BuildContext context) {

    return Theme.of(context)
            .brightness ==
        Brightness.dark;
  }

  void showMsg(String msg) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  //////////////////////////////////////////////////
  // ADD CATEGORY
  //////////////////////////////////////////////////

  Future<void> addCategory() async {

    final text =
        categoryController.text.trim();

    final tr =
        AppLocalizations.of(context);

    if (text.isEmpty) return;

    if (widget.categories
        .containsKey(text)) {

      showMsg(
          tr.tr('category_exists'));

      return;
    }

    setState(() => loading = true);

    await widget.onAddCategory(text);

    categoryController.clear();

    selectedCategory = text;

    setState(() => loading = false);

    showMsg(
        tr.tr('category_added'));
  }

  //////////////////////////////////////////////////
  // ADD SUBCATEGORY
  //////////////////////////////////////////////////

  Future<void> addSubCategory() async {

    final sub =
        subCategoryController.text.trim();

    final tr =
        AppLocalizations.of(context);

    if (selectedCategory == null ||
        sub.isEmpty) {
      return;
    }

    if (widget.categories[
            selectedCategory!]!
        .contains(sub)) {

      showMsg(
          tr.tr('subcategory_exists'));

      return;
    }

    setState(() => loading = true);

    await widget.onAddSubCategory(
      selectedCategory!,
      sub,
    );

    subCategoryController.clear();

    setState(() => loading = false);

    showMsg(
        tr.tr('subcategory_added'));
  }

  @override
  Widget build(BuildContext context) {

    final tr =
        AppLocalizations.of(context);

    final dark = isDark(context);

    final bgColor = dark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F6FA);

    final cardColor = dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    final textColor =
        dark ? Colors.white : Colors.black;

    return Scaffold(

      backgroundColor: bgColor,

      appBar: AppBar(

        title: Text(
          tr.tr('categories'),
        ),

        centerTitle: true,

        backgroundColor:
            dark ? Colors.black : Colors.teal,
      ),

      body: Column(
        children: [

          Container(

            width: double.infinity,

            margin:
                const EdgeInsets.all(16),

            padding:
                const EdgeInsets.all(20),

            decoration: BoxDecoration(

              gradient:
                  const LinearGradient(

                colors: [

                  Color(0xFF00B09B),

                  Color(0xFF96C93D),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(

              "${widget.categories.length} ${tr.tr('categories')}",

              style: const TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,

                color: Colors.white,
              ),
            ),
          ),

          Expanded(

            child: SingleChildScrollView(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: Column(
                children: [

                  _card(

                    cardColor,

                    Column(
                      children: [

                        _input(
                          categoryController,
                          tr.tr('new_category'),
                        ),

                        const SizedBox(
                            height: 12),

                        _button(
                          tr.tr('add_category'),
                          addCategory,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  _card(

                    cardColor,

                    Column(
                      children: [

                        DropdownButtonFormField<
                            String>(

                          value:
                              selectedCategory,

                          decoration:
                              _inputDecoration(
                            tr.tr(
                                'select_category'),
                          ),

                          items: widget
                              .categories.keys
                              .map((cat) {

                            return DropdownMenuItem(

                              value: cat,

                              child: Text(tr.tr(cat)),
                            );
                          }).toList(),

                          onChanged: (val) {

                            setState(() {

                              selectedCategory =
                                  val;
                            });
                          },
                        ),

                        const SizedBox(
                            height: 12),

                        _input(
                          subCategoryController,
                          tr.tr(
                              'new_subcategory'),
                        ),

                        const SizedBox(
                            height: 12),

                        _button(
                          tr.tr(
                              'add_subcategory'),
                          addSubCategory,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  widget.categories.isEmpty

                      ? Padding(

                          padding:
                              const EdgeInsets.only(
                            top: 40,
                          ),

                          child: Text(

                            tr.tr(
                                'no_categories_yet'),

                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        )

                      : Column(

                          children: widget
                              .categories.entries
                              .map((entry) {

                            return _categoryCard(
                              entry,
                              cardColor,
                              textColor,
                              tr,
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),

          if (loading)

            const Padding(

              padding: EdgeInsets.all(10),

              child:
                  CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////
  // CATEGORY CARD
  //////////////////////////////////////////////////

  Widget _categoryCard(

    MapEntry<String, List<String>> entry,

    Color cardColor,

    Color textColor,

    AppLocalizations tr,
  ) {

    return Container(

      margin:
          const EdgeInsets.only(bottom: 12),

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: cardColor,

        borderRadius:
            BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(0.05),

            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              const Icon(
                Icons.folder,
                color: Colors.teal,
              ),

              const SizedBox(width: 8),

              Text(

                tr.tr(entry.key),

                style: TextStyle(

                  fontSize: 16,

                  fontWeight:
                      FontWeight.bold,

                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          entry.value.isEmpty

              ? Text(
                  tr.tr(
                      'no_subcategories'),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                )

              : Wrap(

                  spacing: 8,

                  runSpacing: 6,

                  children:
                      entry.value.map((sub) {

                    return Container(

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(

                        color: Colors.teal
                            .withOpacity(0.15),

                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),

                      child: Text(

                        sub,

                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////
  // CARD
  //////////////////////////////////////////////////

  Widget _card(
    Color color,
    Widget child,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: color,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black.withOpacity(0.04),

            blurRadius: 10,
          ),
        ],
      ),

      child: child,
    );
  }

  //////////////////////////////////////////////////
  // INPUT
  //////////////////////////////////////////////////

  Widget _input(
    TextEditingController controller,
    String hint,
  ) {

    return TextField(

      controller: controller,

      decoration:
          _inputDecoration(hint),
    );
  }

  //////////////////////////////////////////////////
  // INPUT DECORATION
  //////////////////////////////////////////////////

  InputDecoration _inputDecoration(
      String hint) {

    return InputDecoration(

      hintText: hint,

      filled: true,

      fillColor:
          Colors.grey.withOpacity(0.1),

      border: OutlineInputBorder(

        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),
    );
  }

  //////////////////////////////////////////////////
  // BUTTON
  //////////////////////////////////////////////////

  Widget _button(
    String text,
    VoidCallback onTap,
  ) {

    return SizedBox(

      width: double.infinity,

      child: ElevatedButton(

        onPressed:
            loading ? null : onTap,

        style:
            ElevatedButton.styleFrom(

          backgroundColor: Colors.teal,

          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
          ),

          shape: RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(14),
          ),
        ),

        child: Text(text),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'app_localization.dart';

class CategoryScreen extends StatefulWidget {
  final Map<String, List<String>> categories;
  final Future<void> Function(String) onAddCategory;
  final Future<void> Function(String, String) onAddSubCategory;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAddCategory,
    required this.onAddSubCategory,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final categoryController = TextEditingController();
  final subCategoryController = TextEditingController();

  String? selectedCategory;
  bool loading = false;

  @override
  void dispose() {
    categoryController.dispose();
    subCategoryController.dispose();
    super.dispose();
  }

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ✅ SAFE TRANSLATION (IMPORTANT FIX)
  String safeText(AppLocalizations tr, String key) {
    final value = tr.tr(key);
    return value == key ? key : value;
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> addCategory() async {
    final text = categoryController.text.trim();
    final tr = AppLocalizations.of(context);

    if (text.isEmpty) return;

    if (widget.categories.containsKey(text)) {
      showMsg(tr.tr('category_exists'));
      return;
    }

    setState(() => loading = true);

    await widget.onAddCategory(text);

    categoryController.clear();
    selectedCategory = text;

    setState(() => loading = false);

    showMsg(tr.tr('category_added'));
  }

  Future<void> addSubCategory() async {
    final sub = subCategoryController.text.trim();
    final tr = AppLocalizations.of(context);

    if (selectedCategory == null || sub.isEmpty) return;

    if (widget.categories[selectedCategory!]!.contains(sub)) {
      showMsg(tr.tr('subcategory_exists'));
      return;
    }

    setState(() => loading = true);

    await widget.onAddSubCategory(selectedCategory!, sub);

    subCategoryController.clear();

    setState(() => loading = false);

    showMsg(tr.tr('subcategory_added'));
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    final dark = isDark(context);

    final bgColor = dark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F6FA);

    final cardColor = dark ? const Color(0xFF1E1E1E) : Colors.white;

    final textColor = dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: Text(tr.tr('categories')),
        centerTitle: true,
        backgroundColor: dark ? Colors.black : Colors.teal,
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              "${widget.categories.length} ${tr.tr('categories')}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _card(
                    cardColor,
                    Column(
                      children: [
                        _input(categoryController, tr.tr('new_category')),
                        const SizedBox(height: 12),
                        _button(tr.tr('add_category'), addCategory),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  _card(
                    cardColor,
                    Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: _inputDecoration(tr.tr('select_category')),

                          items: widget.categories.keys.map((cat) {
                            return DropdownMenuItem(
                              value: cat,

                              // ✅ SAFE FIX (NO DOUBLE TRANSLATION)
                              child: Text(safeText(tr, cat)),
                            );
                          }).toList(),

                          onChanged: (val) {
                            setState(() {
                              selectedCategory = val;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        _input(subCategoryController, tr.tr('new_subcategory')),

                        const SizedBox(height: 12),

                        _button(tr.tr('add_subcategory'), addSubCategory),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  widget.categories.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            tr.tr('no_categories_yet'),
                            style: TextStyle(color: textColor),
                          ),
                        )
                      : Column(
                          children: widget.categories.entries.map((entry) {
                            return _categoryCard(entry, cardColor, textColor, tr);
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // ================= CATEGORY CARD =================

  Widget _categoryCard(
    MapEntry<String, List<String>> entry,
    Color cardColor,
    Color textColor,
    AppLocalizations tr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder, color: Colors.teal),
              const SizedBox(width: 8),

              // ✅ FIXED HERE ALSO
              Text(
                safeText(tr, entry.key),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: entry.value.map((sub) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(sub),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card(Color color, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _button(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        child: Text(text),
      ),
    );
  }
}*/