import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/screens/add_awards.dart';
import 'package:united_areechola/asl_admin/screens/add_manager.dart';
import 'package:united_areechola/asl_admin/screens/add_matches.dart';
import 'package:united_areechola/asl_admin/screens/add_players.dart';
import 'package:united_areechola/asl_admin/screens/add_season.dart';
import 'package:united_areechola/asl_admin/screens/add_team.dart';

class AslAdmin extends StatefulWidget {
  const AslAdmin({super.key});

  @override
  State<AslAdmin> createState() => _AslAdminState();
}

class _AslAdminState extends State<AslAdmin> {
  final List<Widget> sections = [
    AddSeason(),
    AddManager(),
    AddTeams(),
    AddPlayers(),
    AddMatches(),
    AddAwardScreen()
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
                  Tab(icon: Icon(Icons.ac_unit_rounded), text: "Add Season"),
                  Tab(icon: Icon(Icons.star), text: "Add Manager"),
                  Tab(icon: Icon(Icons.star), text: "Add Teams"),
                  Tab(icon: Icon(Icons.group), text: "Add Players"),
                  Tab(icon: Icon(Icons.group), text: "Add Matches"),
                  Tab(icon: Icon(Icons.star), text: "Add Awards"),
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
