import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddTeams extends ConsumerStatefulWidget {
  const AddTeams({super.key});

  @override
  ConsumerState<AddTeams> createState() => _AddPlayersState();
}

class _AddPlayersState extends ConsumerState<AddTeams> {
  final selectmanager = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final isPlayerEdit = StateProvider<bool>((ref) => false);
  final selectSeason = StateProvider<String?>((ref) => null);
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final selectedPlayers = [];
  final teamPlayers = StateProvider<Map<String, PlayerModel>>((ref) => {});
  final teamNameController = TextEditingController();

  final List<String> managers = [
    "MAHROOF",
    "MUNEER OP",
    "SHAMEEM CP",
    "FARSAD OP",
    "JASEEL K",
    "MANAF ",
    "SHYJU",
    "SALMAN",
  ];

  void getPlayers() async {
    ref.read(teamPlayers.notifier).state =
        await ref.read(aslRepositoryProvider).getPlayers();
  }

  @override
  void initState() {
    getPlayers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 40)),
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
                      "Name",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Palette.blackColor,
                          fontSize: w * 0.009),
                    ),
                    SizedBox(
                      height: w * 0.01,
                    ),
                    TextFormField(
                      onTap: () async {},
                      style: GoogleFonts.poppins(
                          color: Palette.blackColor,
                          fontSize: w * 0.008,
                          fontWeight: FontWeight.w400),
                      controller: teamNameController,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Palette.greyColor,
                            fontSize: w * 0.008,
                          ),
                          hintText: "Team Name",
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
                              borderSide: const BorderSide(
                                  color: Palette.borderColor))),
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
                      "Manager",
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
                            "Select Manager",
                            style: GoogleFonts.poppins(
                              color: Color(0xffB6B6B6),
                              fontSize: w * 0.008,
                            ),
                          ),
                          value: (ref.watch(selectmanager) ?? "").isEmpty
                              ? null
                              : ref.read(selectmanager),
                          items: managers
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
                            ref.read(selectmanager.notifier).state = value;
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
              Container(
                width: w * 0.2,
                height: h * 0.06,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Select Players"),
                    items: ref
                        .watch(teamPlayers)
                        .entries
                        .map((entry) {
                          // Only include players with an empty `teamId`
                          if (entry.value.teamId.isEmpty) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selectedPlayers.contains(entry.key),
                                    onChanged: (_) {
                                      _togglePlayerSelection(entry.key);
                                    },
                                  ),
                                  Text(entry.value.name),
                                ],
                              ),
                            );
                          }
                          return null; // Return null for items you want to exclude
                        })
                        .whereType<DropdownMenuItem<String>>()
                        .toList(), // Filter out null items
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          if (!selectedPlayers.contains(value)) {
                            selectedPlayers.add(value);
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          Text(
            "Selected Players:",
            style: GoogleFonts.poppins(
                fontSize: w * 0.01, fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8.0,
            children: selectedPlayers
                .map((id) => Chip(
                      label: Text(ref.watch(teamPlayers)[id]?.name ?? ""),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () => _removePlayer(id),
                    ))
                .toList(),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          InkWell(
            onTap: () async {
              if (teamNameController.text.trim().isEmpty) {
                return showSnackBarToast(
                    context, "Please enter team name", "red");
              } else if ((ref.read(selectmanager) ?? "").isEmpty) {
                return showSnackBarToast(
                    context, "Please choose manager", "red");
              }
              // else if (selectedPlayers.isEmpty) {
              //   return showSnackBarToast(
              //       context, "Please choose players", "red");
              // }

              final confirm =
                  await alert(context, "do you want add this team", w, h);
              if (confirm) {
                final teamModel = AslTeamModel(
                    seasonId: ref.read(selectSeason)??'',
                    group: "A",
                    draw: 0,
                    playedMatch: 0,
                    win: 0,
                    lose: 0,
                    point: 0,
                    name: teamNameController.text.trim(),
                    image: "",
                    manager: ref.read(selectmanager) ?? "",
                    delete: false,
                    search: setSearchParam(teamNameController.text.trim()),
                    players: selectedPlayers);
                final teamId = await ref
                    .read(aslRepositoryProvider)
                    .addAslTeam(teamModel, ref.read(selectSeason) ?? "");
                for (var player in selectedPlayers) {
                  await FirebaseFirestore.instance
                      .collection('players')
                      .doc(player)
                      .update({"teamId": teamId});
                }
                showSnackBarToast(
                    context, "new team added successfully", "green");

                teamNameController.clear();
                selectedPlayers.clear();
                ref.read(selectmanager.notifier).state = null;
              }
            },
            child: Container(
              height: w * 0.027,
              width: w * 0.2,
              decoration: const BoxDecoration(
                color: Palette.newColor,
              ),
              child: Center(
                child: Text(
                  ref.watch(isPlayerEdit) ? "Update Team" : "Add Team",
                  style: GoogleFonts.poppins(
                    color: Palette.whiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: w * 0.01,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayerSelection(String playerId) {
    setState(() {
      if (selectedPlayers.contains(playerId)) {
        selectedPlayers.remove(playerId);
      } else {
        selectedPlayers.add(playerId);
      }
    });
  }

  void _removePlayer(String playerId) {
    setState(() {
      selectedPlayers.remove(playerId);
    });
  }
}
