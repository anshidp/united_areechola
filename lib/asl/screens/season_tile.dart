import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';
import 'package:united_areechola/common/common.dart';

class SeasonTile extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;

  const SeasonTile({super.key, required this.seasonModel});

  @override
  ConsumerState<SeasonTile> createState() => _SeasonTileState();
}

class _SeasonTileState extends ConsumerState<SeasonTile> {
  double? value;
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
    final textstyle = GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 115, 110, 110));
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade800)),
      child: Consumer(builder: (context, ref, _) {
        ref.watch(teams);
        return Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: scrHeight * 0.1,
                  child: Image.asset(ImageConstants.clubLogo),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: SizedBox(
                    width: scrWidth * 0.5,
                    child: Text(
                      "ASL ${widget.seasonModel.seasonName.toUpperCase()}",
                      style: GoogleFonts.inter(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // isAdmin
                //     ? PopupMenuButton<int>(
                //         surfaceTintColor: Colors.black,
                //         shadowColor: Colors.white,
                //         color: Colors.black,
                //         tooltip: "",
                //         icon: const Icon(
                //           Icons.more_vert_rounded,
                //           color: Colors.black,
                //         ),
                //         onSelected: (value) async {
                //           if (value == 1) {
                //             bool delete = await addDialog(
                //                 context, "Do you want delete this season?");
                //             if (delete) {
                //               // deleteEvent(eventId, context);
                //             }
                //           }
                //         },
                //         itemBuilder: (context) {
                //           return [
                //             const PopupMenuItem(
                //                 value: 1,
                //                 child: Text(
                //                   "Delete",
                //                   style: TextStyle(
                //                       fontFamily: "Inter",
                //                       color: Colors.white,
                //                       fontSize: 13,
                //                       fontWeight: FontWeight.w500),
                //                 ))
                //           ];
                //         })
                //     : const SizedBox()
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date", style: textstyle),
                Text(
                  DateFormat("dd-MMM-yyyy")
                      .format(widget.seasonModel.createdDate),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xff478F8F)),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Teams", style: textstyle),
                Text((widget.seasonModel.teams ?? []).length.toString(),
                    style: textstyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Winners", style: textstyle),
                Text(ref.read(teams)[widget.seasonModel.winner ?? ""] ?? "",
                    style: textstyle)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Runners", style: textstyle),
                Text(ref.read(teams)[widget.seasonModel.runner ?? ""] ?? "",
                    style: textstyle)
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        );
      }),
    );
  }
}
