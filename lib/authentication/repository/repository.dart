import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/Models/userdatamodel.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';

final authrepositoryprovider = Provider((ref) => Authrepository());

class Authrepository {
  Future<bool> checklogin({
    required String email,
    required String password,
  }) async {
    try {
      final data = await FirebaseFirestore.instance
          .collection("admin")
          .where(
            "email",
            isEqualTo: email,
          )
          .where("password", isEqualTo: password)
          .get();

      return data.docs.isNotEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //google signIn

  Future<UserDataModel?> googlesignIn(BuildContext context) async {
    try {
      UserCredential userCredential;
      final GoogleSignInAccount? googleaccount = await GoogleSignIn().signIn();
      final googleAuth = await googleaccount?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final email = userCredential.user?.email;
      final usersnapshot = await FirebaseFirestore.instance
          .collection("Members")
          .where("email", isEqualTo: email)
          .get();
      UserDataModel? userDataModel;
      if (usersnapshot.docs.isNotEmpty) {
        userDataModel = UserDataModel.fromMap(usersnapshot.docs.first.data());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("id", userDataModel.id ?? "");
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false);
        }
        return userDataModel;
      } else {
        final doc = FirebaseFirestore.instance.collection("Members").doc();
        UserDataModel dataModel = UserDataModel(
            email: userCredential.user?.email ?? "",
            password: "",
            role: "user");
        dataModel.id = doc.id;
        doc.set(dataModel.toMap());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("id", dataModel.id ?? "");
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false);
        }
      }
    } on FirebaseException catch (e, s) {
      print("error: ${s.toString()}");
      print(e.message);
    } catch (e, s) {
      print(e.toString());
      print("error: ${s.toString()}");
    }
    return null;
  }

  Future<UserDataModel?> signWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final usersnap = await FirebaseFirestore.instance
          .collection("Members")
          .where("email", isEqualTo: email)
          .where("password", isEqualTo: password)
          .get();
      if (usersnap.docs.isNotEmpty) {
        return UserDataModel.fromMap(usersnap.docs.first.data());
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // logout
  logOutgoogle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    prefs.remove("id");
  }
}
