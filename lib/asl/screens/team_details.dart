// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl/screens/overview.dart';
import 'package:united_areechola/asl/screens/players.dart';
import 'package:united_areechola/asl/screens/table.dart';
import 'package:united_areechola/asl/screens/teams.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/asl_admin/screens/show_match.dart';
import 'package:united_areechola/common/common.dart';

class TeamDetails extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const TeamDetails({
    super.key,
    required this.seasonModel,
  });

  @override
  ConsumerState<TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends ConsumerState<TeamDetails> {
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  void getTeams() async {
    ref.read(teams.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeams(widget.seasonModel.id ?? "");
  }

  @override
  void initState() {
    getTeams();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC), // Slate 50
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            // Premium Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // Slate 900
                    Color(0xFF1E293B), // Slate 800
                    Color(0xFF334155), // Slate 700
                  ],
                ),
                // borderRadius: BorderRadius.only(
                //   bottomLeft: Radius.circular(30),
                //   bottomRight: Radius.circular(30),
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, 
                    blurRadius: 20, 
                    offset: Offset(0, 10)
                  )
                ]
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Back Button & Title Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                          Expanded(
                            child: Text(
                              "Tournament Dashboard",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                                letterSpacing: 1
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balance for back button
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Main Season Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Image.asset(ImageConstants.clubLogo),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ASL ${widget.seasonModel.seasonName}",
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.1
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Palette.newColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Season ${widget.seasonModel.year}",
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Tab Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBar(
                        isScrollable: true,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.white60,
                        labelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.only(bottom: 20),
                        tabs: const [
                          Tab(text: "Overview"),
                          Tab(text: "Teams"),
                          Tab(text: "Matches"),
                          Tab(text: "Table"),
                          Tab(text: "Players"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SeasonOverView(seasonModel: widget.seasonModel),
                  Teams(seasonModel: widget.seasonModel),
                  ShowMatch(seasonModel: widget.seasonModel),
                  SingleChildScrollView(child: TeamTable(seasonModel: widget.seasonModel)),
                  Players(seasonModel: widget.seasonModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Redesigned Helper Widgets (kept for potential use within sub-tabs if passed down)
  Widget topScorers(double width) {
    return _buildTopList("Top Scorers", "goal", Colors.green);
  }

  Widget topAssisters(double width) {
    return _buildTopList("Top Assisters", "assist", Colors.amber[700]!);
  }

  Widget _buildTopList(String title, String statKey, Color badgeColor) {
    return StreamBuilder<List<PlayerModel>>(
      stream: FirebaseFirestore.instance
          .collection("seasons")
          .doc(widget.seasonModel.id)
          .collection('players')
          .orderBy("statics.$statKey", descending: true)
          .limit(3)
          .snapshots()
          .map((event) => event.docs.map((e) => PlayerModel.fromMap(e.data())).toList()),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final players = snap.data ?? [];
        if (players.isEmpty || players.every((e) => (e.statics[statKey] ?? 0) == 0)) {
          return Center(
            child: Text(
              "No $statKey records yet",
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: players.length,
              itemBuilder: (ctx, index) {
                final player = players[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, 
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index == 0 ? const Color(0xFFFFD700).withOpacity(0.2) : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "#${index + 1}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: index == 0 ? Colors.amber[800] : Colors.grey[600]
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Consumer(
                              builder: (context, ref, _) {
                                ref.watch(teams);
                                return Text(
                                  ref.read(teams)[player.teamId] ?? "Unknown Team",
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey[500]
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${player.statics[statKey]}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
