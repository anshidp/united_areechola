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

  playerupdate() async {
    final playerRef =
        await FirebaseFirestore.instance.collection('players').get();
    final team = await FirebaseFirestore.instance.collection('teams').get();
    final match = await FirebaseFirestore.instance.collection('matches').get();
    for (var p in playerRef.docs) {
      await FirebaseFirestore.instance.collection('players').doc(p.id).update({
        "appearences": 0,
        "statics": {"goal": 0, "assist": 0, "yelloCard": 0, "redCard": 0}
      });
    }
    for (var i in team.docs) {
      await FirebaseFirestore.instance.collection('teams').doc(i.id).update(
          {"win": 0, "lose": 0, "point": 0, "draw": 0, "playedMatch": 0});
    }
    for (var e in match.docs) {
      await FirebaseFirestore.instance
          .collection('matches')
          .doc(e.id)
          .update({"teamAscore": 0, "teamBscore": 0, "status": "ongoing"});
    }
  }

  @override
  void initState() {
    // playerupdate();
    getTeams();
    // transferDataToSeasonSubcollection(widget.seasonModel.id ?? "");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(color: Palette.topColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  // Logo and League name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Logo
                      SizedBox(
                        width: scrWidth * 0.3,
                        height: scrHeight * 0.08,
                        child: Image.asset(ImageConstants.clubLogo),
                      ),
                      // League name
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            "ASL ${widget.seasonModel.seasonName.toUpperCase()}",
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  TabBar(
                    labelStyle: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    labelColor: Colors.white,
                    indicatorColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: "Overview"),
                      Tab(text: "Teams"),

                      Tab(text: "Matches"),
                      Tab(text: "Table"),
                      Tab(text: "Players"),

                      // Tab(text: "Knockout"),
                    ],
                  ),
                ],
              ),
            ),

            // TabBarView (content for each tab)
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  SeasonOverView(
                    seasonModel: widget.seasonModel,
                  ),
                  //! team photos
                  Teams(
                    seasonModel: widget.seasonModel,
                  ),
                  //! matches
                  ShowMatch(seasonModel: widget.seasonModel),
                  // Teams tab content
                  //! team table
                  SingleChildScrollView(
                      child: TeamTable(
                    seasonModel: widget.seasonModel,
                  )),

                  // Players tab content
                  Players(
                    seasonModel: widget.seasonModel,
                  ),

                  // SingleChildScrollView(child: BracketView()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topScorers(double width) {
    return StreamBuilder<List<PlayerModel>>(
        stream: FirebaseFirestore.instance
            .collection("seasons")
            .doc(widget.seasonModel.id)
            .collection('players')
            .orderBy("statics.goal", descending: true)
            .limit(3)
            .snapshots()
            .map((event) => event.docs
                .map(
                  (e) => PlayerModel.fromMap(e.data()),
                )
                .toList()),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final topScorers = snap.data ?? [];
          if (topScorers.isEmpty ||
              topScorers
                  .every((element) => (element.statics['goal'] ?? 0) == 0)) {
            return Center(
              child: Text("No goals have been recorded yet!"),
            );
          }
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: 20)),
                Text(
                  "Top Scorer",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topScorers.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.grey.shade200,
                        height: 1,
                      ),
                      itemBuilder: (ctx, index) {
                        final player = topScorers[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Player Image
                              // CircleAvatar(
                              //   radius: 28,
                              //   backgroundImage: NetworkImage(player.image),
                              // ),
                              // const SizedBox(width: 12),

                              // Name & Team
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer(
                                      builder: (context, ref, _) {
                                        ref.watch(teams);
                                        return Text(
                                          ref.read(teams)[player.teamId] ?? "",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Goals
                              index == 0
                                  ? CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        player.statics['goal'].toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      player.statics['goal'].toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget topAssisters(double width) {
    return StreamBuilder<List<PlayerModel>>(
        stream: FirebaseFirestore.instance
            .collection("seasons")
            .doc(widget.seasonModel.id)
            .collection('players')
            .orderBy("statics.assist", descending: true)
            .limit(3)
            .snapshots()
            .map((event) => event.docs
                .map(
                  (e) => PlayerModel.fromMap(e.data()),
                )
                .toList()),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final topAssisters = snap.data ?? [];
          if (topAssisters.isEmpty ||
              topAssisters
                  .every((element) => (element.statics['assist'] ?? 0) == 0)) {
            return Center(
              child: Text("No assists have been recorded yet!"),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: 20)),
                Text(
                  "Top Assister",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topAssisters.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.grey.shade200,
                        height: 1,
                      ),
                      itemBuilder: (ctx, index) {
                        final player = topAssisters[index];
                        final assists = player.statics['assist'] ?? 0;

                        if (assists <= 0) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Player Image
                              // CircleAvatar(
                              //   radius: 28,
                              //   backgroundImage: NetworkImage(player.image),
                              // ),
                              // const SizedBox(width: 12),

                              // Name & Team
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Consumer(
                                      builder: (context, ref, _) {
                                        ref.watch(teams);
                                        return Text(
                                          ref.read(teams)[player.teamId] ?? "",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Assist count
                              index == 0
                                  ? CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        assists.toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      assists.toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
