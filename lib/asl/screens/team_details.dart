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

  Future<void> transferDataToSeasonSubcollection(String seasonId) async {
    // Get the references of the existing collections
    final teamsRef = await FirebaseFirestore.instance.collection('teams').get();
    final matchesRef =
        await FirebaseFirestore.instance.collection('matches').get();

    // Define the season document
    final seasonDoc =
        FirebaseFirestore.instance.collection('seasons').doc(seasonId);

    // Transfer teams to the season subcollection
    for (var teamDoc in teamsRef.docs) {
      final teamData = teamDoc.data();
      teamData['seasonId'] = seasonId; // Add seasonId to the team document
      await seasonDoc.collection('teams').doc(teamDoc.id).set(teamData);
    }

    // Transfer matches to the season subcollection
    for (var matchDoc in matchesRef.docs) {
      final matchData = matchDoc.data();
      matchData['seasonId'] = seasonId; // Add seasonId to the match document
      await seasonDoc.collection('matches').doc(matchDoc.id).set(matchData);
    }

    print(
        'Data transferred to season subcollection with seasonId successfully!');
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
        length: 6,
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
                              fontSize: 26,
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
                      Tab(text: "Stats"),
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
                  SingleChildScrollView(
                      child: ShowMatch(seasonModel: widget.seasonModel)),
                  // Teams tab content
                  //! team table
                  SingleChildScrollView(
                      child: TeamTable(
                    seasonModel: widget.seasonModel,
                  )),

                  // Players tab content
                  SingleChildScrollView(
                      child: Players(
                    seasonModel: widget.seasonModel,
                  )),
                  SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      topScorers(scrWidth),
                      topAssisters(scrWidth),
                    ],
                  )),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: width * 0.03)),
                Text(
                  "Top Scorer",
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    // width: 400,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1), // Subtle shadow
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: Color(0xffFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: topScorers.length,
                        itemBuilder: (ctx, index) {
                          final player = topScorers[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02, vertical: width * 0.01),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              NetworkImage(player.image),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: width * 0.2),
                                              child: Text(
                                                player.name,
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Consumer(builder: (context, ref, _) {
                                              ref.watch(teams);
                                              return Text(
                                                ref.read(teams)[player.teamId] ??
                                                    "",
                                                style: GoogleFonts.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500),
                                              );
                                            }),
                                          ],
                                        )
                                      ],
                                    ),
                                    if (index == 0)
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.green,
                                        child: Text(
                                          player.statics['goal'].toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                      )
                                    else
                                      Text(
                                        player.statics['goal'].toString(),
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      )
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
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
              children: [
                Padding(padding: EdgeInsets.only(top: width * 0.03)),
                Text(
                  "Top Assister",
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Subtle shadow
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: Color(0xffFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: topAssisters.length,
                        itemBuilder: (ctx, index) {
                          final player = topAssisters[index];
                          if ((player.statics['assist'] ?? 0) > 0) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width * 0.02,
                                  vertical: width * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                NetworkImage(player.image),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10)),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: width * 0.2),
                                                child: Text(
                                                  player.name,
                                                  style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Consumer(
                                                  builder: (context, ref, _) {
                                                ref.watch(teams);
                                                return Text(
                                                  ref.read(teams)[
                                                          player.teamId] ??
                                                      "",
                                                  style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                );
                                              }),
                                            ],
                                          )
                                        ],
                                      ),
                                      if (index == 0)
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.green,
                                          child: Text(
                                            player.statics['assist'].toString(),
                                            style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                        )
                                      else
                                        Text(
                                          player.statics['assist'].toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        )
                                    ],
                                  )
                                ],
                              ),
                            );
                          } else {
                            return SizedBox();
                          }
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
