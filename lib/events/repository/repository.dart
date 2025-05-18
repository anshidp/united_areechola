import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class EventRepository implements EventsRepositories {
  @override
  Future<void> addEvents(EventModel eventModel) async {
    try {
      final doc = FirebaseFirestore.instance.collection("events").doc();
      eventModel.eventId = doc.id;
      doc.set(eventModel.toMap());
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
      print(e);
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
      print(e);
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
      doc.set(eventTransactionModel.toMap());
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .update({
        "users": FieldValue.arrayUnion([eventTransactionModel.userId]),
        "totalIncome": FieldValue.increment(eventTransactionModel.amount ?? 0),
      });
    } catch (error) {
      print(error);
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
      doc.set(eventExpenseModel.toMap());
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .update({
        "totalexpense": FieldValue.increment(eventExpenseModel.amount ?? 0),
      });
    } catch (error) {
      print(error);
    }
  }
}
