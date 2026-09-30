import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Transactionpdf {
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);
  final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  void downloadPdf({
    required String eventId,
    required String eventName,
    required BuildContext ctx,
  }) async {
    try {
      pw.MemoryImage? imageLogo;
      try {
        final ByteData bytes = await rootBundle.load('assets/logo-removebg-preview.png');
        final Uint8List imageData = bytes.buffer.asUint8List();
        imageLogo = pw.MemoryImage(imageData);
      } catch (e) {
        debugPrint("Logo asset error: $e");
      }

      List<IncomeModel> incomeModel = await getIncome(eventId: eventId);
      List<ExpenseModel> expenseModel = await getExpense(eventId: eventId);
      Map<String, dynamic> allUsers = await getAllUsers();

      double totalIncome = incomeModel.fold(0.0, (acc, item) => acc + (item.amount ?? 0.0));
      double totalExpense = expenseModel.fold(0.0, (acc, item) => acc + (item.amount ?? 0.0));
      double balance = totalIncome - totalExpense;

      final pdf = pw.Document();

      // Theme colors
      final headerBg = PdfColor.fromHex('#1E1B4B');
      final headerAccent = PdfColor.fromHex('#4338CA');
      final successColor = PdfColor.fromHex('#059669');
      final expenseColor = PdfColor.fromHex('#DC2626');
      final primaryText = PdfColor.fromHex('#0F172A');
      final secondaryText = PdfColor.fromHex('#64748B');
      final tableHeaderBg = PdfColor.fromHex('#1E293B');
      final tableRowAlt = PdfColor.fromHex('#F8FAFC');
      final expenseHeaderBg = PdfColor.fromHex('#881337');
      final expenseRowAlt = PdfColor.fromHex('#FFF1F2');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context context) {
            if (context.pageNumber == 1) {
              return pw.SizedBox.shrink();
            }
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              padding: const pw.EdgeInsets.only(bottom: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${eventName.toUpperCase()}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: secondaryText,
                    ),
                  ),
                  pw.Text(
                    'UNITED AREECHOLA',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: headerAccent,
                    ),
                  ),
                ],
              ),
            );
          },
          footer: (pw.Context context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(top: 16),
              padding: const pw.EdgeInsets.only(top: 8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated on: ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 8, color: secondaryText),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: secondaryText),
                  ),
                ],
              ),
            );
          },
          build: (pw.Context context) => [
            // Banner Header
            _buildHeaderBanner(imageLogo, eventName, headerBg, headerAccent),
            pw.SizedBox(height: 20),

            // Financial Summary Metrics
            _buildSummarySection(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              balance: balance,
              successColor: successColor,
              expenseColor: expenseColor,
              primaryText: primaryText,
              secondaryText: secondaryText,
            ),
            pw.SizedBox(height: 24),

            // Income Section
            if (incomeModel.isNotEmpty) ...[
              _buildSectionHeader('INCOME CONTRIBUTIONS', '${incomeModel.length} Transactions', successColor),
              pw.SizedBox(height: 10),
              _buildIncomeTable(incomeModel, allUsers, tableHeaderBg, tableRowAlt, primaryText, successColor),
              pw.SizedBox(height: 24),
            ],

            // Expense Section
            if (expenseModel.isNotEmpty) ...[
              _buildSectionHeader('EXPENSE BREAKDOWN', '${expenseModel.length} Expense Items', expenseColor),
              pw.SizedBox(height: 10),
              _buildExpenseTable(expenseModel, expenseHeaderBg, expenseRowAlt, primaryText, expenseColor),
              pw.SizedBox(height: 24),
            ],

            // Empty State Notice if no records
            if (incomeModel.isEmpty && expenseModel.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(30),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'No transactions or expenses recorded for this event.',
                  style: pw.TextStyle(fontSize: 12, color: secondaryText),
                ),
              ),

            pw.SizedBox(height: 20),
            _buildSignatureBlock(primaryText, secondaryText),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: '${eventName.replaceAll(' ', '_')}_Financial_Report',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Error generating PDF: ${e.toString()}');
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
        );
      }
    }
  }

  // Header Banner
  pw.Widget _buildHeaderBanner(
    pw.MemoryImage? logo,
    String eventName,
    PdfColor bg,
    PdfColor accent,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'UNITED AREECHOLA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'OFFICIAL EVENT FINANCIAL STATEMENT',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#A5B4FC'),
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#FFFFFF25'),
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(color: PdfColor.fromHex('#FFFFFF40'), width: 0.5),
                  ),
                  child: pw.Text(
                    eventName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (logo != null)
            pw.Container(
              width: 56,
              height: 56,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Image(logo, fit: pw.BoxFit.contain),
            ),
        ],
      ),
    );
  }

  // Financial Summary Cards
  pw.Widget _buildSummarySection({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required PdfColor successColor,
    required PdfColor expenseColor,
    required PdfColor primaryText,
    required PdfColor secondaryText,
  }) {
    final balanceColor = balance >= 0 ? successColor : expenseColor;

    return pw.Row(
      children: [
        _buildMetricCard('TOTAL INCOME', currencyFormat.format(totalIncome), successColor, PdfColor.fromHex('#ECFDF5')),
        pw.SizedBox(width: 12),
        _buildMetricCard('TOTAL EXPENSES', currencyFormat.format(totalExpense), expenseColor, PdfColor.fromHex('#FEF2F2')),
        pw.SizedBox(width: 12),
        _buildMetricCard('NET BALANCE', currencyFormat.format(balance), balanceColor, balance >= 0 ? PdfColor.fromHex('#EFF6FF') : PdfColor.fromHex('#FFF1F2')),
      ],
    );
  }

  pw.Widget _buildMetricCard(String label, String amount, PdfColor color, PdfColor bgColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: color, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              amount,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F172A'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Header
  pw.Widget _buildSectionHeader(String title, String subtitle, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 4,
              height: 14,
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0F172A'),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F1F5F9'),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#475569'),
            ),
          ),
        ),
      ],
    );
  }

  // Income Table
  pw.Widget _buildIncomeTable(
    List<IncomeModel> items,
    Map<String, dynamic> allUsers,
    PdfColor headerBg,
    PdfColor rowAlt,
    PdfColor textDark,
    PdfColor successColor,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
        bottom: pw.BorderSide(color: PdfColor.fromHex('#CBD5E1'), width: 1),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(32),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: headerBg,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader('#', pw.TextAlign.center),
            _buildTableHeader('CONTRIBUTOR NAME', pw.TextAlign.left),
            _buildTableHeader('DATE', pw.TextAlign.left),
            _buildTableHeader('AMOUNT', pw.TextAlign.right),
          ],
        ),
        // Rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;
          final userName = (item.user != null && item.user!.isNotEmpty && allUsers.containsKey(item.user))
              ? allUsers[item.user].toString().toUpperCase()
              : (item.username?.isNotEmpty == true ? item.username!.toUpperCase() : 'ANONYMOUS');

          final dateStr = item.createdDate != null
              ? DateFormat('dd MMM yyyy').format(item.createdDate!)
              : 'N/A';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : rowAlt,
            ),
            children: [
              _buildTableCell('${index + 1}', align: pw.TextAlign.center, isBold: true),
              _buildTableCell(userName, align: pw.TextAlign.left, isBold: true),
              _buildTableCell(dateStr, align: pw.TextAlign.left),
              _buildTableCell(
                currencyFormat.format(item.amount ?? 0),
                align: pw.TextAlign.right,
                color: successColor,
                isBold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  // Expense Table
  pw.Widget _buildExpenseTable(
    List<ExpenseModel> items,
    PdfColor headerBg,
    PdfColor rowAlt,
    PdfColor textDark,
    PdfColor expenseColor,
  ) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
        bottom: pw.BorderSide(color: PdfColor.fromHex('#CBD5E1'), width: 1),
      ),
      columnWidths: const {
        0: pw.FixedColumnWidth(32),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: headerBg,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader('#', pw.TextAlign.center),
            _buildTableHeader('EXPENSE ITEM', pw.TextAlign.left),
            _buildTableHeader('DATE', pw.TextAlign.left),
            _buildTableHeader('AMOUNT', pw.TextAlign.right),
          ],
        ),
        // Rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;

          final dateStr = item.createdDate != null
              ? DateFormat('dd MMM yyyy').format(item.createdDate!)
              : 'N/A';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : rowAlt,
            ),
            children: [
              _buildTableCell('${index + 1}', align: pw.TextAlign.center, isBold: true),
              _buildTableCell(item.expense?.toUpperCase() ?? 'EXPENSE ITEM', align: pw.TextAlign.left, isBold: true),
              _buildTableCell(dateStr, align: pw.TextAlign.left),
              _buildTableCell(
                currencyFormat.format(item.amount ?? 0),
                align: pw.TextAlign.right,
                color: expenseColor,
                isBold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text, pw.TextAlign align) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          letterSpacing: 0.5,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    required pw.TextAlign align,
    PdfColor? color,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColor.fromHex('#334155'),
        ),
        textAlign: align,
      ),
    );
  }

  // Signature block
  pw.Widget _buildSignatureBlock(PdfColor textDark, PdfColor textMuted) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Report verified & issued by:',
              style: pw.TextStyle(fontSize: 8, color: textMuted),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'United Areechola',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              width: 100,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.8)),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Authorized Signature',
              style: pw.TextStyle(fontSize: 8, color: textMuted),
            ),
          ],
        ),
      ],
    );
  }

  // Data Fetching Methods with Soft-Delete Filtering
  Future<List<IncomeModel>> getIncome({required String eventId}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .get();

      if (snap.docs.isEmpty) return [];

      return snap.docs
          .where((doc) => doc.data()["delete"] != true)
          .map((doc) => IncomeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching income for PDF: $e");
      return [];
    }
  }

  Future<List<ExpenseModel>> getExpense({required String eventId}) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("expense")
          .get();

      if (snap.docs.isEmpty) return [];

      return snap.docs
          .where((doc) => doc.data()["delete"] != true)
          .map((doc) => ExpenseModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching expense for PDF: $e");
      return [];
    }
  }

  Future<Map<String, String>> getAllUsers() async {
    Map<String, String> userMap = {};
    try {
      final userSnap = await FirebaseFirestore.instance.collection("users").get();
      for (var userDoc in userSnap.docs) {
        if (userDoc.data().containsKey('name')) {
          userMap[userDoc.id] = userDoc.data()['name'];
        }
      }
      return userMap;
    } catch (e) {
      debugPrint("Error fetching users for PDF: $e");
      return userMap;
    }
  }
}

class IncomeModel {
  String? user;
  double? amount;
  String? username;
  DateTime? createdDate;

  IncomeModel({this.user, this.amount, this.username, this.createdDate});

  factory IncomeModel.fromJson(Map<String, dynamic> data) {
    final rawAmount = data['amount'];
    return IncomeModel(
      username: data['username'],
      user: data['userId'] ?? "",
      amount: rawAmount != null ? (rawAmount as num).toDouble() : 0.0,
      createdDate: data['createdDate'] != null ? (data['createdDate'] as Timestamp).toDate() : null,
    );
  }
}

class ExpenseModel {
  String? expense;
  double? amount;
  DateTime? createdDate;

  ExpenseModel({this.expense, this.amount, this.createdDate});

  factory ExpenseModel.fromJson(Map<String, dynamic> data) {
    final rawAmount = data['expenseAmount'] ?? data['amount'];
    return ExpenseModel(
      expense: data['expenseName'] ?? "",
      amount: rawAmount != null ? (rawAmount as num).toDouble() : 0.0,
      createdDate: data['createdDate'] != null ? (data['createdDate'] as Timestamp).toDate() : null,
    );
  }
}
