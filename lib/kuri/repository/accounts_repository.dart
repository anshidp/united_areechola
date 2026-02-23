import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:united_areechola/kuri/models/transaction_model.dart';
import 'package:united_areechola/common/common.dart';

class AccountsRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('accounts');

  // Add Transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _collection.doc(transaction.id).set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Stream All Transactions (Ordered by Date)
  Stream<List<TransactionModel>> getTransactions() {
    return _collection.orderBy('date', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Delete Transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
