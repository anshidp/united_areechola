// ignore_for_file: public_member_api_docs, sort_constructors_first
class ManagerModel {
  DateTime createdDate;
  bool delete;
  String seasonName;
  String managerName;
  String? id;
  String? team;
  List? players;

  ManagerModel({
    required this.managerName,
    this.players,
    this.team,
    required this.createdDate,
    required this.delete,
    required this.seasonName,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'managerName': managerName,
      'createdDate': createdDate,
      'delete': delete,
      'seasonName': seasonName,
      'id': id,
      'team': team ?? "",
      'players': players ?? [],
    };
  }

  factory ManagerModel.fromMap(Map<String, dynamic> map) {
    return ManagerModel(
      managerName: map['managerName'] ?? "",
      createdDate: map['createdDate'].toDate(),
      delete: map['delete'] ?? "",
      seasonName: map['seasonName'] ?? "",
      id: map['id'] ?? "",
      team: map['team'] ?? "",
      players: map['players'] ?? [],
    );
  }
}

class SeasonImages {
  String bestdefender;
  String bestgoal;
  String bestsave;
  String bestkeeper;
  String bestmanager;
  String bestplayer;
  String emergingPlayer;
  String fairPlaye;
  String finalManofMatch;
  String matchOfficial;
  String runners;
  String topScorer;
  String winners;
  SeasonImages({
    required this.bestdefender,
    required this.bestgoal,
    required this.bestsave,
    required this.bestkeeper,
    required this.bestmanager,
    required this.bestplayer,
    required this.emergingPlayer,
    required this.fairPlaye,
    required this.finalManofMatch,
    required this.matchOfficial,
    required this.runners,
    required this.topScorer,
    required this.winners,
  });

  factory SeasonImages.fromMap(Map<String, dynamic> map) {
    return SeasonImages(
      bestdefender: map['bestDefender'] ?? "",
      bestgoal: map['bestGoal'] ?? "",
      bestsave: map['bestSave'] ?? "",
      bestkeeper: map['bestkeeper'] ?? "",
      bestmanager: map['bestmanager'] ?? "",
      bestplayer: map['bestplayer'] ?? "",
      emergingPlayer: map['emergingPlayer'] ?? "",
      fairPlaye: map['fairplay'] ?? "",
      finalManofMatch: map['finalmanOftheMatch'] ?? "",
      matchOfficial: map['matchOfficial'] ?? "",
      runners: map['runners'] ?? "",
      topScorer: map['topScorer'] ?? "",
      winners: map['winners'] ?? "",
    );
  }
}
