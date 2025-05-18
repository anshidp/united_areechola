import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/usermodel.dart';

final adduserRepositoryProvider = Provider((ref) => AddUserRepository());

class AddUserRepository {
  Future<void> addUser(Usermodel usermodel) async {
    try {
      final doc = FirebaseFirestore.instance.collection("users").doc();
      usermodel.id = doc.id;
      FirebaseFirestore.instance
          .collection("users")
          .doc(doc.id)
          .set(usermodel.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Usermodel>> getUsers({required String seach}) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("search",
            arrayContains: seach.isEmpty ? null : seach.toUpperCase())
        .where("delete", isEqualTo: false).orderBy("createdDate",descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) {
              return Usermodel.fromMap(e.data());
            }).toList());
  }
}
