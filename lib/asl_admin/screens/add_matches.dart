import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

enum GroupType { group, semifinal, quarterfinal, finalmatch }

class AddMatches extends ConsumerStatefulWidget {
  const AddMatches({super.key});

  @override
  ConsumerState<AddMatches> createState() => _AddMatchesState();
}

class _AddMatchesState extends ConsumerState<AddMatches> {
  final teamA = StateProvider<String?>((ref) => null);
  final teamB = StateProvider<String?>((ref) => null);
  final selectStage = StateProvider<String?>((ref) => null);
  final selectSeason = StateProvider<String?>((ref) => null);
  final selectGroup = StateProvider<String?>((ref) => null);
  final startTime = StateProvider<TimeOfDay?>((ref) => null);
  final startDate = StateProvider<DateTime?>((ref) => null);
  final statTimeController = TextEditingController();
  final statDateController = TextEditingController();
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final List<String> stage = [
    GroupType.group.name,
    GroupType.semifinal.name,
    GroupType.quarterfinal.name,
    GroupType.finalmatch.name
  ];
  final List<String> group = ["A", "B"];

  void getSeason() async {
    ref.read(seasons.notifier).state =
        await ref.read(aslRepositoryProvider).getSeasons();
  }

  @override
  void initState() {
    getSeason();
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
        SizedBox(
          // height: w * 0.12,
          width: w * 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Season",
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
                      "Season",
                      style: GoogleFonts.poppins(
                        color: Color(0xffB6B6B6),
                        fontSize: w * 0.008,
                      ),
                    ),
                    value: (ref.watch(selectSeason) ?? "").isEmpty
                        ? null
                        : ref.read(selectSeason),
                    items: ref
                        .watch(seasons)
                        .entries
                        .map(
                          (possition) => DropdownMenuItem<String>(
                            value: possition.key,
                            child: Text(
                              possition.value,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: w * 0.008,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      ref.read(selectSeason.notifier).state = value;

                      ref.read(teams.notifier).state = await ref
                          .read(aslRepositoryProvider)
                          .getTeams(ref.read(selectSeason) ?? "");
                    }),
              ),
            ],
          ),
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
                    "Team A",
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
                          "Team A",
                          style: GoogleFonts.poppins(
                            color: Color(0xffB6B6B6),
                            fontSize: w * 0.008,
                          ),
                        ),
                        value: (ref.watch(teamA) ?? "").isEmpty
                            ? null
                            : ref.read(teamA),
                        items: ref
                            .watch(teams)
                            .entries
                            .map(
                              (possition) => DropdownMenuItem<String>(
                                value: possition.key,
                                child: Text(
                                  possition.value,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: w * 0.008,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          ref.read(teamA.notifier).state = value;
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(width: w * 0.05),
            SizedBox(
              // height: w * 0.12,
              width: w * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Team B",
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
                          "Team B",
                          style: GoogleFonts.poppins(
                            color: Color(0xffB6B6B6),
                            fontSize: w * 0.008,
                          ),
                        ),
                        value: (ref.watch(teamB) ?? "").isEmpty
                            ? null
                            : ref.read(teamB),
                        items: ref
                            .watch(teams)
                            .entries
                            .map(
                              (possition) => DropdownMenuItem<String>(
                                value: possition.key,
                                child: Text(
                                  possition.value,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: w * 0.008,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          ref.read(teamB.notifier).state = value;
                        }),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
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
                    "StartTime",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Palette.blackColor,
                        fontSize: w * 0.009),
                  ),
                  SizedBox(
                    height: w * 0.01,
                  ),
                  TextFormField(
                    onTap: () async {
                      final pickTime = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2050));
                      if (pickTime != null) {
                        ref.read(startDate.notifier).state = pickTime;
                        statDateController.text =
                            DateFormat("dd-MM-yyyy").format(pickTime);
                      }
                    },
                    style: GoogleFonts.poppins(
                        color: Palette.blackColor,
                        fontSize: w * 0.008,
                        fontWeight: FontWeight.w400),
                    controller: statDateController,
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          color: Palette.greyColor,
                          fontSize: w * 0.008,
                        ),
                        hintText: "StartDate",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor))),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: w * 0.01,
            ),
            SizedBox(
              // height: w * 0.12,
              width: w * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "StartTime",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Palette.blackColor,
                        fontSize: w * 0.009),
                  ),
                  SizedBox(
                    height: w * 0.01,
                  ),
                  TextFormField(
                    onTap: () async {
                      final pickTime = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (pickTime != null) {
                        print(pickTime);
                        ref.read(startTime.notifier).state = pickTime;
                        statTimeController.text =
                            "${ref.read(startTime)?.hour}:${ref.read(startTime)?.minute}";
                      }
                    },
                    style: GoogleFonts.poppins(
                        color: Palette.blackColor,
                        fontSize: w * 0.008,
                        fontWeight: FontWeight.w400),
                    controller: statTimeController,
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          color: Palette.greyColor,
                          fontSize: w * 0.008,
                        ),
                        hintText: "StartTime",
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(w * 0.02),
                            borderSide:
                                const BorderSide(color: Palette.borderColor))),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   // height: w * 0.12,
            //   width: w * 0.2,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "Group",
            //         style: GoogleFonts.poppins(
            //             fontWeight: FontWeight.w500,
            //             color: Palette.blackColor,
            //             fontSize: w * 0.009),
            //       ),
            //       SizedBox(
            //         height: w * 0.01,
            //       ),
            //       Container(
            //         padding: EdgeInsets.only(left: w * 0.02),
            //         width: w * 0.2,
            //         height: h * 0.06,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(w * 0.02),
            //           border: Border.all(color: Colors.grey),
            //         ),
            //         child: DropdownButton<String>(
            //             focusColor: Colors.transparent,
            //             underline: const SizedBox(),
            //             hint: Text(
            //               "Group",
            //               style: GoogleFonts.poppins(
            //                 color: Color(0xffB6B6B6),
            //                 fontSize: w * 0.008,
            //               ),
            //             ),
            //             value: (ref.watch(selectGroup) ?? "").isEmpty
            //                 ? null
            //                 : ref.read(selectGroup),
            //             items: group
            //                 .map(
            //                   (possition) => DropdownMenuItem<String>(
            //                     value: possition,
            //                     child: Text(
            //                       possition,
            //                       style: GoogleFonts.poppins(
            //                         color: Colors.black,
            //                         fontSize: w * 0.008,
            //                       ),
            //                     ),
            //                   ),
            //                 )
            //                 .toList(),
            //             onChanged: (value) {
            //               ref.read(teamB.notifier).state = value;
            //             }),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              width: w * 0.01,
            ),
            SizedBox(
              // height: w * 0.12,
              width: w * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stage",
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
                          "Stage",
                          style: GoogleFonts.poppins(
                            color: Color(0xffB6B6B6),
                            fontSize: w * 0.008,
                          ),
                        ),
                        value: (ref.watch(selectStage) ?? "").isEmpty
                            ? null
                            : ref.read(selectStage),
                        items: stage
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
                        onChanged: (value) {
                          ref.read(selectStage.notifier).state = value;
                        }),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: w * 0.01,
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        InkWell(
          onTap: () {
            if (ref.read(teamA) == null) {
              return showSnackBarToast(context, "Please choose Team A", "red");
            } else if (ref.read(teamB) == null) {
              return showSnackBarToast(context, "Please choose Team B", "red");
            } else if (statDateController.text.isEmpty) {
              return showSnackBarToast(
                  context, "Please choose StartDate", "red");
            } else if (statTimeController.text.isEmpty) {
              return showSnackBarToast(
                  context, "Please choose StartTime", "red");
            }
            final matchModel = MatchModel(
                seasonId: ref.read(selectSeason) ?? "",
                ispenalty: false,
                winner: "",
                stage: ref.read(selectStage) ?? "",
                goals: [],
                createdDate: DateTime.now(),
                delete: false,
                teamA: ref.read(teamA) ?? "",
                teamB: ref.read(teamB) ?? "",
                kickoff: DateTime(
                  ref.read(startDate)!.year,
                  ref.read(startDate)!.month,
                  ref.read(startDate)!.day,
                  ref.read(startTime)!.hour,
                  ref.read(startTime)!.minute,
                ),
                status: MatchStatus.ongoing.name,
                teamAscore: 0,
                teamBscore: 0);
            ref
                .read(aslRepositoryProvider)
                .addNewMatch(matchModel, ref.read(selectSeason) ?? "");
            if (context.mounted) {
              showSnackBarToast(context, "Match created successfully", 'green');
              ref.read(teamA.notifier).state = null;
              ref.read(teamB.notifier).state = null;
              statTimeController.clear();
              ref.read(startTime.notifier).state = null;
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
                "Add Match",
                style: GoogleFonts.poppins(
                  color: Palette.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: w * 0.008,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
