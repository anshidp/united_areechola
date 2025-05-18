import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/common/common.dart';

class TeamTable extends StatefulWidget {
  final SeasonModel seasonModel;
  const TeamTable({super.key, required this.seasonModel});

  @override
  State<TeamTable> createState() => _TeamTableState();
}

class _TeamTableState extends State<TeamTable> {
  final style =
      GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AslTeamModel>>(
      stream: FirebaseFirestore.instance
          .collection('seasons')
          .doc(widget.seasonModel.id)
          .collection('teams')
          .where('delete', isEqualTo: false)
          .snapshots()
          .map(
            (event) =>
                event.docs.map((e) => AslTeamModel.fromMap(e.data())).toList(),
          ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Text("Error loading teams"),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text("No data"),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final teams = (snapshot.data ?? [])
          ..sort((a, b) => b.point.compareTo(a.point));

        final groupATeams = teams.where((team) => team.group == 'A').toList();
        final groupBTeams = teams.where((team) => team.group == 'B').toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupTable('A', groupATeams),
              const SizedBox(height: 20),
              _buildGroupTable('B', groupBTeams),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupTable(String groupName, List<AslTeamModel> teams) {
    return Container(
      color: Color(0xFFF2F2F2), // Background color
      padding: const EdgeInsets.all(16.0), // Padding around the table
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white, // Table container color
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // Subtle shadow
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: DataTable(
              columnSpacing: 15,
              border: TableBorder(
                horizontalInside: BorderSide.none,
                verticalInside: BorderSide.none,
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    "Team",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "PL",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "W",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "L",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "D",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "PTS",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List.generate(teams.length, (index) {
                final team = teams[index];
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 35,
                        child: Image.asset(ImageConstants.clubLogo),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        team.name,
                        style: style,
                      ),
                    ],
                  )),
                  DataCell(Text(
                    team.playedMatch.toString(),
                    style: style,
                  )),
                  DataCell(Text(
                    team.win.toString(),
                    style: style,
                  )),
                  DataCell(Text(
                    team.lose.toString(),
                    style: style,
                  )),
                  DataCell(Text(
                    team.draw.toString(),
                    style: style,
                  )),
                  DataCell(Text(
                    team.point.toString(),
                    style: style,
                  )),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
