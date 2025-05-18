import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class AddPlayers extends ConsumerStatefulWidget {
  const AddPlayers({super.key});

  @override
  ConsumerState<AddPlayers> createState() => _AddPlayersState();
}

class _AddPlayersState extends ConsumerState<AddPlayers> {
  final selectPossition = StateProvider<String?>((ref) => null);
  final selectPossitionShort = StateProvider<String?>((ref) => null);
  final selectTeam = StateProvider<String?>((ref) => null);
  final selectPlayerModel = StateProvider<PlayerModel?>((ref) => null);
  final searchPlayers = StateProvider<String>((ref) => "");
  final teams = StateProvider<Map<String, dynamic>>((ref) => {});
  final seasons = StateProvider<Map<String, dynamic>>((ref) => {});
  final selectSeason = StateProvider<String?>((ref) => null);
  final isPlayerEdit = StateProvider<bool>((ref) => false);
  final nameController = TextEditingController();
  final auctionPriceController = TextEditingController();
  String? downloadUrl;
  final List<String> possitoins = [
    "Center-Back (CB)",
    "Left-Back (LB)",
    "Right-Back (RB)",
    "Central Midfielder (CM)",
    "Center Forward (CF)",
    "Left Midfielder (LM)",
    "Right Winger (RW)",
    "Left Winger (LW)",
    "Goalkeeper",
  ];

