// ignore_for_file: public_member_api_docs, sort_constructors_first
class MatchModel {
  String? matchId;
  String teamA;
  String teamB;
  DateTime? createdDate;
  DateTime kickoff;
  int teamAscore;
  int teamBscore;
  String status;
  bool delete;
  List goals;
  String stage;
  bool? ispenalty;
  String? winner;
  String seasonId;

  MatchModel(
      {this.matchId,
      required this.seasonId,
      required this.teamA,
      required this.teamB,
      required this.stage,
      this.createdDate,
      required this.kickoff,
      required this.status,
      required this.teamAscore,
      required this.goals,
      required this.delete,
      required this.ispenalty,
      required this.winner,
      required this.teamBscore});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'matchId': matchId,
      'teamA': teamA,
      'teamB': teamB,
      'createdDate': createdDate,
      'kickoff': kickoff,
      'teamAscore': teamAscore,
      'teamBscore': teamBscore,
      'winner': winner,
      'status': status,
      'delete': delete,
      'goals': [],
      'stage': stage,
      'ispenalty': ispenalty,
      'seasonId': seasonId
    };
  }

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
        seasonId: map['seasonId'] ?? "",
        winner: map['winner'] ?? "",
        ispenalty: map['ispenalty'] ?? false,
        stage: map['stage'] ?? "",
        goals: map['goals'] ?? [],
        delete: map['delete'] ?? false,
        matchId: map['matchId'] ?? "",
        teamA: map['teamA'] ?? "",
        teamB: map['teamB'] ?? "",
        createdDate: map['createdDate']?.toDate(),
        kickoff: map['kickoff'].toDate(),
        teamAscore: map['teamAscore'] ?? 0,
        teamBscore: map['teamBscore'] ?? 0,
        status: map['status'] ?? "");
  }
}
