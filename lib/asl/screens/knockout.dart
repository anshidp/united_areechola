import 'package:flutter/material.dart';

class BracketView extends StatelessWidget {
  final List<Round> rounds = [
    Round([
      Match(team1: 'Team A', team2: 'Team B', score1: 2, score2: 1, team3: 'Team E',score3: 4,score4: 6,team4: "Team 4"),
      Match(team1: 'Team C', team2: 'Team D', score1: 3, score2: 2,score3: 3,score4: 2,team3: "Team e",team4: "Team k"),
    ]),
    Round([
      Match(team1: 'Team A', team2: 'Team C', score1: 1, score2: 2,score3: 8,score4: 2,team3: "Team w",team4: "Team p"),
    ]),
  ];

  BracketView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 400,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double matchHeight = 60.0;
          final double roundWidth = 120.0;
      
          // Calculate lines between matches
          final List<Offset> lines = [];
          for (int i = 0; i < rounds.length - 1; i++) {
            final round = rounds[i];
            final nextRound = rounds[i + 1];
      
            for (int j = 0; j < nextRound.matches.length; j++) {
              final matchIndex = j * 2;
              if (matchIndex < round.matches.length) {
                final x1 = i * roundWidth + roundWidth / 2;
                final y1 = matchIndex * matchHeight + matchHeight / 2;
                final x2 = (i + 1) * roundWidth + roundWidth / 2;
                final y2 = j * matchHeight + matchHeight / 2;
      
                lines.add(Offset(x1, y1));
                lines.add(Offset(x2, y2));
              }
            }
          }
      
          return Stack(
            children: [
              // Draw lines
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: BracketPainter(lines),
              ),
              // Draw matches
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rounds.map((round) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: round.matches.map((match) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        padding: EdgeInsets.all(8.0),
                        width: roundWidth,
                        height: matchHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${match.team1} ${match.score1} - ${match.score2} ${match.team2}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class Match {
  final String team1;
  final String team2;
  final String team3;
  final String team4;
  final int score1;
  final int score2;
  final int score3;
  final int score4;

  Match({
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.team3,
    required this.team4,
    required this.score3,
    required this.score4
  });
}

class Round {
  final List<Match> matches;

  Round(this.matches);
}

class BracketPainter extends CustomPainter {
  final List<Offset> lines;

  BracketPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 219, 33, 33)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < lines.length; i += 2) {
      canvas.drawLine(lines[i], lines[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
