
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import 'db/db_helper.dart';
import 'excel_helper.dart';
import 'app_localization.dart';
import 'package:open_filex/open_filex.dart';

class ReportScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final VoidCallback onRefresh;

  const ReportScreen({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  //////////////////////////////////////////////////
  // DATE VARIABLES
  //////////////////////////////////////////////////

  DateTime? fromDate;
  DateTime? toDate;

  final format = DateFormat('dd-MM-yyyy');

  //////////////////////////////////////////////////
  // THEME
  //////////////////////////////////////////////////

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get bgColor =>
      isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA);

  Color get cardColor =>
      isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get textColor =>
      isDark ? Colors.white : Colors.black;

  //////////////////////////////////////////////////
  // PICK FROM DATE
  //////////////////////////////////////////////////

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

  //////////////////////////////////////////////////
  // PICK TO DATE
  //////////////////////////////////////////////////

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

  //////////////////////////////////////////////////
  // VALIDATE DATES
  //////////////////////////////////////////////////

  bool validateDates() {
    final t = AppLocalizations.of(context);

    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate("select_date_error")),
        ),
      );
      return false;
    }
    return true;
  }

  //////////////////////////////////////////////////
  // EXPORT PDF
  //////////////////////////////////////////////////

Future<void> exportPDF() async {
  if (!validateDates()) return;

  final t = AppLocalizations.of(context);

  final path = await ExcelHelper.exportPdfByDate(
    widget.data,
    fromDate!,
    toDate!,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        t.translate("pdf_saved"),
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: t.translate("open"),
        textColor: Colors.white,
        onPressed: () async {
          await OpenFilex.open(path);
        },
      ),
    ),
  );
}

  //////////////////////////////////////////////////
  // EXPORT EXCEL
  //////////////////////////////////////////////////
Future<void> exportExcel() async {
  if (!validateDates()) return;

  final t = AppLocalizations.of(context);

  final path = await ExcelHelper.exportExcelByDate(
    widget.data,
    fromDate!,
    toDate!,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "${t.translate("excel_saved")}",
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: t.translate("open"),
        textColor: Colors.white,
        onPressed: () async {
          await OpenFilex.open(path);
        },
      ),
    ),
  );
}

  //////////////////////////////////////////////////
  // UPLOAD PDF
  //////////////////////////////////////////////////

Future<void> uploadPDF() async {
  final t = AppLocalizations.of(context);

  FilePickerResult? result =
      await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          t.translate("no_pdf_selected"),
        ),
      ),
    );
    return;
  }

  final file = result.files.single;

  try {
    //////////////////////////////////////////////////
    // USER LANGUAGE
    //////////////////////////////////////////////////

    String language =
        Localizations.localeOf(context)
            .languageCode;

    //////////////////////////////////////////////////
    // SAMPLE EXPENSE
    //////////////////////////////////////////////////

    await DBHelper.insertPDFTransaction(
      amount: 500,
      type: "Expense",
      category: "Others",
      subCategory: "General",
      language: language,
      note: "Imported PDF: ${file.name}",
    );

    //////////////////////////////////////////////////
    // SAMPLE INCOME
    //////////////////////////////////////////////////

    await DBHelper.insertPDFTransaction(
      amount: 10000,
      type: "Income",
      category: "Salary",
      subCategory: "Monthly Salary",
      language: language,
      note: "Imported PDF: ${file.name}",
    );

    widget.onRefresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${t.translate("pdf_imported")}: ${file.name}",
        ),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${t.translate("pdf_failed")} : $e",  
        ),
      ),
    );
  }
}

  //////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.teal,
        title: Text(t.translate("reports_export")),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////////////////////////////////////////
            // HEADER CARD
            //////////////////////////////////////////////////

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.analytics,
                      size: 45, color: Colors.white),

                  const SizedBox(height: 14),

                  Text(
                    t.translate("financial_reports"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    t.translate("report_subtitle"),
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            //////////////////////////////////////////////////
            // DATE SECTION
            //////////////////////////////////////////////////

            Text(
              t.translate("select_date_range"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 14),

            _buildDateTile(
              icon: Icons.calendar_month,
              title: fromDate == null
                  ? t.translate("choose_from_date")
                  : "${t.translate("from")} : ${format.format(fromDate!)}",
              onTap: pickFromDate,
            ),

            const SizedBox(height: 12),

            _buildDateTile(
              icon: Icons.calendar_today,
              title: toDate == null
                  ? t.translate("choose_to_date")
                  : "${t.translate("to")} : ${format.format(toDate!)}",
              onTap: pickToDate,
            ),

            const SizedBox(height: 28),

            //////////////////////////////////////////////////
            // EXPORT BUTTONS
            //////////////////////////////////////////////////

            _premiumButton(
              color: Colors.red,
              icon: Icons.picture_as_pdf,
              title: t.translate("download_pdf"),
              onTap: exportPDF,
            ),

            const SizedBox(height: 14),

            _premiumButton(
              color: Colors.green,
              icon: Icons.table_chart,
              title: t.translate("download_excel"),
              onTap: exportExcel,
            ),

            const SizedBox(height: 14),

            _premiumButton(
              color: Colors.blue,
              icon: Icons.upload_file,
              title: t.translate("upload_pdf"),
              onTap: uploadPDF,
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // DATE TILE
  //////////////////////////////////////////////////

  Widget _buildDateTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.15),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  //////////////////////////////////////////////////
  // PREMIUM BUTTON
  //////////////////////////////////////////////////

  Widget _premiumButton({
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}