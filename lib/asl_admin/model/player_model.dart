// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerModel {
  String name;
  String image;
  String possition;
  String possitionShort;
  String teamId;
  Map<String, dynamic> statics;
  String? playerId;
  DocumentReference? reference;
  DateTime createdDate;
  bool? delete;
  List? search;
  double price;
  int appearences;

  PlayerModel(
      {required this.name,
      required this.price,
      required this.appearences,
      required this.image,
      required this.createdDate,
      this.delete,
      this.playerId,
      this.reference,
      required this.possition,
      required this.possitionShort,
      this.search,
      required this.statics,
      required this.teamId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'image': image,
      'possition': possition,
      'teamId': teamId,
      'statics': statics,
      'playerId': playerId,
      'reference': reference,
      'createdDate': createdDate,
      'delete': delete,
      'search': search ?? [],
      'possitionShort': possitionShort,
      'price': price,
      'appearences': appearences
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
        appearences: map['appearences'] ?? 0,
        price: map['price'].toDouble(),
        possitionShort: map['possitionShort'] ?? "",
        createdDate: map['createdDate']?.toDate(),
        statics: map['statics'] ?? {},
        name: map['name'] ?? "",
        image: map['image'] ?? "",
        possition: map['possition'] ?? "",
        teamId: map['teamId'] ?? "",
        playerId: map['playerId'] ?? "",
        reference: map['reference'],
        delete: map['delete'] ?? false,
        search: map['search'] ?? []);
  }

  PlayerModel copyWith({
    String? name,
    String? image,
    String? possition,
    String? possitionShort,
    String? teamId,
    Map<String, dynamic>? statics,
    String? playerId,
    DocumentReference? reference,
    DateTime? createdDate,
    bool? delete,
    List? search,
    double? price,
    int? appearences
  }) {
    return PlayerModel(
      appearences: appearences??this.appearences,
      price: price ?? this.price,
      name: name ?? this.name,
      image: image ?? this.image,
      possition: possition ?? this.possition,
      possitionShort: possitionShort ?? this.possitionShort,
      teamId: teamId ?? this.teamId,
      statics: statics ?? this.statics,
      playerId: playerId ?? this.playerId,
      reference: reference ?? this.reference,
      createdDate: createdDate ?? this.createdDate,
      delete: delete ?? this.delete,
      search: search ?? this.search,
    );
  }
}
