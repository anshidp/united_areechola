import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Models/kuri_group.dart';
import 'package:united_areechola/Models/kuri_member.dart';
import 'package:united_areechola/constants.dart';

final kurirepositoryProvider = Provider(
  (ref) => KuriRepository(),
);

class KuriRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> createKuriGroup(KuriGroup group) async {
    final docRef = _firestore.collection(FirebaseContants.kuriGroups).doc();
    group.id = docRef.id;
    docRef.set(group.toJson());
  }

  Future<void> addMember(KuriMember member, String groupId) async {
    final membersDoc = _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .collection(FirebaseContants.members)
        .doc();
    member.id = membersDoc.id;
    membersDoc.set(member.toJson());
    await _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayUnion([member.id])
    });
  }

  Future<KuriMember> getLastWinner({required String groupId}) async {
    final lastwinner = await _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .collection(FirebaseContants.members)
        .where("wonMonth", isEqualTo: 0)
        .limit(1)
        .get();
    return KuriMember.fromJson(lastwinner.docs.first.data());
  }

  Stream<List<KuriMember>> getMembers(String groupId) {
    return _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .collection(FirebaseContants.members)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KuriMember.fromJson(doc.data()))
            .toList());
  }

  Stream<KuriGroup?> getKuriGroup(String groupId) {
    return _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return KuriGroup.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  Future<void> updateWinner(String groupId, int month, String memberId) async {
    await _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .update({
      'monthlyWinners.$month': memberId,
      'currentMonth': month,
      'lastSpinDate': DateTime.now()
    });
    await _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .collection(FirebaseContants.members)
        .doc(memberId)
        .update({
      'wonMonth': month,
    });
  }

  bool isSpinAvailability(DateTime? lastSpinDate) {
    if (lastSpinDate == null) return true;
    final today = DateTime.now();

    final isNextMonth =
        today.year > lastSpinDate.year || today.month > lastSpinDate.month;

    return isNextMonth;
  }

  Future<List<KuriMember>> getEligibleMembers(String groupId) async {
    final membersSnapshot = await _firestore
        .collection(FirebaseContants.kuriGroups)
        .doc(groupId)
        .collection(FirebaseContants.members)
        .where("wonMonth", isEqualTo: 0)
        .get();

    return membersSnapshot.docs
        .map((doc) => KuriMember.fromJson(doc.data()))
        .toList();
  }
}
