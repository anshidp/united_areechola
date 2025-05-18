import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/asl_admin/screens/add_matches.dart';
import 'package:united_areechola/asl_admin/screens/update_match.dart';
import 'package:united_areechola/authentication/screens/splash_screen.dart';
import 'package:united_areechola/common/common.dart';

class ShowMatch extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const ShowMatch({super.key, required this.seasonModel});

  @override
  ConsumerState<ShowMatch> createState() => _ShowMatchState();
}

class _ShowMatchState extends ConsumerState<ShowMatch> {
  final teamAscoreController = TextEditingController();
  final teamBscoreController = TextEditingController();
  final selectWinningTeam = StateProvider<String?>((ref) => null);
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
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return StreamBuilder<List<MatchModel>>(
        stream: FirebaseFirestore.instance
            .collection('seasons')
            .doc(widget.seasonModel.id)
            .collection('matches')
            .where('delete', isEqualTo: false)
            .orderBy('createdDate', descending: false)
            .snapshots()
            .map((event) => event.docs
                .map(
                  (e) => MatchModel.fromMap(e.data()),
                )
                .toList()),
        builder: (ctx, snapshot) {
          print(snapshot.error);
          if (!snapshot.hasData) {
            return Text("no data found");
          }
          final matches = snapshot.data ?? [];
          bool isFinalMatch = matches.any((element) =>
              element.stage == GroupType.finalmatch.name &&
              element.status == MatchStatus.fulltime.name);
          final groupMatches = matches
              .where(
                (element) => element.stage == GroupType.group.name,
              )
              .toList();
          final semiMatches = matches
              .where(
                (element) => element.stage == GroupType.semifinal.name,
              )
              .toList();
          final quarterMatches = matches
              .where(
                (element) => element.stage == GroupType.quarterfinal.name,
              )
              .toList();
          final finalmatches = matches
              .where(
                (element) => element.stage == GroupType.finalmatch.name,
              )
              .toList();

          return SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  children: [
                    buildGroupMatches(groupMatches, "Group", h, w),
                    const SizedBox(height: 20),
                    buildGroupMatches(quarterMatches, "QuarterFinal", h, w),
                    const SizedBox(height: 20),
                    buildGroupMatches(semiMatches, "SemiFinal", h, w),
                    const SizedBox(height: 20),
                    buildGroupMatches(finalmatches, "Final", h, w),
                  ],
                ),
                if (isFinalMatch)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lottie Animation (Confetti or Celebration animation)
                        Lottie.asset(
                          'assets/winners.json', // Replace with your Lottie file path
                          repeat: true,
                          width: w * 0.8,
                          height: h * 0.5,
                        ),
                        SizedBox(height: 20),
                        // Winner Announcement
                        Consumer(builder: (context, ref, _) {
                          ref.watch(teams);
                          return Container(
                            width: double.infinity,
                            height: h * 0.06,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "Congratulations, Team ${ref.read(teams)[getFinalWinner(matches)]}!",
                              style: GoogleFonts.inter(
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          );
        });
  }

  Widget buildGroupMatches(
      List<MatchModel> matchModel, String stageName, double h, double w) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stageName,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: matchModel.length,
                itemBuilder: (context, index) {
                  final match = matchModel[index];

                  return Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      width: double.infinity,
                      height: h * 0.08,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.1), // Subtle shadow
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                          color: Color(0xffFFFFFF),
                          borderRadius: BorderRadius.circular(15)),
                      child: Consumer(builder: (context, ref, _) {
                        ref.watch(teams);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ref.read(teams)[match.teamA] ?? "",
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: w * 0.05),
                            if (match.teamAscore > 0 ||
                                match.teamBscore > 0 ||
                                match.status == MatchStatus.fulltime.name)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${(match.teamAscore)} - ${(match.teamBscore).toString()}",
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(match.status.toUpperCase(),
                                      style: GoogleFonts.inter(
                                          color: match.status ==
                                                  MatchStatus.fulltime.name
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600))
                                ],
                              )
                            else
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      DateFormat('HH:mm').format(match.kickoff),
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(DateFormat('aa').format(match.kickoff),
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            SizedBox(width: w * 0.05),
                            Text(ref.read(teams)[match.teamB] ?? "",
                                style: GoogleFonts.inter(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            if (isAdmin &&
                                match.status == MatchStatus.ongoing.name)
                              Padding(padding: EdgeInsets.only(left: w * 0.3)),
                            if (isAdmin &&
                                match.status == MatchStatus.ongoing.name)
                              ElevatedButton(
                                onPressed: () {
                                  teamAscoreController.text =
                                      (match.teamAscore ?? 0).toString();
                                  teamBscoreController.text =
                                      (match.teamBscore ?? 0).toString();
                                  showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return StatefulBuilder(
                                            builder: (context, set) {
                                          return AlertDialog(
                                            content: Padding(
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: w * 0.2,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Palette
                                                                      .blackColor,
                                                                  fontSize:
                                                                      w * 0.008,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          controller:
                                                              teamAscoreController,
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      "Team ${ref.read(teams)[match.teamA]} scroe",
                                                                  labelStyle:
                                                                      GoogleFonts
                                                                          .poppins(
                                                                    color: Palette
                                                                        .greyColor,
                                                                    fontSize: w *
                                                                        0.008,
                                                                  ),
                                                                  hintStyle:
                                                                      GoogleFonts
                                                                          .poppins(
                                                                    color: Palette
                                                                        .greyColor,
                                                                    fontSize: w *
                                                                        0.008,
                                                                  ),
                                                                  hintText:
                                                                      "Team ${ref.read(teams)[match.teamA]} scroe",
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(w *
                                                                          0.02),
                                                                      borderSide: const BorderSide(
                                                                          color: Palette
                                                                              .borderColor)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(w *
                                                                              0.02),
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Palette
                                                                                  .borderColor)),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(w * 0.02),
                                                                      borderSide: const BorderSide(color: Palette.borderColor))),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: w * 0.03,
                                                      ),
                                                      SizedBox(
                                                        width: w * 0.2,
                                                        child: TextFormField(
                                                          readOnly: true,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Palette
                                                                      .blackColor,
                                                                  fontSize:
                                                                      w * 0.008,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          controller:
                                                              teamBscoreController,
                                                          decoration:
                                                              InputDecoration(
                                                                  labelText:
                                                                      "Team ${ref.read(teams)[match.teamB]} scroe",
                                                                  labelStyle:
                                                                      GoogleFonts
                                                                          .poppins(
                                                                    color: Palette
                                                                        .greyColor,
                                                                    fontSize: w *
                                                                        0.008,
                                                                  ),
                                                                  hintStyle:
                                                                      GoogleFonts
                                                                          .poppins(
                                                                    color: Palette
                                                                        .greyColor,
                                                                    fontSize: w *
                                                                        0.008,
                                                                  ),
                                                                  hintText:
                                                                      "Team ${ref.read(teams)[match.teamB]} scroe",
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(w *
                                                                          0.02),
                                                                      borderSide: const BorderSide(
                                                                          color: Palette
                                                                              .borderColor)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(w *
                                                                              0.02),
                                                                      borderSide:
                                                                          const BorderSide(
                                                                              color: Palette
                                                                                  .borderColor)),
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(w * 0.02),
                                                                      borderSide: const BorderSide(color: Palette.borderColor))),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: h * 0.03)),
                                                  if (int.parse(
                                                                  teamAscoreController
                                                                      .text) ==
                                                              0 &&
                                                          int.parse(
                                                                  teamBscoreController
                                                                      .text) ==
                                                              0 &&
                                                          match.stage ==
                                                              GroupType
                                                                  .semifinal
                                                                  .name ||
                                                      match.stage ==
                                                          GroupType
                                                              .finalmatch.name)
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left:
                                                                      w * 0.02),
                                                          width: w * 0.2,
                                                          height: h * 0.06,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(w *
                                                                        0.02),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          child: DropdownButton<
                                                                  String>(
                                                              focusColor: Colors
                                                                  .transparent,
                                                              underline:
                                                                  const SizedBox(),
                                                              hint: Text(
                                                                "Select Winner",
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Color(
                                                                      0xffB6B6B6),
                                                                  fontSize:
                                                                      w * 0.008,
                                                                ),
                                                              ),
                                                              value: (ref.watch(
                                                                              selectWinningTeam) ??
                                                                          "")
                                                                      .isEmpty
                                                                  ? null
                                                                  : ref.read(
                                                                      selectWinningTeam),
                                                              items: ref
                                                                  .watch(teams)
                                                                  .entries
                                                                  .map(
                                                                    (possition) =>
                                                                        DropdownMenuItem<
                                                                            String>(
                                                                      value: possition
                                                                          .key,
                                                                      child:
                                                                          Text(
                                                                        possition
                                                                            .value,
                                                                        style: GoogleFonts
                                                                            .poppins(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              w * 0.008,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                              onChanged:
                                                                  (value) {
                                                                set(
                                                                  () {
                                                                    ref
                                                                        .read(selectWinningTeam
                                                                            .notifier)
                                                                        .state = value;
                                                                  },
                                                                );
                                                              }),
                                                        ),
                                                      ],
                                                    ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: h * 0.03)),
                                                  InkWell(
                                                    onTap: () async {
                                                      bool isPenalty = int.parse(
                                                                      teamAscoreController
                                                                          .text) ==
                                                                  0 &&
                                                              int.parse(teamBscoreController
                                                                      .text) ==
                                                                  0 &&
                                                              match.stage ==
                                                                  GroupType
                                                                      .semifinal
                                                                      .name ||
                                                          match.stage ==
                                                              GroupType
                                                                  .finalmatch
                                                                  .name;
                                                      if (teamAscoreController
                                                          .text.isEmpty) {
                                                        return showSnackBarToast(
                                                            context,
                                                            "Please enter ${ref.read(teams)[match.teamA]} Score",
                                                            "red");
                                                      } else if (teamBscoreController
                                                          .text.isEmpty) {
                                                        return showSnackBarToast(
                                                            context,
                                                            "Please enter ${ref.read(teams)[match.teamB]} Score",
                                                            'red');
                                                      } else if (!isPenalty) {
                                                        return showSnackBarToast(
                                                            context,
                                                            "Please choose winner team",
                                                            'red');
                                                      }

                                                      final confirm = await alert(
                                                          context,
                                                          "Do you want end this match",
                                                          w,
                                                          h);
                                                      //! update match
                                                      if (confirm &&
                                                          context.mounted) {
                                                        ref.read(aslRepositoryProvider).updateMatchStat(
                                                            seasonId: widget
                                                                    .seasonModel
                                                                    .id ??
                                                                "",
                                                            winner: ref.read(
                                                                    selectWinningTeam) ??
                                                                "",
                                                            context: context,
                                                            w: w,
                                                            h: h,
                                                            currentStage:
                                                                match.stage,
                                                            matchId:
                                                                match.matchId ??
                                                                    "",
                                                            teamA: match.teamA,
                                                            teamB: match.teamB,
                                                            teamAscore: int.parse(
                                                                teamAscoreController
                                                                    .text),
                                                            teamBscore: int.parse(
                                                                teamBscoreController
                                                                    .text));
                                                        if (context.mounted) {
                                                          showSnackBarToast(
                                                              context,
                                                              "Player updated successfully",
                                                              "green");
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      height: w * 0.027,
                                                      width: w * 0.2,
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15)),
                                                        color: Palette.newColor,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "End Match",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: Palette
                                                                .whiteColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: w * 0.008,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                      });
                                },
                                style: ElevatedButton.styleFrom(),
                                child: Text(
                                  "End Match",
                                  style: GoogleFonts.inter(
                                      fontSize: w * 0.007,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            Padding(padding: EdgeInsets.only(left: w * 0.03)),
                            if (isAdmin &&
                                match.status == MatchStatus.ongoing.name)
                              ElevatedButton(
                                onPressed: () {
                                  if (mounted) {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                              content: UpdateMatch(
                                            matchModel: match,
                                          ));
                                        });
                                  }
                                },
                                style: ElevatedButton.styleFrom(),
                                child: Text(
                                  "Update Match",
                                  style: GoogleFonts.inter(
                                      fontSize: w * 0.007,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                          ],
                        );
                      }),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  String getFinalWinner(List<MatchModel> matches) {
    final finalMatch =
        matches.firstWhere((match) => match.stage == GroupType.finalmatch.name);
    print("finalMatch : ${finalMatch.toMap()}");
    print("===================");
    String winner = "";
    if (finalMatch.teamAscore == 0 && finalMatch.teamBscore == 0) {
      winner = finalMatch.winner ?? "";
    } else {
      winner = finalMatch.teamAscore > finalMatch.teamBscore
          ? finalMatch.teamA
          : finalMatch.teamB;
    }

    print("winner: $winner");

    return winner ?? 'Unknown Team';
  }
}
