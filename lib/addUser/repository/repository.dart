import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/usermodel.dart';

final adduserRepositoryProvider = Provider((ref) => AddUserRepository());

class AddUserRepository {
  Future<void> addUser(Usermodel usermodel) async {
    try {
      final doc = FirebaseFirestore.instance.collection("subcriptionMembers").doc();
      usermodel.id = doc.id;
      FirebaseFirestore.instance
          .collection("subcriptionMembers")
          .doc(doc.id)
          .set(usermodel.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Usermodel>> getUsers({required String seach}) {
    Query query =
        FirebaseFirestore.instance.collection("subcriptionMembers");

    if (seach.isNotEmpty) {
      query = query.where("search", arrayContains: seach.toUpperCase());
    }

    return query
        .where("delete", isEqualTo: false)
        .orderBy("createdDate", descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) {
              return Usermodel.fromMap(e.data() as Map<String, dynamic>);
            }).toList());
  }
}
