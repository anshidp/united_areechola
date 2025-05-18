import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/screens/add_players.dart';
import 'package:united_areechola/asl_admin/screens/add_season.dart';
import 'package:united_areechola/asl_admin/screens/add_team.dart';
import 'package:united_areechola/asl_admin/screens/show_matches.dart';

class AslAdmin extends StatefulWidget {
  const AslAdmin({super.key});

  @override
  State<AslAdmin> createState() => _AslAdminState();
}

class _AslAdminState extends State<AslAdmin> {
  final List<Widget> sections = [
    AddNewMatches(),
    AddPlayers(),
    AddTeams(),
    AddSeason()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: sections.length,
        child: Column(
          children: [
            TabBar(
                indicatorColor: Colors.black,
                labelColor: Colors.black, // Text color for the selected tab
                unselectedLabelColor: const Color.fromARGB(
                    255, 189, 189, 189), // Text color for unselected tabs
                labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(icon: Icon(Icons.group), text: "AddMatches"),
                  Tab(icon: Icon(Icons.group), text: "AddPlayers"),
                  Tab(icon: Icon(Icons.star), text: "AddTeams"),
                  Tab(icon: Icon(Icons.ac_unit_rounded), text: "AddSeason"),
                ]),
            Expanded(
                child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: sections))
          ],
        ),
      ),
    );
  }
}
