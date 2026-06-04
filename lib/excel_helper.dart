import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

class ExcelHelper {

  // ==============================
  // 📄 EXPORT PDF
  // ==============================
  static Future<String> exportPdfByDate(
    List<Map<String, dynamic>> data,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final pdf = pw.Document();

    final filteredData = data.where((tx) {
      final txDate = DateTime.parse(tx['date']);
      return txDate.isAfter(fromDate.subtract(const Duration(days: 1))) &&
          txDate.isBefore(toDate.add(const Duration(days: 1)));
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Transaction Report",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text("From: ${fromDate.toLocal()}"),
              pw.Text("To: ${toDate.toLocal()}"),
              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: ["Date", "Type", "Category", "Amount"],
                data: filteredData.map((tx) {
                  return [
                    tx['date'].toString(),
                    tx['type'].toString(),
                    tx['category'].toString(),
                    tx['amount'].toString(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final dir = Directory("/storage/emulated/0/Download");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(
      "${dir.path}/wallet_report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // ==============================
  // 📊 EXPORT EXCEL
  // ==============================
  static Future<String> exportExcelByDate(
    List<Map<String, dynamic>> data,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Report'];

    // HEADER ROW
    sheet.appendRow(["Date", "Type", "Category", "Amount"]);

    // FILTER DATA
    final filteredData = data.where((tx) {
      final txDate = DateTime.parse(tx['date']);
      return txDate.isAfter(fromDate.subtract(const Duration(days: 1))) &&
          txDate.isBefore(toDate.add(const Duration(days: 1)));
    }).toList();

    // ADD DATA ROWS
    for (var tx in filteredData) {
      sheet.appendRow([
        tx['date'].toString(),
        tx['type'].toString(),
        tx['category'].toString(),
        tx['amount'].toString(),
      ]);
    }

    final dir = Directory("/storage/emulated/0/Download");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File(
      "${dir.path}/wallet_report_${DateTime.now().millisecondsSinceEpoch}.xlsx",
    );

    await file.writeAsBytes(excel.encode()!);

    return file.path;
  }
}