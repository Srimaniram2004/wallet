import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  final List<String> categories;
  final Function(String) onAdd;

  const CategoryScreen({
    super.key,
    required this.categories,
    required this.onAdd,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final dark = isDark(context);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF121212) : const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Categories"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: dark ? Colors.black : Colors.teal,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: dark
                    ? const LinearGradient(
                        colors: [Color(0xFF232526), Color(0xFF414345)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                      ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manage Categories",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${widget.categories.length} total categories",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= INPUT =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: dark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Add new category",
                      hintStyle: TextStyle(
                          color: dark ? Colors.grey : Colors.grey.shade600),
                      prefixIcon: const Icon(Icons.category_outlined),
                      filled: true,
                      fillColor:
                          dark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Category"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? Colors.teal : Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;

                        widget.onAdd(controller.text.trim());
                        controller.clear();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= LIST =================
            Expanded(
              child: widget.categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 60,
                              color: dark ? Colors.grey : Colors.grey),
                          const SizedBox(height: 10),
                          Text(
                            "No categories yet",
                            style: TextStyle(
                              color: dark ? Colors.grey : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: widget.categories.length,
                      itemBuilder: (_, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                dark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: dark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: dark
                                      ? Colors.teal.withOpacity(0.2)
                                      : Colors.teal.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.label,
                                  color: Colors.teal,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  widget.categories[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),

                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}