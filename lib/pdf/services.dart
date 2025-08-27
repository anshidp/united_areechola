// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:united_areechola/constants.dart';

class Transactionpdf {
  void downloadPdf({
    required String eventId,
    required String eventName,
    required BuildContext ctx,
  }) async {
    try {
      final ByteData bytes =
          await rootBundle.load('assets/logo-removebg-preview.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      List<IncomeModel> incomeModel = await getIncome(eventId: eventId);
      List<ExpenseModel>? expenseModel =
          await getExpense(eventId: eventId, ctx: ctx);
      Map<String, dynamic> allUsers = await getAllUsers();

      double totalExpense = 0;
      double balance = 0;
      double totalAmount = incomeModel
          .map((income) => (income.amount ?? 0))
          .reduce((a, b) => a + b);

      if (expenseModel != null) {
        totalExpense = expenseModel
            .map((expense) => (expense.amount ?? 0))
            .reduce((a, b) => a + b);
        balance = totalAmount - totalExpense;
      }

      final pdf = pw.Document();
      final imageLogo = pw.MemoryImage(imageData);

      // Define colors for consistent theming
      final primaryColor = PdfColor.fromHex('#6366F1');
      final secondaryColor = PdfColor.fromHex('#8B5CF6');
      final successColor = PdfColor.fromHex('#059669');
      final warningColor = PdfColor.fromHex('#D97706');
      final errorColor = PdfColor.fromHex('#DC2626');
      final lightGray = PdfColor.fromHex('#F3F4F6');
      final darkGray = PdfColor.fromHex('#374151');

      // Light color variants
      final primaryLight = PdfColor.fromHex('#E0E7FF');
      final secondaryLight = PdfColor.fromHex('#EDE9FE');
      final successLight = PdfColor.fromHex('#ECFDF5');
      final warningLight = PdfColor.fromHex('#FFFBEB');
      final errorLight = PdfColor.fromHex('#FEF2F2');
      final whiteTransparent = PdfColor.fromHex('#FFFFFF80');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          build: (context) => [
            // Header Section
            _buildHeader(imageLogo, eventName, primaryColor),
            pw.SizedBox(height: 30),

            // Summary Cards Section
            _buildSummarySection(
                totalAmount,
                totalExpense,
                balance,
                primaryColor,
                successColor,
                warningColor,
                errorColor,
                successLight,
                warningLight,
                errorLight),
            pw.SizedBox(height: 30),

            // Income Section
            if (incomeModel.isNotEmpty)
              _buildIncomeSection(
                  incomeModel, allUsers, primaryColor, lightGray, primaryLight),

            if (incomeModel.isNotEmpty &&
                expenseModel != null &&
                expenseModel.isNotEmpty)
              pw.SizedBox(height: 25),

            // Expense Section
            if (expenseModel != null && expenseModel.isNotEmpty)
              _buildExpenseSection(
                  expenseModel, secondaryColor, lightGray, secondaryLight),

            pw.SizedBox(height: 30),

            // Footer
            _buildFooter(darkGray),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: '${eventName}_Financial_Report',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error generating PDF: ${e.toString()}');
    }
  }

// Header Section
  pw.Widget _buildHeader(
      pw.MemoryImage logo, String eventName, PdfColor primaryColor) {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primaryColor, PdfColor.fromHex('#8B5CF6')],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'UNITED AREECHOLA',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Financial Report',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColor.fromHex('#E0E7FF'),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFFFFF40'),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  eventName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FFFFFF30'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Image(logo, height: 60, width: 60),
          ),
        ],
      ),
    );
  }

