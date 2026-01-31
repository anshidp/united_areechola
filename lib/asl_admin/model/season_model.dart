// ignore_for_file: public_member_api_docs, sort_constructors_first

class SeasonModel {
  DateTime createdDate;
  bool delete;
  String seasonName;
  String? id;
  int year;
  int? teams;
  String? winner;
  String? runner;
  String? bestPlayer;
  DateTime endDate;
  List? search;
  SeasonImages? images;

  SeasonModel({
    this.images,
    required this.createdDate,
    required this.delete,
    required this.seasonName,
    this.id,
    required this.year,
    this.teams,
    this.winner,
    this.runner,
    this.bestPlayer,
    this.search,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdDate': createdDate,
      'delete': delete,
      'seasonName': seasonName,
      'id': id,
      'year': year,
      'teams': teams,
      'winner': winner,
      'runner': runner,
      'bestPlayer': bestPlayer,
      'endDate': endDate,
      'search': search,
      'images': SeasonImages().toMap(),
    };
  }

  factory SeasonModel.fromMap(Map<String, dynamic> map) {
    return SeasonModel(
        images: SeasonImages.fromMap(map['images']),
        createdDate: map['createdDate'].toDate(),
        delete: map['delete'] ?? "",
        seasonName: map['seasonName'] ?? "",
        id: map['id'] ?? "",
        year: map['year'] ?? 0,
        teams: map['teams'] ?? 0,
        winner: map['winner'] ?? "",
        runner: map['runner'] ?? "",
        bestPlayer: map['bestPlayer'] ?? "",
        search: map['search'] ?? [],
        endDate: map['endDate'].toDate());
  }
}

class SeasonImages {
  String? bestdefender;
  String? bestgoal;
  String? bestsave;
  String? bestkeeper;
  String? bestmanager;
  String? bestplayer;
  String? emergingPlayer;
  String? fairPlaye;
  String? finalManofMatch;
  String? matchOfficial;
  String? runners;
  String? topScorer;
  String? winners;
  SeasonImages({
    this.bestdefender,
    this.bestgoal,
    this.bestsave,
    this.bestkeeper,
    this.bestmanager,
    this.bestplayer,
    this.emergingPlayer,
    this.fairPlaye,
    this.finalManofMatch,
    this.matchOfficial,
    this.runners,
    this.topScorer,
    this.winners,
  });

  factory SeasonImages.fromMap(Map<String, dynamic> map) {
    return SeasonImages(
      bestdefender: map['bestDefender'] ?? "",
      bestgoal: map['bestGoal'] ?? "",
      bestsave: map['bestsave'] ?? "",
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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bestdefender': bestdefender,
      'bestgoal': bestgoal,
      'bestsave': bestsave,
      'bestkeeper': bestkeeper,
      'bestmanager': bestmanager,
      'bestplayer': bestplayer,
      'emergingPlayer': emergingPlayer,
      'fairPlaye': fairPlaye,
      'finalManofMatch': finalManofMatch,
      'matchOfficial': matchOfficial,
      'runners': runners,
      'topScorer': topScorer,
      'winners': winners,
    };
  }
}

class SeasonAward {
  final String id;
  final String key;
  final String title;
  final String imageUrl;
  final bool enabled;

  SeasonAward({
    required this.id,
    required this.key,
    required this.title,
    required this.imageUrl,
    required this.enabled,
  });

  factory SeasonAward.fromMap(Map<String, dynamic> data) {
    return SeasonAward(
      id: data['id'] ?? "",
      key: data['key'] ?? '',
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      enabled: data['enabled'] ?? true,
    );
  }
}
