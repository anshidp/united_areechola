import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/common/common.dart';

class Players extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const Players({super.key, required this.seasonModel});

  @override
  ConsumerState<Players> createState() => _PlayersState();
}

class _PlayersState extends ConsumerState<Players> {
  final style =
      GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600);

  final searchPlayers = StateProvider<String>((ref) => "");

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 20)),
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
                    controller:
                        TextEditingController(text: ref.read(searchPlayers)),
                    decoration: InputDecoration(
                        hintStyle: GoogleFonts.poppins(
                          color: Palette.greyColor,
                          fontSize: w * 0.006,
                        ),
                        hintText: "Search players",
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
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        SizedBox(
          width: double.infinity,
          child: Consumer(builder: (context, ref, _) {
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
                    .map(
                      (event) => event.docs
                          .map(
                            (e) => PlayerModel.fromMap(e.data()),
                          )
                          .toList(),
                    ),
                builder: (context, snapshot) {
                  print(snapshot.error);
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No data"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final players = (snapshot.data ?? [])
                    ..sort((a, b) => (b.statics['goal'] ?? 0)
                        .compareTo((a.statics['goal'] ?? 0)));
                  return Container(
                    color: Color(0xFFF2F2F2), // Background color
                    padding:
                        const EdgeInsets.all(16.0), // Padding around the table
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white, // Table container color
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Subtle shadow
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: DataTable(
                          columnSpacing: 15,
                          border: TableBorder(
                            top: BorderSide.none,
                            bottom: BorderSide.none,
                            left: BorderSide.none,
                            right: BorderSide.none,
                            horizontalInside: BorderSide(
                              color: Colors
                                  .grey.shade300, // Divider color for rows
                              width: 0.5,
                            ),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Name",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Team",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Goals",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Assist",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Yellow",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Red",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: List.generate(players.length, (index) {
                            final player = players[index];
                            final playerStat = player.statics;
                            return DataRow(cells: [
                              DataCell(Row(
                                children: [
                                  SizedBox(
                                      width: 30,
                                      height: 35,
                                      child: Image.network(player.image)),
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: w*0.2),
                                    child: Text(
                                      player.name,
                                      style: style,
                                    ),
                                  ),
                                ],
                              )),
                              DataCell(FutureBuilder(
                                  future: FirebaseFirestore.instance
                                      .collection('seasons')
                                      .doc(widget.seasonModel.id)
                                      .collection('teams')
                                      .doc(player.teamId)
                                      .get(),
                                  builder: (context, snap) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox();
                                    }
                                    return Text(
                                      snap.data?['name'] ?? "",
                                      style: style,
                                    );
                                  })),
                              DataCell(
                                Text(
                                  (playerStat['goal'] ?? 0).toString(),
                                  style: style,
                                ),
                              ),
                              DataCell(Text(
                                (playerStat['assist'] ?? 0).toString(),
                                style: style,
                              )),
                              DataCell(Text(
                                (playerStat['yelloCard'] ?? 0).toString(),
                                style: style,
                              )),
                              DataCell(Text(
                                (playerStat['redCard'] ?? 0).toString(),
                                style: style,
                              )),
                              // DataCell(Text(playerStat['goal'])),
                            ]);
                          })),
                    ),
                  );
                });
          }),
        ),
      ],
    );
  }
}
