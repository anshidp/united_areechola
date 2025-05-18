import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:united_areechola/Homepage/Dashboad/screen/dashboad.dart';
import 'package:united_areechola/Homepage/widgets/sidemenu.dart';
import 'package:united_areechola/Models/userdatamodel.dart';
import 'package:united_areechola/addUser/adduser.dart';
import 'package:united_areechola/asl/screens/asl.dart';
import 'package:united_areechola/asl_admin/screens/asl_admin.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/bloodGroups/screens/bloodgroup.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/screens/addevents.dart';
import 'package:united_areechola/subcriptions/screens/add_subcription.dart';

/// ERP VERSIONS
String webVersion = "1.3.7";

///

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool currentUserPermission = true;

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void updateUserToken(UserDataModel user) async {
    try {
      String token = await FirebaseMessaging.instance.getToken() ?? "";
      if ((user.token ?? "").isEmpty || user.token != token) {
        await FirebaseFirestore.instance
            .collection(FirebaseContants.members)
            .doc(user.id)
            .update({"token": token});
        print("token updated success");
      }
    } on FirebaseException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(vsync: this, length: kIsWeb ? 6 : 5, initialIndex: 0);

    updateUserToken(userDataModel!);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool back = await myalert(context, "Do you want to quit?");

        return back;
      },
      child: Scaffold(
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.isDesktop) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SideMenu(tabController: _tabController),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: const [
                        //!Dashboad
                        Dashboard(),

                        //! Add users
                        AddUsers(),
                        //! subcription
                        AddSubcription(),
                        //! Events
                        AddEvents(),

                        //!Asl admin
                        AslAdmin(),
                        //! ASL
                        Asl(),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Scaffold(
                body: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: const [
                    Dashboard(),
                    Asl(),
                    // CommittieScreen(),
                    AddSubcription(),
                    BloodGroups(),
                    AddEvents(),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
                  selectedLabelStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: "PublicSans",
                  ),
                  unselectedItemColor: Colors.black,
                  unselectedLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: "PublicSans"),
                  showUnselectedLabels: true,
                  selectedItemColor: const Color.fromARGB(255, 52, 152, 9),
                  currentIndex: _tabController.index,
                  onTap: (index) {
                    setState(() {
                      _tabController.index = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard, size: 20),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: 30,
                          height: 25,
                          child: Image.asset(ImageConstants.clubLogo)),
                      label: 'Asl',
                    ),
                    // BottomNavigationBarItem(
                    //   icon: Icon(Icons.group),
                    //   label: 'Committie',
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.subscriptions,
                        size: 20,
                      ),
                      label: 'Subscriptions',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bloodtype_rounded, size: 20),
                      label: 'BloodGroups',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.event, size: 20),
                      label: 'Events',
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
