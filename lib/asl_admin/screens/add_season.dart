import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddSeason extends ConsumerStatefulWidget {
  const AddSeason({super.key});

  @override
  ConsumerState<AddSeason> createState() => _AddSeasonState();
}

class _AddSeasonState extends ConsumerState<AddSeason> {
  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final endDateController = TextEditingController();

  final endDate = StateProvider<DateTime?>((ref) => null);
  final selectedTeams = [];
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  void getTeams() async {
    ref.read(teams.notifier).state =
        await ref.read(aslRepositoryProvider).getAllTeams();
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
    return Scaffold(
      body: Column(
        children: [
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
                      controller: nameController,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Palette.greyColor,
                            fontSize: w * 0.008,
                          ),
                          hintText: "Season Name",
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
                    TextFormField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onTap: () async {},
                      style: GoogleFonts.poppins(
                          color: Palette.blackColor,
                          fontSize: w * 0.008,
                          fontWeight: FontWeight.w400),
                      controller: yearController,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Palette.greyColor,
                            fontSize: w * 0.008,
                          ),
                          hintText: "Year",
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
                    hint: const Text("Select Teams"),
                    items: ref.watch(teams).entries.map((entry) {
                      // Only include players with an empty `teamId`

                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Checkbox(
                              value: selectedTeams.contains(entry.key),
                              onChanged: (_) {
                                _togglePlayerSelection(entry.key);
                              },
                            ),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(), // Filter out null items
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          if (!selectedTeams.contains(value)) {
                            selectedTeams.add(value);
                          }
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: w * 0.05),
              SizedBox(
                // height: w * 0.12,
                width: w * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                            initialDate: DateTime.now(),
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2400));
                        if (selectedDate != null) {
                          ref.read(endDate.notifier).state = selectedDate;
                          endDateController.text =
                              DateFormat("dd-MM-YYYY").format(selectedDate);
                        }
                      },
                      style: GoogleFonts.poppins(
                          color: Palette.blackColor,
                          fontSize: w * 0.008,
                          fontWeight: FontWeight.w400),
                      controller: endDateController,
                      decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: Palette.greyColor,
                            fontSize: w * 0.008,
                          ),
                          hintText: "EndDate",
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
            ],
          ),
          Padding(padding: EdgeInsets.only(top: h * 0.04)),
          InkWell(
            onTap: () async {
              if (nameController.text.trim().isEmpty) {
                return showSnackBarToast(context, "Please enter  name", "red");
              } else if (yearController.text.isEmpty) {
                return showSnackBarToast(context, "Please enter year", "red");
              } else if (endDateController.text.isEmpty) {
                return showSnackBarToast(
                    context, "Please enter endDate", "red");
              }

              final confirm =
                  await alert(context, "do you want add season", w, h);
              if (confirm) {
                final seasonModel = SeasonModel(
                    bestPlayer: "",
                    runner: "",
                    teams: selectedTeams,
                    winner: "",
                    endDate: ref.read(endDate)!,
                    seasonName: nameController.text.trim(),
                    delete: false,
                    search: setSearchParam(nameController.text.trim()),
                    createdDate: DateTime.now(),
                    year: int.parse(yearController.text.trim()));
                ref.read(aslRepositoryProvider).addNewSeason(seasonModel);
                showSnackBarToast(
                    context, "Season added successfully", "green");

                nameController.clear();
                ref.read(endDate.notifier).state = null;
                selectedTeams.clear();
                yearController.clear();
                endDateController.clear();
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
                  "Add Season",
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
      if (selectedTeams.contains(playerId)) {
        selectedTeams.remove(playerId);
      } else {
        selectedTeams.add(playerId);
      }
    });
  }

  void _removePlayer(String playerId) {
    setState(() {
      selectedTeams.remove(playerId);
    });
  }
}