// Summary Section
  pw.Widget _buildSummarySection(
    double totalAmount,
    double totalExpense,
    double balance,
    PdfColor primaryColor,
    PdfColor successColor,
    PdfColor warningColor,
    PdfColor errorColor,
    PdfColor successLight,
    PdfColor warningLight,
    PdfColor errorLight,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      children: [
        _buildSummaryCard(
          'Total Income',
          '₹${totalAmount.toStringAsFixed(2)}',
          successColor,
          successLight,
          '💰',
        ),
        _buildSummaryCard(
          'Total Expenses',
          '₹${totalExpense.toStringAsFixed(2)}',
          warningColor,
          warningLight,
          '💸',
        ),
        _buildSummaryCard(
          'Balance',
          '₹${balance.toStringAsFixed(2)}',
          balance >= 0 ? successColor : errorColor,
          balance >= 0 ? successLight : errorLight,
          '💼',
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCard(String title, String amount, PdfColor color,
      PdfColor lightColor, String emoji) {
    return pw.Expanded(
      child: pw.Container(
        margin: pw.EdgeInsets.symmetric(horizontal: 8),
        padding: pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: lightColor,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: color, width: 0.5),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                emoji,
                style: pw.TextStyle(fontSize: 16),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#6B7280'),
              ),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              amount,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

// Income Section
  pw.Widget _buildIncomeSection(
    List<IncomeModel> incomeModel,
    Map<String, dynamic> allUsers,
    PdfColor primaryColor,
    PdfColor lightGray,
    PdfColor primaryLight,
  ) {
    const rowsPerTable = 25; // adjust based on font size

    // Split data into smaller chunks
    List<List<IncomeModel>> chunks = [];
    for (var i = 0; i < incomeModel.length; i += rowsPerTable) {
      chunks.add(incomeModel.sublist(
        i,
        i + rowsPerTable > incomeModel.length
            ? incomeModel.length
            : i + rowsPerTable,
      ));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: primaryLight,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            '💰 INCOME DETAILS (${incomeModel.length} entries)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
        pw.SizedBox(height: 12),

        // Create a table for each chunk
        for (var chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) ...[
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: lightGray, width: 1),
              verticalInside: pw.BorderSide(color: lightGray, width: 1),
              top: pw.BorderSide(color: primaryColor, width: 2),
              bottom: pw.BorderSide(color: primaryColor, width: 1),
              left: pw.BorderSide(color: primaryColor, width: 1),
              right: pw.BorderSide(color: primaryColor, width: 1),
            ),
            columnWidths: {
              0: pw.FixedColumnWidth(40),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: primaryColor),
                children: [
                  _buildTableHeader('#'),
                  _buildTableHeader('Contributor'),
                  _buildTableHeader('Amount'),
                ],
              ),
              // Data rows
              ...chunks[chunkIndex].asMap().entries.map((entry) {
                int index = entry.key + (chunkIndex * rowsPerTable);
                IncomeModel income = entry.value;
                bool isEven = index % 2 == 0;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : lightGray,
                  ),
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(
                        allUsers[income.user] ?? income.username ?? 'Unknown'),
                    _buildTableCell(
                      income.amount?.toStringAsFixed(2) ?? '0.00',
                      isAmount: true,
                    ),
                  ],
                );
              }),
            ],
          ),
          if (chunkIndex != chunks.length - 1) pw.SizedBox(height: 20),
        ],
      ],
    );
  }

