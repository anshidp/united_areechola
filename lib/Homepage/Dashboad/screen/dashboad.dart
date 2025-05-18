import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:united_areechola/Homepage/Dashboad/widgets/dashboad_items.dart';
import 'package:united_areechola/Homepage/chart/dashboard_chart.dart';
import 'package:united_areechola/authentication/repository/repository.dart';
import 'package:united_areechola/authentication/screens/login.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/constants.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  List icons = [
    Icon(
      Icons.person,
      color: Colors.green,
    ),
    Icon(
      Icons.calendar_month,
      color: Colors.blue,
    ),
    Icon(
      Icons.account_balance_wallet,
      color: Colors.blue,
    )
  ];
  int totalUsers = 0;
  int totalevents = 0;
  double totalsubcriptionIncome = 0;
  getTotalData() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .count()
          .get()
          .then((value) {
        setState(() {
          totalUsers = (value.count ?? 0);
        });
      });
      await FirebaseFirestore.instance
          .collection("transactions")
          .where("delete", isEqualTo: false)
          .get()
          .then((value) {
        setState(() {
          for (var i in value.docs) {
            totalsubcriptionIncome += i["amount"] ?? 0;
          }
        });
      });
      await FirebaseFirestore.instance
          .collection("events")
          .where("delete", isEqualTo: false)
          .count()
          .get()
          .then((value) {
        setState(() {
          totalevents = value.count ?? 0;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    getTotalData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: scrHeight * 0.07,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Hi, ${userDataModel?.role.toUpperCase()}",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20)),
                    GestureDetector(
                        onTap: () async {
                          bool logout =
                              await myalert(context, "Do you want logout?");
                          if (logout) {
                            ref.read(authrepositoryprovider).logOutgoogle();

                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            }
                          }
                        },
                        child: const Icon(Icons.logout))
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 30)),
              LayoutBuilder(builder: (context, size) {
                return SizedBox(
                  width: double.infinity,
                  // height: 70,
                  child: GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: 3,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: size.maxWidth > 600 ? 2 : 1.3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 2,
                          crossAxisCount: 3),
                      itemBuilder: (ctx, index) {
                        return DashboadItems(
                            icon: icons[index],
                            index: index,
                            title: index == 0
                                ? "TOTAL USERS"
                                : index == 1
                                    ? "TOTAL EVENTS"
                                    : "INCOME",
                            count: index == 0
                                ? totalUsers
                                : index == 1
                                    ? totalevents
                                    : totalsubcriptionIncome.toDouble());
                      }),
                );
              }),
              SizedBox(
                  width: scrWidth,
                  height: scrWidth > 600 ? scrHeight * 0.6 : scrHeight * 0.65,
                  child: DashboardChart(
                    totalEventIncome: totalsubcriptionIncome,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
