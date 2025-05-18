import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';

class SeasonOverView extends StatefulWidget {
  final SeasonModel seasonModel;
  const SeasonOverView({super.key, required this.seasonModel});

  @override
  State<SeasonOverView> createState() => _SeasonOverViewState();
}

class _SeasonOverViewState extends State<SeasonOverView> {
  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    final seasonImages = widget.seasonModel.images;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: scrHeight * 0.05, horizontal: scrWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ASL SEASON - 9",
                style: GoogleFonts.poppins(
                    fontSize: scrWidth * 0.013,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
              if (kIsWeb)
                webscreen(scrHeight, scrWidth, seasonImages)
              else
                mobilescreen(scrHeight, scrWidth, seasonImages)
            ],
          ),
        ),
      ),
    );
  }

  Widget mobilescreen(
      double scrHeight, double scrWidth, SeasonImages? seasonImages) {
    return Column(
      children: [
        Column(
          children: [
            Container(
              width: scrWidth,
              height: scrHeight * 0.5,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  image: DecorationImage(
                      image: NetworkImage(seasonImages?.winners ?? ""),
                      fit: BoxFit.cover)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text(
              "WINNERS",
              style: GoogleFonts.poppins(
                  fontSize: scrWidth * 0.02,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff808080)),
            )
          ],
        ),
        SizedBox(
          width: 20,
        ),
        Column(
          children: [
            Container(
              width: scrWidth,
              height: scrHeight * 0.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(seasonImages?.runners ?? ""),
                      fit: BoxFit.cover)),
            ),
            Padding(padding: EdgeInsets.only(top: 10)),
            Text(
              "RUNNERS",
              style: GoogleFonts.poppins(
                  fontSize: scrWidth * 0.02,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff808080)),
            )
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth ,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestplayer ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST PLAYER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: scrWidth,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.bestdefender ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST DEFENDER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestkeeper ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST GOALKEEPER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.topScorer ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "TOP SCORER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestgoal ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST GOAL",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(
                                seasonImages?.finalManofMatch ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "MAN OF THE MATCH",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.bestmanager ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST MANAGER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.fairPlaye ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "FAIR PLAY",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        // border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.matchOfficial ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "MATCH OFFICIAL",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.02,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget webscreen(
      double scrHeight, double scrWidth, SeasonImages? seasonImages) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: scrWidth * 0.5,
                    height: scrHeight * 0.5,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.winners ?? ""),
                            fit: BoxFit.cover)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "WINNERS",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.013,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: scrWidth * 0.5,
                    height: scrHeight * 0.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.runners ?? ""),
                            fit: BoxFit.cover)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "RUNNERS",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.013,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestplayer ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST PLAYER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.bestdefender ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST DEFENDER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestkeeper ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST GOALKEEPER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.topScorer ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "TOP SCORER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        //! ....
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.bestgoal ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST GOAL",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(
                                seasonImages?.finalManofMatch ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "MAN OF THE MATCH",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.bestmanager ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "BEST MANAGER",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image: NetworkImage(seasonImages?.fairPlaye ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "FAIR PLAY",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        ),
        //!jjj
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    // width: scrWidth * 0.5,
                    height: scrHeight * 0.3,
                    decoration: BoxDecoration(
                        // border: Border.all(color: Colors.white24),
                        image: DecorationImage(
                            image:
                                NetworkImage(seasonImages?.matchOfficial ?? ""),
                            fit: BoxFit.contain)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Text(
                    "MATCH OFFICIAL",
                    style: GoogleFonts.poppins(
                        fontSize: scrWidth * 0.01,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff808080)),
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
