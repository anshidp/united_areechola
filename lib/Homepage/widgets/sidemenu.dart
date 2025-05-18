import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/authentication/screens/login.dart';
import 'package:united_areechola/common/common.dart';

class SideMenu extends StatefulWidget {
  final TabController _tabController;

  const SideMenu({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  @override
  State<SideMenu> createState() => _SideMenuState();
}

int selectedTab = 0;
int subTab = 0;

class _SideMenuState extends State<SideMenu> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        // final admin = ref.watch(adminModelProvider);

        return Container(
          // color: const Color(0xff231F20),
          color: const Color(0xFFFAFAFA),
          width: 230,
          child: Theme(
            data: ThemeData(
              highlightColor: const Color(0xffF5F6F7),
            ),
            child: Scrollbar(
              controller: scrollController,
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        Container(
                          width: 600,
                          height: 200,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      "assets/logo-removebg-preview.png"))),
                        ),

                        ///Dashboard
                        Container(
                          margin: const EdgeInsets.all(7),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedTab == 0
                                ? const Color(0xff003F62)
                                : Colors.white,
                          ),
                          // color: Color(0xFF1a2226),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget._tabController.animateTo((0));
                                selectedTab = 0;
                                // subTab = 0;
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.dashboard,
                                  color: selectedTab == 0
                                      ? Colors.white
                                      : Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  "Dashboard",
                                  style: TextStyle(
                                    fontFamily: "PublicSans",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: selectedTab == 0
                                        ? Colors.white
                                        : Color(0xff626C71),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // Divider(
                        //   color: Colors.blueGrey.shade800,
                        // ),
                        // add users
                        Container(
                          margin: const EdgeInsets.all(7),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedTab == 1
                                ? const Color(0xff003F62)
                                : Colors.white,
                          ),
                          // color: Color(0xFF1a2226),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget._tabController.animateTo((1));
                                selectedTab = 1;
                                // subTab = 0;
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.person,
                                  color: selectedTab == 1
                                      ? Colors.white
                                      : Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  "Add Users",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectedTab == 1
                                        ? Colors.white
                                        : Color(0xff626C71),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Divider(
                        //   color: Colors.blueGrey.shade800,
                        // ),
                        Container(
                          margin: const EdgeInsets.all(7),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedTab == 2
                                ? const Color(0xff003F62)
                                : Colors.white,
                          ),
                          // color: Color(0xFF1a2226),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget._tabController.animateTo((2));
                                selectedTab = 2;
                                // subTab = 0;
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: selectedTab == 2
                                      ? Colors.white
                                      : Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  "Add Subcription",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectedTab == 2
                                        ? Colors.white
                                        : Color(0xff626C71),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // Divider(
                        //   color: Colors.blueGrey.shade800,
                        // ),
                        // Add events
                        Container(
                          margin: const EdgeInsets.all(7),
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedTab == 3
                                ? const Color(0xff003F62)
                                : Colors.white,
                          ),
                          // color: Color(0xFF1a2226),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget._tabController.animateTo((3));
                                selectedTab = 3;
                                // subTab = 0;
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.calendar_today_sharp,
                                  color: selectedTab == 3
                                      ? Colors.white
                                      : Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  "Add Events",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selectedTab == 3
                                        ? Colors.white
                                        : Color(0xff626C71),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(7),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: selectedTab == 4
                                  ? const Color(0xff003F62)
                                  : Colors.white,
                            ),
                            // color: Color(0xFF1a2226),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  widget._tabController.animateTo((4));
                                  selectedTab = 4;
                                  // subTab = 0;
                                });
                              },
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.calendar_today_sharp,
                                    color: selectedTab == 4
                                        ? Colors.white
                                        : Colors.black,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    "ASL ADMIN",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selectedTab == 4
                                          ? Colors.white
                                          : Color(0xff626C71),
                                    ),
                                  )
                                ],
                              ),
                            )),
                        Container(
                            margin: const EdgeInsets.all(7),
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: selectedTab == 5
                                  ? const Color(0xff003F62)
                                  : Colors.white,
                            ),
                            // color: Color(0xFF1a2226),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  widget._tabController.animateTo((5));
                                  selectedTab = 5;
                                  // subTab = 0;
                                });
                              },
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                      width: 30,
                                      height: 35,
                                      child:
                                          Image.asset(ImageConstants.clubLogo)),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    "ASL",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selectedTab == 5
                                          ? Colors.white
                                          : Color(0xff626C71),
                                    ),
                                  )
                                ],
                              ),
                            )),

                        // Divider(
                        //   color: Colors.blueGrey.shade800,
                        // ),

                        //LogOut
                        InkWell(
                          onTap: () {
                            setState(() {});
                            signOutUser();
                          },
                          child: CustomSideMenuItem(
                            title: 'Logout',
                            icon: Icons.logout,
                            iconColor: Colors.black,
                            iconSize: 18,
                            titleStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  signOutUser() {
    showDialog(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: Text(
            'Are you sure ?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          content: Text(
            'Do you want to logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext),
              child: Text(
                'No',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
            Consumer(builder: (context, ref, child) {
              return TextButton(
                onPressed: () async {
                  subTab = 0;
                  selectedTab = 0;
                  Navigator.pop(alertDialogContext);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("anshi");
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false);
                  }

                  // await FirebaseAuth.instance.signOut();
                  //ref.read(authControllerProvider.notifier).logoutUser(context);
                  // Navigator.pushAndRemoveUntil(

                  //     context,
                  //     MaterialPageRoute(
                  //
                  //
                  //         builder: (context) =>
                  //             LoginPageWidget()),
                  //         (route) => false);
                },
                child: Text(
                  'Yes',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class CustomSideMenuItem extends StatelessWidget {
  const CustomSideMenuItem({
    super.key,
    this.icon,
    this.iconSize = 18,
    this.iconColor = Colors.white,
    this.title,
    this.titleStyle,
    this.onTap,
    this.backColor,
  });

  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? backColor;
  final String? title;
  final TextStyle? titleStyle;

  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        color: backColor,
        child: Row(
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              title ?? '',
              style: titleStyle ??
                  GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
