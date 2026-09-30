import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/event_expense_model.dart';
import 'package:united_areechola/Models/event_transaction_model.dart';
import 'package:united_areechola/Models/eventmodel.dart';

abstract class EventsRepositories {
  Future<void> addEvents(EventModel eventModel);
  Stream<List<EventModel>> getEvents();
  Stream<List<EventTransactionModel>> getEventTransactions(
      {required String eventId, required String search});
  Future<void> addEventsTransaction(
      {required EventTransactionModel eventTransactionModel,
      required String eventId});
  Future<void> addEventsExpense(
      {required EventExpenseModel eventExpenseModel, required String eventId});
  Stream<List<EventExpenseModel>> getEventExpenses({required String eventId});
}

final eventrepositoryProvider = Provider((ref) => EventRepository());

// Get total events
final eventsdatastream =
    StreamProvider((ref) => ref.read(eventrepositoryProvider).getEvents());
// Get Event transactions
final eventTransactionStream =
    StreamProvider.family<List<EventTransactionModel>, String>((ref, data) {
  Map a = jsonDecode(data);
  return ref
      .read(eventrepositoryProvider)
      .getEventTransactions(eventId: a["eventId"], search: a["search"]);
});

// Get Event expenses
final eventExpenseStream =
    StreamProvider.family<List<EventExpenseModel>, String>((ref, eventId) =>
        ref.read(eventrepositoryProvider).getEventExpenses(eventId: eventId));

Future<void> syncEventTotals(String eventId) async {
  if (eventId.isEmpty) return;
  try {
    // 1. Total income = sum of Transactions.amount where delete != true
    final transSnap = await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("Transactions")
        .get();

    double totalIncome = 0;
    for (var doc in transSnap.docs) {
      final data = doc.data();
      if (data["delete"] == true) continue;
      final rawAmount = data["amount"];
      if (rawAmount != null) {
        totalIncome += (rawAmount as num).toDouble();
      }
    }

    // 2. Total expense = sum of expense.expenseAmount where delete != true
    final expSnap = await FirebaseFirestore.instance
        .collection("events")
        .doc(eventId)
        .collection("expense")
        .get();

    double totalExpense = 0;
    for (var doc in expSnap.docs) {
      final data = doc.data();
      if (data["delete"] == true) continue;
      final rawExp = data["expenseAmount"];
      if (rawExp != null) {
        totalExpense += (rawExp as num).toDouble();
      }
    }

    // 3. Update event document with exact sums
    await FirebaseFirestore.instance.collection("events").doc(eventId).update({
      "totalIncome": totalIncome,
      "totalexpense": totalExpense,
      "balance": totalIncome - totalExpense,
    });
  } catch (e) {
    debugPrint("Error syncing event totals: $e");
  }
}

class EventRepository implements EventsRepositories {
  @override
  Future<void> addEvents(EventModel eventModel) async {
    try {
      final doc = FirebaseFirestore.instance.collection("events").doc();
      eventModel.eventId = doc.id;
      await doc.set(eventModel.toMap());
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Stream<List<EventModel>> getEvents() {
    return FirebaseFirestore.instance
        .collection("events")
        .where("delete", isEqualTo: false)
        .orderBy("createdDate", descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => EventModel.fromMap(e.data())).toList());
  }

  @override
  Stream<List<EventTransactionModel>> getEventTransactions(
      {required String eventId, required String search}) {
    try {
      return FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .where("search",
              arrayContains: search.isEmpty ? null : search.toUpperCase())
          .where("delete", isEqualTo: false)
          .orderBy("createdDate", descending: true)
          .snapshots()
          .map((event) => event.docs
              .map((e) => EventTransactionModel.fromMap(e.data()))
              .toList());
    } catch (e) {
      debugPrint(e.toString());
    }
    throw UnimplementedError();
  }

  @override
  Stream<List<EventExpenseModel>> getEventExpenses({required String eventId}) {
    try {
      return FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("expense")
          .snapshots()
          .map((event) => event.docs
              .map((e) => EventExpenseModel.fromMap(e.data()))
              .toList());
    } catch (e) {
      debugPrint(e.toString());
    }
    throw UnimplementedError();
  }

  @override
  Future<void> addEventsTransaction(
      {required EventTransactionModel eventTransactionModel,
      required String eventId}) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("Transactions")
          .doc();
      eventTransactionModel.id = doc.id;
      await doc.set(eventTransactionModel.toMap());
      if (eventTransactionModel.userId != null &&
          eventTransactionModel.userId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("events")
            .doc(eventId)
            .update({
          "users": FieldValue.arrayUnion([eventTransactionModel.userId]),
        });
      }
      await syncEventTotals(eventId);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Future<void> addEventsExpense(
      {required EventExpenseModel eventExpenseModel,
      required String eventId}) async {
    try {
      final doc = FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("expense")
          .doc();
      eventExpenseModel.id = doc.id;
      await doc.set(eventExpenseModel.toMap());
      await syncEventTotals(eventId);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
