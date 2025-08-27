import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/Homepage/chart/dashboard_chart.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _statsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int totalUsers = 0;
  int totalevents = 0;
  double totalsubcriptionIncome = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // _slideAnimation = Tween<Offset>(
    //   begin: const Offset(0, 0.3),
    //   end: Offset.zero,
    // ).animate(CurvedAnimation(
    //   parent: _animationController,
    //   curve: Curves.easeOutBack,
    // ));

    getTotalData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _statsAnimationController.dispose();
    super.dispose();
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
            .collection("events")
            .where("delete", isEqualTo: false)
            .count()
            .get()
            .then((value) {
          setState(() {
            totalevents = value.count ?? 0;
          });
        }),
      ]);

      setState(() {
        isLoading = false;
      });
      _statsAnimationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
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

                // Add some bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          );
        },
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
                      backgroundImage:
                          NetworkImage(userDataModel?.photoUrl ?? ""),
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
                  ),
                ),
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
        'value': totalUsers.toString(),
        'icon': Icons.people_outline,
        'color': Colors.green,
        'gradient': [Colors.green[400]!, Colors.green[600]!],
      },
      {
        'title': 'Total Events',
        'value': totalevents.toString(),
        'icon': Icons.event_outlined,
        'color': Colors.blue,
        'gradient': [Colors.blue[400]!, Colors.blue[600]!],
      },
      {
        'title': 'Total Income',
        'value': '₹${totalsubcriptionIncome.toStringAsFixed(0)}',
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.purple,
        'gradient': [Colors.purple[400]!, Colors.purple[600]!],
      },
    ];

    return AnimatedBuilder(
      animation: _statsAnimationController,
      builder: (context, child) {
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
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 800 + (index * 200)),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildStatCard(stat, index),
                );
              },
            );
          },
        );
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
            // Add navigation or action here
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
                    Text(
                      stat['value'] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
