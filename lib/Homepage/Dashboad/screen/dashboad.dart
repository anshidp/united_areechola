import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:united_areechola/Homepage/chart/dashboard_chart.dart';
import 'package:united_areechola/authentication/screens/login.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/kuri/screens/accounts_screen.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int totalUsers = 0;
  double totalExpense = 0;
  double totalsubcriptionIncome = 0;
  double totalEventIncome = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getTotalData();
  }

  getTotalData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await Future.wait([
        FirebaseFirestore.instance
            .collection("users")
            .count()
            .get()
            .then((value) {
          setState(() {
            totalUsers = (value.count ?? 0);
          });
        }),
        FirebaseFirestore.instance
            .collection("transactions")
            .where("delete", isEqualTo: false)
            .get()
            .then((value) {
          setState(() {
            totalsubcriptionIncome = 0;
            for (var i in value.docs) {
              totalsubcriptionIncome += i["amount"] ?? 0;
            }
          });
        }),
        FirebaseFirestore.instance
            .collection("accounts")
            .where("type", isEqualTo: "expense")
            .get()
            .then((value) {
          setState(() {
            totalExpense = 0;
            for (var i in value.docs) {
              totalExpense += (i["amount"] ?? 0).toDouble();
            }
          });
        }),
        FirebaseFirestore.instance
            .collection("events")
            .where("delete", isEqualTo: false)
            .get()
            .then((value) {
          setState(() {
            totalEventIncome = 0;
            for (var i in value.docs) {
              totalEventIncome += i["totalIncome"] ?? 0;
            }
          });
        }),
      ]);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverToBoxAdapter(
            child: _buildHeader(context, size),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: _buildStatsSection(size),
          ),

          // Chart Section
          SliverToBoxAdapter(
            child: SizedBox(
                width: scrWidth,
                height:
                    scrWidth > 600 ? scrHeight * 0.6 : scrHeight * 0.65,
                child: DashboardChart(
                  totalEventIncome: totalsubcriptionIncome,
                )),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[800]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isAdmin) ...[
            Row(
              children: [
                Hero(
                  tag: "profile_avatar",
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundImage: userDataModel?.photoUrl == null ||
                              (userDataModel?.photoUrl ?? "").isEmpty
                          ? null
                          : NetworkImage(userDataModel?.photoUrl ?? ""),
                      radius: size.width * 0.06,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back,",
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userDataModel?.fullName?.toUpperCase() ?? 'USER',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Hi, ${userDataModel?.role.toUpperCase() ?? 'ADMIN'}",
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      style: GoogleFonts.inter(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.remove("id");
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 22,
              ),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Size size) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatsCards(size),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Size size) {
    final stats = [
      {
        'title': 'Total Users',
        'value': totalUsers,
        'icon': Icons.people_outline,
        'color': Colors.green,
        'gradient': [Colors.green[400]!, Colors.green[600]!],
      },
      {
        'title': 'Total Expense',
        'value': totalExpense,
        'icon': Icons.arrow_upward_rounded,
        'color': Colors.red,
        'gradient': [Colors.red[400]!, Colors.red[600]!],
      },
      {
        'title': 'Subscription Income',
        'value': totalsubcriptionIncome,
        'icon': Icons.card_membership_rounded,
        'color': Colors.purple,
        'gradient': [Colors.purple[400]!, Colors.purple[600]!],
      },
      {
        'title': 'Event Collection',
        'value': totalEventIncome,
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.purple,
        'gradient': [Colors.purple[400]!, Colors.purple[600]!],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 3 : 2,
        childAspectRatio: size.width > 600 ? 2.1 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat, index);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: stat['gradient'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (stat['color'] as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AccountsScreen()));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedFlipCounter(
                        fractionDigits: index == 2 || index == 3 ? 1 : 0,
                        prefix: index == 2 || index == 3 ? "₹" : "",
                        duration: const Duration(milliseconds: 200),
                        value: stat['value'] ?? 0,
                        textStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      stat['title'] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
