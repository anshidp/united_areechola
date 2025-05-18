// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:united_areechola/constants.dart';

class Transactionpdf {
  void downloadPdf(
      {required String eventId,
      required String eventName,
      required BuildContext ctx}) async {
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
            .map((income) => (income.amount ?? 0))
            .reduce((a, b) => a + b);
        balance = totalAmount - totalExpense;
      }

      final pdf = pw.Document();
      final imageLogo = pw.MemoryImage(imageData);
      List<pw.TableRow> generateTableRows(List<IncomeModel> incomeModel,
          List<ExpenseModel>? expenseModel, Map<String, dynamic> allUsers) {
        List<pw.TableRow> tableRows = [];

        // Header Row
        tableRows.add(
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.blue200),
            children: [
              pw.Text("No",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.Text("Income",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.Text("Amount",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              if (expenseModel != null)
                pw.Text("Expense",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white)),
              pw.Text("Amount",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ],
          ),
        );

        // Data Rows
        for (int i = 0;
            i <
                (incomeModel.length > (expenseModel?.length ?? 0)
                    ? incomeModel.length
                    : (expenseModel?.length ?? 0));
            i++) {
          tableRows.add(pw.TableRow(children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(3),
              child: pw.Text("${i + 1}"),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(3),
              child: pw.Text(i < incomeModel.length
                  ? allUsers[incomeModel[i].user] ??
                      incomeModel[i].username ??
                      ""
                  : ""),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(3),
              child: pw.Text(i < incomeModel.length
                  ? incomeModel[i].amount.toString()
                  : ""),
            ),
            if (expenseModel != null)
              pw.Padding(
                padding: pw.EdgeInsets.all(3),
                child: pw.Text(i < expenseModel.length
                    ? (expenseModel[i].expense ?? "")
                    : ""),
              ),
            if (expenseModel != null)
              pw.Padding(
                padding: pw.EdgeInsets.all(3),
                child: pw.Text(i < expenseModel.length
                    ? (expenseModel[i].amount ?? 0).toString()
                    : ""),
              ),
          ]));
        }

        return tableRows;
      }

      pdf.addPage(pw.MultiPage(
        build: (context) => [
          pw.Row(children: [
            pw.Image(imageLogo, height: 120),
            pw.Padding(padding: pw.EdgeInsets.only(left: 10)),
            pw.Text("UNITED AREECHOLA",
                style: pw.TextStyle(fontBold: pw.Font.symbol(), fontSize: 25)),
          ]),
          pw.Padding(padding: pw.EdgeInsets.only(top: 20)),
          pw.Table(
            columnWidths: {
              0: pw.FlexColumnWidth(0.5),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(1),
            },
            border: pw.TableBorder.all(),
            children: generateTableRows(incomeModel, expenseModel, allUsers),
          ),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Total Income: $totalAmount"),
                  pw.SizedBox(height: 10),
                  pw.Text("Total Expense: $totalExpense"),
                  pw.SizedBox(height: 10),
                  pw.Text("Balance: $balance"),
                ])
          ])
        ],
      ));

      await Printing.layoutPdf(
        name: eventName,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print(e.toString());
    }
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