  Future<String?> pickAndUploadFile(BuildContext context) async {
    String? imageUrl;
    final filePickerResult = await FilePicker.platform.pickFiles();

    if (filePickerResult != null) {
      final platformFile = filePickerResult.files.single;
      final fileBytes = platformFile.bytes;

      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask =
          storageRef.child('players/${platformFile.name}').putData(fileBytes!);

      await uploadTask;

      // Download imageUrl
      imageUrl = await storageRef
          .child('players/${platformFile.name}')
          .getDownloadURL();

      return imageUrl;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            MouseRegion(
              cursor: WidgetStateMouseCursor.clickable,
              hitTestBehavior: HitTestBehavior.deferToChild,
              child: GestureDetector(
                onTap: () async {
                  downloadUrl = await pickAndUploadFile(context);

                  setState(() {});
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: w * 0.05,
                      child: (downloadUrl != null ||
                              (downloadUrl ?? "").isNotEmpty)
                          ? CircleAvatar(
                              radius: w * 0.045,
                              backgroundImage: NetworkImage(downloadUrl!))
                          : const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
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
                            hintText: "Player Name",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
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
                        "Possition",
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
                              "Select Possition",
                              style: GoogleFonts.poppins(
                                color: Color(0xffB6B6B6),
                                fontSize: w * 0.008,
                              ),
                            ),
                            value: (ref.watch(selectPossition) ?? "").isEmpty
                                ? null
                                : ref.read(selectPossition),
                            items: possitoins
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
                              ref.read(selectPossition.notifier).state = value;
                              if ((value ?? "").contains("()")) {
                                String? shortForm = (value ?? "")
                                    .split('(')[1]
                                    .replaceAll(')', '');
                                ref.read(selectPossitionShort.notifier).state =
                                    shortForm;
                              }
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
                        "Select Team",
                        style: GoogleFonts.poppins(
                          color: Color(0xffB6B6B6),
                          fontSize: w * 0.008,
                        ),
                      ),
                      value: (ref.watch(selectTeam) ?? "").isEmpty
                          ? null
                          : ref.read(selectTeam),
                      items: ref
                          .watch(teams)
                          .entries
                          .map(
                            (team) => DropdownMenuItem<String>(
                              value: team.key,
                              child: Text(
                                team.value,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: w * 0.008,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        ref.read(selectTeam.notifier).state = value;
                      }),
                ),
                SizedBox(width: w * 0.05),
                SizedBox(
                  // height: w * 0.12,
                  width: w * 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onTap: () async {},
                        style: GoogleFonts.poppins(
                            color: Palette.blackColor,
                            fontSize: w * 0.008,
                            fontWeight: FontWeight.w400),
                        controller: auctionPriceController,
                        decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(
                              color: Palette.greyColor,
                              fontSize: w * 0.008,
                            ),
                            hintText: "Auction Price",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
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
                  return showSnackBarToast(
                      context, "Please enter  name", "red");
                } else if ((ref.read(selectPossition) ?? "").isEmpty) {
                  return showSnackBarToast(
                      context, "Please choose possition", "red");
                }
                // else if (selectedPlayers.isEmpty) {
                //   return showSnackBarToast(
                //       context, "Please choose players", "red");
                // }

                if (ref.read(isPlayerEdit)) {
                  final confirm = await alert(
                      context, "do you want update this player", w, h);
                  if (confirm) {
                    final copy = ref.read(selectPlayerModel)?.copyWith(
                        price: double.parse(auctionPriceController.text.trim()),
                        search: setSearchParam(nameController.text.trim()),
                        name: nameController.text.trim(),
                        image: downloadUrl,
                        possition: ref.read(selectPossition),
                        possitionShort: ref.read(selectPossitionShort),
                        teamId: ref.read(selectTeam));
                    ref.read(aslRepositoryProvider).updatePlayer(
                        ref.read(selectPlayerModel)?.playerId ?? "", copy!);

                    if (context.mounted) {
                      showSnackBarToast(
                          context,
                          "${nameController.text.trim()} updated successfully",
                          "green");
                    }

                    nameController.clear();
                    ref.read(selectPossition.notifier).state = null;
                    ref.read(selectTeam.notifier).state = null;
                    auctionPriceController.clear();
                  }
                } else {
                  final confirm =
                      await alert(context, "do you want add this player", w, h);
                  if (confirm) {
                    final playerModel = PlayerModel(
                        appearences: 0,
                        price: double.parse(auctionPriceController.text.trim()),
                        possitionShort: ref.read(selectPossitionShort) ?? "",
                        teamId: ref.read(selectTeam) ?? "",
                        name: nameController.text.trim(),
                        image: downloadUrl ?? "",
                        possition: ref.read(selectPossition) ?? "",
                        delete: false,
                        search: setSearchParam(nameController.text.trim()),
                        createdDate: DateTime.now(),
                        statics: {
                          "goal": 0,
                          "assist": 0,
                          "yelloCard": 0,
                          "redCard": 0,
                          "bestPlayer": 0,
                          "bestGoal": 0
                        });
                    ref.read(aslRepositoryProvider).addNewPlayer(playerModel);
                    showSnackBarToast(
                        context,
                        "${nameController.text.trim()} added successfully",
                        "green");

                    nameController.clear();
                    ref.read(selectPossition.notifier).state = null;
                    ref.read(selectTeam.notifier).state = null;
                    auctionPriceController.clear();
                  }
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
                    ref.watch(isPlayerEdit) ? "Update Player" : "Add Player",
                    style: GoogleFonts.poppins(
                      color: Palette.whiteColor,
                      fontWeight: FontWeight.w600,
                      fontSize: w * 0.01,
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Padding(
              padding: EdgeInsets.only(right: w * 0.014),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  // height: w * 0.12,
                  width: w * 0.2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        onChanged: (value) {
                          ref.read(searchPlayers.notifier).state = value;
                        },
                        style: GoogleFonts.poppins(
                            color: Palette.blackColor,
                            fontSize: w * 0.008,
                            fontWeight: FontWeight.w400),
                        controller: TextEditingController(
                            text: ref.read(searchPlayers)),
                        decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(
                              color: Palette.greyColor,
                              fontSize: w * 0.008,
                            ),
                            hintText: "Search players",
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(w * 0.02),
                                borderSide: const BorderSide(
                                    color: Palette.borderColor))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            Consumer(builder: (context, ref, _) {
              ref.watch(searchPlayers);
              return StreamBuilder<List<PlayerModel>>(
                  stream: FirebaseFirestore.instance
                      .collection('players')
                      .where('delete', isEqualTo: false)
                      .where('search',
                          arrayContains: ref.read(searchPlayers).isEmpty
                              ? null
                              : ref.read(searchPlayers).toUpperCase())
                      .snapshots()
                      .map((event) => event.docs
                          .map(
                            (e) => PlayerModel.fromMap(e.data()),
                          )
                          .toList()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print("Error: ${snapshot.error}");
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('Loading data...');
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("No players found"),
                      );
                    }

                    final players = snapshot.data ?? [];

                    return players.isEmpty
                        ? const Center(child: Text('No Data'))
                        : DataTable(
                            checkboxHorizontalMargin: Checkbox.width,
                            dividerThickness: 0.5,
                            showCheckboxColumn: true,
                            horizontalMargin: 25,
                            headingTextStyle: GoogleFonts.urbanist(
                                fontWeight: FontWeight.w500,
                                fontSize: w * 0.01),
                            dataTextStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: w * 0.009),
                            headingRowColor:
                                WidgetStateProperty.all(Palette.whiteColor),
                            columns: const [
                              DataColumn(
                                  label: Text(
                                "Sl No",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "image",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "Player Name",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                " Possition",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "Team",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "Auction Price",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "Edit",
                              )),
                              DataColumn(
                                  // headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                "Delete",
                              )),
                            ],
                            rows: List.generate(
                              players.length,
                              (index) {
                                final player = players[index];
                                return DataRow(
                                    color: index.isOdd
                                        ? WidgetStateProperty.all(Palette
                                            .lightPurple
                                            .withOpacity(0.2))
                                        : WidgetStateProperty.all(
                                            Palette.whiteColor),
                                    cells: [
                                      DataCell(SelectableText(
                                        '${index + 1}',
                                      )),
                                      DataCell(player.image.isNotEmpty
                                          ? Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          player.image),
                                                      fit: BoxFit.cover)),
                                            )
                                          : SizedBox()),
                                      DataCell(
                                        Text(
                                          player.name,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          player.possition,
                                        ),
                                      ),
                                      DataCell(
                                        Text(ref.read(teams)[player.teamId] ??
                                            ""),
                                      ),
                                      DataCell(
                                        Text(player.price.toString()),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            ref
                                                .read(isPlayerEdit.notifier)
                                                .state = true;
                                            ref
                                                .read(
                                                    selectPlayerModel.notifier)
                                                .state = player;
                                            downloadUrl = player.image;
                                            auctionPriceController.text =
                                                player.price.toString();
                                            nameController.text = player.name;
                                            ref
                                                .read(selectPossition.notifier)
                                                .state = player.possition;
                                            ref
                                                .read(selectTeam.notifier)
                                                .state = player.teamId;
                                          },
                                          child: const Text(
                                            "Update",
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        InkWell(
                                          onTap: () async {},
                                          child: const Icon(
                                            Icons.delete,
                                            color: Palette.newColor,
                                          ),
                                        ),
                                      )
                                    ]);
                              },
                            ));
                  });
            }),
          ],
        ),
      ),
    );
  }
}