// Expense Section
  pw.Widget _buildExpenseSection(
    List<ExpenseModel> expenseModel,
    PdfColor secondaryColor,
    PdfColor lightGray,
    PdfColor secondaryLight,
  ) {
    const rowsPerTable = 25; // adjust if you want more/less per page

    // Split into smaller chunks
    List<List<ExpenseModel>> chunks = [];
    for (var i = 0; i < expenseModel.length; i += rowsPerTable) {
      chunks.add(expenseModel.sublist(
        i,
        i + rowsPerTable > expenseModel.length
            ? expenseModel.length
            : i + rowsPerTable,
      ));
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: secondaryLight,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            '💸 EXPENSE DETAILS (${expenseModel.length} entries)',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: secondaryColor,
            ),
          ),
        ),
        pw.SizedBox(height: 12),

        // Create a table for each chunk
        for (var chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) ...[
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: lightGray, width: 1),
              verticalInside: pw.BorderSide(color: lightGray, width: 1),
              top: pw.BorderSide(color: secondaryColor, width: 2),
              bottom: pw.BorderSide(color: secondaryColor, width: 1),
              left: pw.BorderSide(color: secondaryColor, width: 1),
              right: pw.BorderSide(color: secondaryColor, width: 1),
            ),
            columnWidths: {
              0: pw.FixedColumnWidth(40),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: secondaryColor),
                children: [
                  _buildTableHeader('#'),
                  _buildTableHeader('Expense Item'),
                  _buildTableHeader('Amount (₹)'),
                ],
              ),
              // Data rows
              ...chunks[chunkIndex].asMap().entries.map((entry) {
                int index = entry.key + (chunkIndex * rowsPerTable);
                ExpenseModel expense = entry.value;
                bool isEven = index % 2 == 0;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : lightGray,
                  ),
                  children: [
                    _buildTableCell('${index + 1}'),
                    _buildTableCell(expense.expense ?? 'Unknown Expense'),
                    _buildTableCell(
                      expense.amount?.toStringAsFixed(2) ?? '0.00',
                      isAmount: true,
                    ),
                  ],
                );
              }),
            ],
          ),
          if (chunkIndex != chunks.length - 1) pw.SizedBox(height: 20),
        ],
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isAmount = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isAmount ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isAmount
              ? PdfColor.fromHex('#059669')
              : PdfColor.fromHex('#374151'),
        ),
        textAlign: isAmount ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

// Footer Section
  pw.Widget _buildFooter(PdfColor darkGray) {
    final now = DateTime.now();
    final formattedDate =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F9FAFB'),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB'), width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Generated on: $formattedDate',
                style: pw.TextStyle(fontSize: 9, color: darkGray),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'This is a computer-generated report.',
                style: pw.TextStyle(fontSize: 8, color: darkGray),
              ),
            ],
          ),
          pw.Container(
            padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#6366F1'),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'UNITED AREECHOLA',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#6366F1'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<IncomeModel>> getIncome({required String eventId}) async {
    try {
      final eventIncomeSnap = await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .get();
      if (eventIncomeSnap.docs.isNotEmpty) {
        return eventIncomeSnap.docs
            .map((income) => IncomeModel.fromJson(income.data()))
            .toList();
      } else {
        throw Exception("no transactions found");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

Future<List<ExpenseModel>>? getExpense(
    {required String eventId, required BuildContext ctx}) async {
  try {
    final eventexpenseSnap = await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("expense")
        .get();
    if (eventexpenseSnap.docs.isNotEmpty) {
      return eventexpenseSnap.docs
          .map((income) => ExpenseModel.fromJson(income.data()))
          .toList();
    } else {
      showSnackBar(ctx, "No Expense found");
      throw Exception("no expense found");
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<Map<String, String>> getAllUsers() async {
  Map<String, String> userMap = {};
  try {
    final userSnap = await FirebaseFirestore.instance.collection("users").get();
    for (var userDoc in userSnap.docs) {
      userMap[userDoc.id] = userDoc.data()['name'];
    }
    return userMap;
  } catch (e) {
    throw Exception("Error fetching users: ${e.toString()}");
  }
}

class IncomeModel {
  String? user;
  double? amount;
  String? username;

  IncomeModel({this.user, this.amount, this.username});

  factory IncomeModel.fromJson(Map<String, dynamic> data) {
    return IncomeModel(
        username: data['username'],
        user: data['userId'] ?? "",
        amount: data['amount']?.toDouble());
  }
}

class ExpenseModel {
  String? expense;
  double? amount;

  ExpenseModel({this.expense, this.amount});

  factory ExpenseModel.fromJson(Map<String, dynamic> data) {
    return ExpenseModel(
        expense: data['expenseName'] ?? "",
        amount: data['expenseAmount']?.toDouble());
  }
}
