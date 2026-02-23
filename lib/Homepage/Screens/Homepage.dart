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
import 'package:united_areechola/constants.dart';
import 'package:united_areechola/events/screens/addevents.dart';
import 'package:united_areechola/kuri/screens/kuri_homescreen.dart';
import 'package:united_areechola/subcriptions/screens/add_subcription.dart';
import 'package:united_areechola/subcriptions/screens/report.dart';

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
  int _selectedIndex = 0;

  final List<NavigationItem> _mobileNavItems = [
    NavigationItem(
      icon: Icon(Icons.grid_view_rounded), // Updated for Dashboard
      label: 'Dashboard',
      color: Color(0xFF3B82F6),
    ),
    NavigationItem(
      icon: Image.asset(
        "assets/logo-removebg-preview.png",
        height: 30,
        width: 30,
      ),
      label: 'ASL',
      color: Color(0xFF06B6D4),
    ),
    NavigationItem(
      icon: Icon(Icons.card_membership_rounded), // Updated for Subscriptions
      label: 'Subscriptions',
      color: Color(0xFF8B5CF6),
    ),
    NavigationItem(
      icon: Icon(
        Icons.bloodtype_rounded, // Kept relevant
      ),
      label: 'Blood Groups',
      color: Color(0xFFDC2626),
    ),
    NavigationItem(
      icon: Icon(Icons.savings_rounded), // Updated for Kuri (Savings)
      label: 'Kuri',
      color: Color(0xFFF59E0B),
    ),
    NavigationItem(
      icon: Icon(Icons.calendar_month_rounded), // Updated for Events
      label: 'Events',
      color: Color(0xFFF59E0B),
    ),
  ];
  late TabController _tabController;
  bool currentUserPermission = true;

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void updateUserToken(UserDataModel user) async {
    try {
      String? token;

      // ✅ Fix: Check platform and provide VAPID key for Web
      if (kIsWeb) {
        token = await FirebaseMessaging.instance.getToken(
          vapidKey: "BJ8Wclfm-WkXbyrKUJrmW-sX5f56Fu6YQyoQD9vvEuyHBz-GFqPE5TW6li67Gp4fkP69CTNBHNJOMT4lgvgkKRg", // <--- Paste your key here
        );
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }

      // Guard against null token
      if (token == null) return;

      // Update if token is new or empty
      if ((user.token ?? "").isEmpty || user.token != token) {
        await FirebaseFirestore.instance
            .collection(FirebaseContants
                .members) // Ensure this matches "Members" in your Cloud Function
            .doc(user.id)
            .update({"token": token});

        print("Token updated for user: ${user.id}");
      }
    } on FirebaseException catch (e) {
      debugPrint("Error updating token: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(vsync: this, length: kIsWeb ? 8 : 6, initialIndex: 0);

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
                        SubscriptionReportPage(),
                        //! Events
                        AddEventsScreen(),

                        //!Asl admin
                        AslAdmin(),
                        //! ASL
                        Asl(),
                        KuriHomeScreen(),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return _buildMobileLayout();
              // Scaffold(
              //   body: TabBarView(
              //     physics: const NeverScrollableScrollPhysics(),
              //     controller: _tabController,
              //     children: const [
              //       Dashboard(),
              //       Asl(),
              //       // CommittieScreen(),
              //       AddSubcription(),
              //       BloodGroups(),
              //       AddEvents(),
              //     ],
              //   ),
              //   bottomNavigationBar: BottomNavigationBar(
              //     selectedLabelStyle: const TextStyle(
              //       color: Colors.black,
              //       fontSize: 10,
              //       fontFamily: "PublicSans",
              //     ),
              //     unselectedItemColor: Colors.black,
              //     unselectedLabelStyle: const TextStyle(
              //         color: Colors.black,
              //         fontSize: 10,
              //         fontFamily: "PublicSans"),
              //     showUnselectedLabels: true,
              //     selectedItemColor: const Color.fromARGB(255, 52, 152, 9),
              //     currentIndex: _tabController.index,
              //     onTap: (index) {
              //       setState(() {
              //         _tabController.index = index;
              //       });
              //     },
              //     items: [
              //       BottomNavigationBarItem(
              //         icon: Icon(Icons.dashboard, size: 20),
              //         label: 'Dashboard',
              //       ),
              //       BottomNavigationBarItem(
              //         icon: SizedBox(
              //             width: 30,
              //             height: 25,
              //             child: Image.asset(ImageConstants.clubLogo)),
              //         label: 'Asl',
              //       ),
              //       // BottomNavigationBarItem(
              //       //   icon: Icon(Icons.group),
              //       //   label: 'Committie',
              //       // ),
              //       BottomNavigationBarItem(
              //         icon: Icon(
              //           Icons.subscriptions,
              //           size: 20,
              //         ),
              //         label: 'Subscriptions',
              //       ),
              //       BottomNavigationBarItem(
              //         icon: Icon(Icons.bloodtype_rounded, size: 20),
              //         label: 'BloodGroups',
              //       ),
              //       BottomNavigationBarItem(
              //         icon: Icon(Icons.event, size: 20),
              //         label: 'Events',
              //       ),
              //     ],
              //   ),
              // );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: const [
            Dashboard(),
            Asl(),
            AddSubcription(),
            BloodGroups(),
            KuriHomeScreen(),
            AddEventsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _mobileNavItems.length,
              (index) {
                final item = _mobileNavItems[index];
                final isSelected = _selectedIndex == index;

                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 200),
                  tween: Tween<double>(
                    begin: 0.0,
                    end: isSelected ? 1.0 : 0.0,
                  ),
                  builder: (context, double value, child) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          _tabController.index = index;
                        });
                      },
                      child: Container(
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.transparent,
                            item.color.withOpacity(0.1),
                            value,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  Colors.transparent,
                                  item.color.withOpacity(0.2),
                                  value,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: item.icon,
                            ),
                            SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: Color.lerp(
                                  Colors.grey,
                                  item.color,
                                  value,
                                ),
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final Widget icon;
  final String label;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
