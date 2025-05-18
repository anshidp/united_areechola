import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/asl_admin/repository/repository.dart';

class Teams extends ConsumerStatefulWidget {
  final SeasonModel seasonModel;
  const Teams({super.key, required this.seasonModel});

  @override
  ConsumerState<Teams> createState() => _TeamsState();
}

class _TeamsState extends ConsumerState<Teams> {
  final teamsdetails = StateProvider<Map<String, dynamic>>((ref) => {});
  void getTeams() async {
    ref.read(teamsdetails.notifier).state = await ref
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
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: scrHeight * 0.05, horizontal: scrWidth * 0.1),
          child: Column(
            children: [
              Text(
                "ASL SEASON - 9",
                style: GoogleFonts.poppins(
                    fontSize: scrWidth * 0.03,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
              SizedBox(
                width: double.infinity,
                height: 500,
                child: StreamBuilder<List<AslTeamModel>>(
                    stream: FirebaseFirestore.instance
                        .collection('seasons')
                        .doc(widget.seasonModel.id)
                        .collection('teams')
                        .where('delete', isEqualTo: false)
                        .snapshots()
                        .map((event) => event.docs
                            .map((e) => AslTeamModel.fromMap(e.data()))
                            .toList()),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Text("No data found"),
                        );
                      }
                      final teams = snapshot.data ?? [];
                      return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing: scrWidth * 0.02,
                                  mainAxisSpacing: scrWidth * 0.02,
                                  childAspectRatio: 0.7,
                                  crossAxisCount: 1),
                          itemCount: teams.length,
                          itemBuilder: (ctx, index) {
                            final team = teams[index];
                            return Consumer(builder: (context, ref, _) {
                              ref.watch(teamsdetails);
                              return Column(
                                children: [
                                  Container(
                                    width: scrWidth,
                                    height: scrHeight * 0.5,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.white24),
                                        image: DecorationImage(
                                            image: NetworkImage(team.image),
                                            fit: BoxFit.cover)),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 10)),
                                  Text(
                                    ref.read(teamsdetails)[team.teamId] ?? "",
                                    style: GoogleFonts.poppins(
                                        fontSize: scrWidth * 0.03,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xff808080)),
                                  )
                                ],
                              );
                            });
                          });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
