import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/subcription_model.dart';
import 'package:united_areechola/constants.dart';

abstract class SubcriptionRepositoryClass {
  Future<void> addsubcription({required SubcriptionModel subcriptionModel});
}

final subcriptionrepositoryprovider =
    Provider((ref) => SubcriptionRepository());

class SubcriptionRepository implements SubcriptionRepositoryClass {
  @override
  Future<void> addsubcription(
      {required SubcriptionModel subcriptionModel}) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection(FirebaseContants.transactions)
          .doc();
      subcriptionModel.id = doc.id;
      doc.set(subcriptionModel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Stream<List<SubcriptionModel>> getSubcriptionTransactions(
      {required String selectedMonth}) {
    try {
      DateTime selectedDate = DateFormat('yyyy-MM').parse(selectedMonth);
      DateTime firstDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month, 1);
      DateTime lastDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month + 1, 0);

      return FirebaseFirestore.instance
          .collection(FirebaseContants.transactions)
          .where('expireDate', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where("delete", isEqualTo: false)
          .snapshots()
          .map((event) {
        return event.docs
            .map((e) => SubcriptionModel.fromMap(e.data()))
            .where((subscription) {
          DateTime startDate = subscription.startDate!;
          DateTime expiredate = subscription.expireDate!;
          return startDate.isBefore(lastDayOfMonth) &&
              expiredate.isAfter(firstDayOfMonth);
        }).toList();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, double>> getEachMonthsubcriptionAmount(
      {required String selectMonth}) async {
    try {
      Map<String, double> subcriptionamount = {};
      DateTime selectedDate = DateFormat("yyyy-MM").parse(selectMonth);
      DateTime firstDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month, 1);
      DateTime lastDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month + 1, 0);
      var transaction =
          FirebaseFirestore.instance.collection(FirebaseContants.transactions);
      var thismonthTotal = await (transaction
              .where('expireDate', isGreaterThanOrEqualTo: firstDayOfMonth)
              .where("delete", isEqualTo: false)
              .get())
          .then((value) {
        // var data = value.docs.length * 50;
        var data = value.docs.where((element) {
          DateTime startDate = element['startDate'].toDate()!;
          DateTime expiredate = element["expireDate"].toDate()!;
          return startDate.isBefore(lastDayOfMonth) &&
              expiredate.isAfter(firstDayOfMonth);
        }).toList();
        // return data.fold(
        //     0.0, (previousValue, element) => previousValue + element['amount']);
        return data.length*50;
      });
      var totalamount = await (transaction
          .where("delete", isEqualTo: false)
          .get()
          .then((value) =>
              value.docs.fold(0.0, (data, doc) => data + doc["amount"])));
      subcriptionamount["thisMonth"] = thismonthTotal.toDouble();
      subcriptionamount["total"] = totalamount;
      return subcriptionamount;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<List<String>> getunpaidUsers(String selectedMonth) async {
    DateTime selectedDate = DateFormat('yyyy-MM').parse(selectedMonth);
    DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    var usersnapshot =
        await FirebaseFirestore.instance.collection("subcriptionMembers").get();
    var allUsers = usersnapshot.docs
        .map((user) => {"id": user.id, "name": user["name"]})
        .toList();
    var transactionsSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseContants.transactions)
        .where('expireDate', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('delete', isEqualTo: false)
        .get();
    var filteredTransactions = transactionsSnapshot.docs.where((doc) {
      DateTime startDate = doc['startDate'].toDate();
      DateTime expireDate = doc['expireDate'].toDate();
      return startDate.isBefore(lastDayOfMonth) &&
          expireDate.isAfter(firstDayOfMonth);
    }).toList();

    var paidUsers =
        filteredTransactions.map((e) => e['userId'] as String).toSet();

    var unpaidUsernames = allUsers
        .where((user) => !paidUsers.contains(user['id']))
        .map((e) => e['name'] as String)
        .toList();

    return unpaidUsernames;
  }
}
