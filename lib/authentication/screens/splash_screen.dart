import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/Homepage/Screens/Homepage.dart';
import 'package:united_areechola/Models/userdatamodel.dart';
import 'package:united_areechola/authentication/screens/login.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';

UserDataModel? userDataModel;
bool isAdmin = false;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void getSubcriptionAmount() async {
    final data = await db.collection('settings').doc('settings').get();
    if (data.exists && mounted) {
      setState(() {
        subcriptionAmount = data['subcriptionamount'].toDouble() ?? 0;
      });
    }
  }

  checkUser() async {
    try {
      Future.delayed(const Duration(seconds: 2)).then((value) async {
        SharedPreferences perfs = await SharedPreferences.getInstance();
        if (perfs.containsKey("id")) {
          final key = perfs.getString("id");
          FirebaseFirestore.instance
              .collection(FirebaseContants.members)
              .doc(key)
              .snapshots()
              .listen((event) {
            if (event.exists) {
              if (mounted) {
                setState(() {
                  userDataModel = UserDataModel.fromMap(event.data()!);
                  isAdmin = userDataModel?.role == "admin";
                });
              }
            }
            
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false);
            }
          });
        } else {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false);
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    checkUser();
    getSubcriptionAmount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    scrwidth = MediaQuery.of(context).size.width;
    scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 500,
              height: 300,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/logo-removebg-preview.png"))),
            )
          ],
        ),
      ),
    );
  }
}
