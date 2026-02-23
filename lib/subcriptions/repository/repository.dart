import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:united_areechola/Models/notification_model.dart';
import 'package:united_areechola/Models/subcription_model.dart';
import 'package:united_areechola/common/common.dart';
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

  Future<void> addBulkSubscription(
      {required List<SubcriptionModel> subscriptions}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance
          .collection(FirebaseContants.transactions);

      for (var sub in subscriptions) {
        final doc = collection.doc();
        sub.id = doc.id;
        batch.set(doc, sub.toMap());
      }

      await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
      throw e;
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
          .where("delete", isEqualTo: false)
          .where("startDate", isGreaterThanOrEqualTo: firstDayOfMonth)
          .where("startDate", isLessThan: lastDayOfMonth)
          .snapshots()
          .map((event) {
        return event.docs
            .map((e) => SubcriptionModel.fromMap(e.data()))
            .toList();
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool?> isAlreadyPaid(
      {required String userId, required String paiddate}) async {
    try {
      DateTime selectedDate = DateFormat('yyyy-MM').parse(paiddate);
      final firstDayofMonth =
          DateTime(selectedDate.year, selectedDate.month, 1);
      final lastDayofMonth =
          DateTime(selectedDate.year, selectedDate.month + 1, 0);
      final userSnap = await db
          .collection(FirebaseContants.transactions)
          .where("delete", isEqualTo: false)
          .where("userId", isEqualTo: userId)
          .where("startDate", isGreaterThanOrEqualTo: firstDayofMonth)
          .where("startDate", isLessThan: lastDayofMonth)
          .get();
      return userSnap.docs.first.data().isNotEmpty;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<Map<String, double>> getEachMonthSubscriptionAmount({
    required String selectMonth,
  }) async {
    try {
      final Map<String, double> subscriptionAmount = {};

      // Parse the input month (e.g., "2025-03")
      DateTime selectedDate = DateFormat("yyyy-MM").parse(selectMonth);
      DateTime firstDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month, 1);
      DateTime firstDayOfNextMonth =
          DateTime(selectedDate.year, selectedDate.month + 1, 1);

      final transactionRef =
          FirebaseFirestore.instance.collection(FirebaseContants.transactions);

      // Get all non-deleted transactions
      final snapshot =
          await transactionRef.where("delete", isEqualTo: false).get();

      // Calculate total amount (all time)
      final totalAmount = snapshot.docs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc['amount'] as num).toDouble(),
      );

      // Filter transactions whose `startDate` is within the selected month
      final thisMonthDocs = snapshot.docs.where((doc) {
        final DateTime startDate = doc['startDate'].toDate();
        return startDate.isAfter(
                firstDayOfMonth.subtract(const Duration(seconds: 1))) &&
            startDate.isBefore(firstDayOfNextMonth);
      });

      // Sum amounts for this month
      final thisMonthAmount = thisMonthDocs.fold<double>(
        0.0,
        (sum, doc) => sum + (doc['amount'] as num).toDouble(),
      );

      // Prepare result map
      subscriptionAmount['thisMonth'] = thisMonthAmount;
      subscriptionAmount['total'] = totalAmount;

      return subscriptionAmount;
    } catch (e) {
      throw Exception("Error in getEachMonthSubscriptionAmount: $e");
    }
  }

  Future<List<String>> getUnpaidUsers(String selectedMonth) async {
    try {
      // Parse selected month (e.g., "2025-03")
      DateTime selectedDate = DateFormat('yyyy-MM').parse(selectedMonth);
      DateTime firstDayOfMonth =
          DateTime(selectedDate.year, selectedDate.month, 1);
      DateTime firstDayOfNextMonth =
          DateTime(selectedDate.year, selectedDate.month + 1, 1);

      // Get all users
      var usersSnapshot = await FirebaseFirestore.instance
          .collection("subcriptionMembers")
          .get();
      var allUsers = usersSnapshot.docs
          .map((user) => {"id": user.id, "name": user["name"]})
          .toList();

      // Get transactions where `startDate` is in the selected month
      var transactionsSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseContants.transactions)
          .where("delete", isEqualTo: false)
          .get();

      var filteredTransactions = transactionsSnapshot.docs.where((doc) {
        DateTime startDate = doc['startDate'].toDate();
        return startDate.isAfter(
                firstDayOfMonth.subtract(const Duration(seconds: 1))) &&
            startDate.isBefore(firstDayOfNextMonth);
      }).toList();

      // Get set of paid user IDs
      var paidUserIds =
          filteredTransactions.map((e) => e['userId'] as String).toSet();

      // Filter unpaid users
      var unpaidUsernames = allUsers
          .where((user) => !paidUserIds.contains(user['id']))
          .map((e) => e['name'] as String)
          .toList();

      return unpaidUsernames;
    } catch (e) {
      throw Exception("Error in getUnpaidUsers: $e");
    }
  }

  Future<void> sendNotificationAdmin(Map<String, dynamic> body) async {
    try {
      print("fum work");
      final uri = "https://sendnotificationtoall-w3gjiwvdqa-uc.a.run.app";
      final response = await http.post(Uri.parse(uri),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Notification sended success : ${response.body}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addNotificationData(NotificationModel notification) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection(FirebaseContants.notification)
          .doc();
      notification.id = doc.id;
      await doc.set(notification.toMap());
      print("document added successfull");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
