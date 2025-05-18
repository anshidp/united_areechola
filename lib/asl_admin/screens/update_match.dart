import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class UpdateMatch extends ConsumerStatefulWidget {
  final MatchModel matchModel;
  const UpdateMatch({super.key, required this.matchModel});

  @override
  ConsumerState<UpdateMatch> createState() => _UpdateMatchState();
}

class _UpdateMatchState extends ConsumerState<UpdateMatch> {
  final players = StateProvider<List<PlayerModel>>((ref) => []);
  final teamPlayers = StateProvider<List<PlayerModel>>((ref) => []);
  final selectPlayer = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final selectAssister = StateProvider<String?>((ref) => null);
  List<String> events = [
    PlayerTypes.goals.name,
    PlayerTypes.yellow.name,
    PlayerTypes.red.name
  ];
  final selectEvent = StateProvider<String?>((ref) => null);

  void getAllPlayers() async {
    ref.read(players.notifier).state = await ref
        .read(aslRepositoryProvider)
        .getTeamPlayers(widget.matchModel.teamA, widget.matchModel.teamB);
  }

  @override
  void initState() {
    getAllPlayers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(
          height: h * 0.05,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              // height: w * 0.12,
              width: w * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Player",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Palette.blackColor,
                        fontSize: w * 0.009),
                  ),
                  SizedBox(
                    height: w * 0.01,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: w * 0.02),
                    width: w * 0.2,
                    height: h * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.02),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        underline: const SizedBox(),
                        hint: Text(
                          "Select Player",
                          style: GoogleFonts.poppins(
                            color: Color(0xffB6B6B6),
                            fontSize: w * 0.008,
                          ),
                        ),
                        value: (ref.watch(selectPlayer) ?? "").isEmpty
                            ? null
                            : ref.read(selectPlayer),
                        items: ref
                            .watch(players)
                            .map(
                              (possition) => DropdownMenuItem<String>(
                                value: possition.playerId,
                                child: Text(
                                  possition.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: w * 0.008,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          ref.read(selectPlayer.notifier).state = value;
                          ref.read(selectTeam.notifier).state = ref
                              .read(players)
                              .firstWhere(
                                  (element) => element.playerId == value)
                              .teamId;
                          print("team: ${ref.read(selectTeam)}");
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: w * 0.03,
            ),
            SizedBox(
              // height: w * 0.12,
              width: w * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Event",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Palette.blackColor,
                        fontSize: w * 0.009),
                  ),
                  SizedBox(
                    height: w * 0.01,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: w * 0.02),
                    width: w * 0.2,
                    height: h * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(w * 0.02),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        underline: const SizedBox(),
                        hint: Text(
                          "Select Event",
                          style: GoogleFonts.poppins(
                            color: Color(0xffB6B6B6),
                            fontSize: w * 0.008,
                          ),
                        ),
                        value: (ref.watch(selectEvent) ?? "").isEmpty
                            ? null
                            : ref.read(selectEvent),
                        items: events
                            .map(
                              (possition) => DropdownMenuItem<String>(
                                value: possition,
                                child: Text(
                                  possition,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: w * 0.008,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          ref.read(selectEvent.notifier).state = value;
                          ref.read(teamPlayers.notifier).state = await ref
                              .read(aslRepositoryProvider)
                              .getSpecificTeamPlayers(
                                  teamId: ref.read(selectTeam) ?? "");
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: h * 0.04,
        ),
        if ((ref.watch(selectPlayer) ?? "").isNotEmpty &&
            (ref.watch(selectEvent) ?? "").isNotEmpty &&
            ref.watch(selectEvent) == PlayerTypes.goals.name)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                // height: w * 0.12,
                width: w * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Assister",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Palette.blackColor,
                          fontSize: w * 0.009),
                    ),
                    SizedBox(
                      height: w * 0.01,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: w * 0.02),
                      width: w * 0.2,
                      height: h * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(w * 0.02),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButton<String>(
                          focusColor: Colors.transparent,
                          underline: const SizedBox(),
                          hint: Text(
                            "Select Assister",
                            style: GoogleFonts.poppins(
                              color: Color(0xffB6B6B6),
                              fontSize: w * 0.008,
                            ),
                          ),
                          value: (ref.watch(selectAssister) ?? "").isEmpty
                              ? null
                              : ref.read(selectAssister),
                          items: ref
                              .watch(teamPlayers)
                              .where(
                                (element) =>
                                    element.playerId != ref.read(selectPlayer),
                              )
                              .map(
                                (possition) => DropdownMenuItem<String>(
                                  value: possition.playerId,
                                  child: Text(
                                    possition.name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: w * 0.008,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            ref.read(selectAssister.notifier).state = value;
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        SizedBox(
          height: h * 0.04,
        ),
        InkWell(
          onTap: () async {
            if ((ref.read(selectPlayer) ?? "").isEmpty ||
                (ref.read(selectTeam) ?? "").isEmpty) {
              return showSnackBarToast(context, "Please choose player", "red");
            } else if ((ref.read(selectEvent) ?? "").isEmpty) {
              return showSnackBarToast(context, "Please choose event", "red");
            } else if ((ref.read(selectEvent) ?? "").isNotEmpty &&
                (ref.read(selectAssister) ?? '').isEmpty) {
              return showSnackBarToast(
                  context, "Please choose assister", "red");
            }

            final confirm =
                await alert(context, "Do you want update this match", w, h);
            if (confirm) {
              ref.read(aslRepositoryProvider).updatePlayerStat(
                  seasonId: widget.matchModel.seasonId,
                  assister: ref.read(selectAssister) ?? "",
                  matchId: widget.matchModel.matchId ?? "",
                  selectTeam: ref.read(selectTeam) ?? "",
                  teamA: widget.matchModel.teamA,
                  teamB: widget.matchModel.teamB,
                  playerId: ref.read(selectPlayer) ?? "",
                  type: ref.read(selectEvent) ?? "");
            }
            if (context.mounted) {
              showSnackBarToast(context, "Match updated successfully", "green");
              Navigator.pop(context);
            }
          },
          child: Container(
            height: w * 0.027,
            width: w * 0.2,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Palette.newColor,
            ),
            child: Center(
              child: Text(
                "Update Match",
                style: GoogleFonts.poppins(
                  color: Palette.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.008,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
