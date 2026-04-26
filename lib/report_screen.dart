import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'excel_helper.dart';

class ReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const ReportScreen({super.key, required this.data});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  final format = DateFormat('dd-MM-yyyy');

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get cardColor =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : Colors.black;

  Color get subTextColor =>
      isDark ? Colors.grey : Colors.grey.shade700;

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => fromDate = picked);
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => toDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.teal,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= HEADER CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF232526), Color(0xFF414345)],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                      ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Generate Report",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Select date range to export PDF",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= FROM DATE =================
            _buildDateTile(
              icon: Icons.date_range,
              title: fromDate == null
                  ? "Select From Date"
                  : "From: ${format.format(fromDate!)}",
              onTap: pickFromDate,
            ),

            const SizedBox(height: 10),

            // ================= TO DATE =================
            _buildDateTile(
              icon: Icons.date_range,
              title: toDate == null
                  ? "Select To Date"
                  : "To: ${format.format(toDate!)}",
              onTap: pickToDate,
            ),

            const SizedBox(height: 10),

            // ================= SELECTED RANGE =================
            if (fromDate != null && toDate != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.teal.withOpacity(0.15)
                      : Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Selected: ${format.format(fromDate!)} → ${format.format(toDate!)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // ================= EXPORT BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Download PDF Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (fromDate == null || toDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select From & To date"),
                      ),
                    );
                    return;
                  }

                  final path = await PdfHelper.exportPdfByDate(
                    widget.data,
                    fromDate!,
                    toDate!,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("PDF Saved: $path"),
                      backgroundColor: Colors.green,
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

  // ================= REUSABLE DATE TILE =================
  Widget _buildDateTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardColor,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
    );
  }
}