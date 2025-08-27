// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class AslTeamModel {
  String name;
  String image;
  String manager;
  String? teamId;
  List players;
  DocumentReference? reference;
  bool? delete;
  List? search;
  int playedMatch;
  int win;
  int lose;
  int point;
  int draw;
  String group;
  String seasonId;

  AslTeamModel(
      {required this.name,
      required this.image,
      required this.group,
      required this.seasonId,
      this.reference,
      required this.manager,
      required this.players,
      required this.playedMatch,
      required this.win,
      required this.lose,
      required this.point,
      required this.draw,
      this.delete,
      this.search,
      this.teamId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'manager': manager,
      'draw': draw,
      'teamId': teamId,
      'reference': reference,
      'players': players,
      'delete': delete ?? false,
      'search': search ?? [],
      'playedMatch': playedMatch,
      'win': win,
      'lose': lose,
      'point': point,
      'group': group,
      'seasonId': seasonId
    };
  }

  factory AslTeamModel.fromMap(Map<String, dynamic> map) {
    return AslTeamModel(
      seasonId: map['seasonId'],
      group: map['group'] ?? "",
      draw: map['draw'] ?? 0,
      playedMatch: map['playedMatch'],
      win: map['win'],
      lose: map['lose'],
      point: map['point'],
      players: map['players'] ?? [],
      name: map['name'] ?? "",
      image: map['image'] ?? "",
      manager: map['manager'] ?? "",
      teamId: map['teamId'] ?? "",
      reference: map['reference'],
      delete: map['delete'] ?? false,
      search: map['search'] ?? [],
    );
  }

  AslTeamModel copyWith({
    String? name,
    String? image,
    String? manager,
    String? teamId,
    List? players,
    DocumentReference? reference,
    bool? delete,
    List? search,
    int? playedMatch,
    int? win,
    int? lose,
    int? point,
    int? draw,
    String? group,
    String? seasonId,
  }) {
    return AslTeamModel(
      name: name ?? this.name,
      image: image ?? this.image,
      manager: manager ?? this.manager,
      teamId: teamId ?? this.teamId,
      players: players ?? this.players,
      reference: reference ?? this.reference,
      delete: delete ?? this.delete,
      search: search ?? this.search,
      playedMatch: playedMatch ?? this.playedMatch,
      win: win ?? this.win,
      lose: lose ?? this.lose,
      point: point ?? this.point,
      draw: draw ?? this.draw,
      group: group ?? this.group,
      seasonId: seasonId ?? this.seasonId,
    );
  }
}
