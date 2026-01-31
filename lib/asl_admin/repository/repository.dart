import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:united_areechola/asl_admin/model/goal_model.dart';
import 'package:united_areechola/asl_admin/model/manager_model.dart';
import 'package:united_areechola/asl_admin/model/match_model.dart';
import 'package:united_areechola/asl_admin/model/player_model.dart';
import 'package:united_areechola/asl_admin/model/season_model.dart';
import 'package:united_areechola/asl_admin/model/team_model.dart';
import 'package:united_areechola/asl_admin/screens/add_matches.dart';
import 'package:united_areechola/common/common.dart';
import 'package:united_areechola/utils/constants.dart';

final aslRepositoryProvider = Provider((ref) => AslAdminRepository());

enum PlayerTypes { goals, assist, yellow, red, penalty }

abstract class AslAdminRepo {
  Future<void> addNewPlayer(PlayerModel playerModel, String season);
  Future<void> addNewMatch(MatchModel matchmodel, String seasonId);
  Future<void> addNewSeason(SeasonModel seasonModel);
  Future<void> addNewManager(ManagerModel managermodel, String season);
  Future<void> updatePlayer(
      String playerId, PlayerModel playerModel, String season);
  Future<String> addAslTeam(AslTeamModel teamModel, String seasonId);
  Future<Map<String, dynamic>> getPlayers();
  Future<Map<String, dynamic>> getTeams(String seasonId);
  Future<List<PlayerModel>> getTeamPlayers(
      String teamA, String teamB, String seasonId);
  void updatePlayerStat(
      {required String playerId,
      required String type,
      required String matchId,
      required String selectTeam,
      required String teamA,
      required String assister,
      required String seasonId,
      required String teamB,
      required String playerName,
      required bool isPenaltyGoal});
  void updateMatchStat(
      {required String matchId,
      required String teamA,
      required String teamB,
      required int teamBscore,
      required int teamAscore,
      required String currentStage,
      required BuildContext context,
      required String seasonId,
      required String winner,
      required double w,
      required double h});
  Future<List<PlayerModel>> getSpecificTeamPlayers(
      {required String teamId, required String seasonId});
  Future<List<GoalModel>> getgoalByteam(
      {required String matchId, required String team, required String season});
}

class AslAdminRepository implements AslAdminRepo {
  @override
  Future<void> addNewPlayer(PlayerModel playerModel, String season) async {
    try {
      final playerSnap = FirebaseFirestore.instance
          .collection("seasons")
          .doc(season)
          .collection("players")
          .doc();
      playerModel.playerId = playerSnap.id;
      playerModel.reference = playerSnap;
      playerSnap.set(playerModel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<Map<String, PlayerModel>> getPlayers() async {
    print("player work");
    try {
      Map<String, PlayerModel> players = {};
      final playersSnap =
          await FirebaseFirestore.instance.collection("players").get();

      if (playersSnap.docs.isNotEmpty) {
        for (var player in playersSnap.docs) {
          players[player.id] = PlayerModel.fromMap(player.data());
        }
        return players;
      }
      return {};
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<Map<String, ManagerModel>> getManagers(
      {required String season}) async {
    try {
      Map<String, ManagerModel> managers = {};
      final managerSnap = await FirebaseFirestore.instance
          .collection("seasons")
          .doc(season)
          .collection("managers")
          .get();

      if (managerSnap.docs.isNotEmpty) {
        for (var manager in managerSnap.docs) {
          managers[manager.id] = ManagerModel.fromMap(manager.data());
        }
        return managers;
      }
      return {};
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  @override
  Future<String> addAslTeam(AslTeamModel teamModel, String seasonId) async {
    try {
      final teamSnap = FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection("teams")
          .doc();
      teamModel.teamId = teamSnap.id;
      teamModel.reference = teamSnap;
      teamSnap.set(teamModel.toMap());
      return teamSnap.id;
    } catch (e) {
      debugPrint(e.toString());
      throw e.toString();
    }
  }

  @override
  Future<Map<String, dynamic>> getTeams(String seasonId) async {
    try {
      Map<String, dynamic> players = {};
      final teamSnap = await FirebaseFirestore.instance
          .collection("seasons")
          .doc(seasonId)
          .collection("teams")
          .get();
      if (teamSnap.docs.isNotEmpty) {
        for (var team in teamSnap.docs) {
          players[team.id] = team['name'] ?? "";
        }
        return players;
      }
      return {};
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> getAllTeams() async {
    try {
      Map<String, dynamic> players = {};
      final teamSnap =
          await FirebaseFirestore.instance.collectionGroup("teams").get();
      if (teamSnap.docs.isNotEmpty) {
        for (var team in teamSnap.docs) {
          players[team.id] = team['name'] ?? "";
        }
        return players;
      }
      return {};
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> getSeasons() async {
    try {
      Map<String, dynamic> seasons = {};
      final seasonSnap =
          await FirebaseFirestore.instance.collection("seasons").get();
      if (seasonSnap.docs.isNotEmpty) {
        for (var season in seasonSnap.docs) {
          seasons[season.id] = season['seasonName'] ?? "";
        }
        return seasons;
      }
      return {};
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  @override
  Future<void> updatePlayer(
      String playerId, PlayerModel playerModel, String season) async {
    try {
      final playerSnapshot = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(season)
          .collection(FirebaseConstants.playerCollection)
          .doc(playerId);
      playerSnapshot.update(playerModel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateTeam(
      String teamId, AslTeamModel teamModel, String season) async {
    try {
      final teamSnapshot = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(season)
          .collection(FirebaseConstants.teamCollection)
          .doc(teamId);
      teamSnapshot.update(teamModel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> addNewSeason(SeasonModel seasonModel) async {
    try {
      final playerSnap = FirebaseFirestore.instance.collection("seasons").doc();
      seasonModel.id = playerSnap.id;

      playerSnap.set(seasonModel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> addNewMatch(MatchModel matchmodel, String seasonId) async {
    try {
      final matchsnap = FirebaseFirestore.instance
          .collection("seasons")
          .doc(seasonId)
          .collection("matches")
          .doc();
      matchmodel.matchId = matchsnap.id;
      matchsnap.set(matchmodel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<List<PlayerModel>> getTeamPlayers(
      String teamA, String teamB, String seasonId) async {
    try {
      print("teamA: $teamA");
      print("teamB: $teamB");
      List<PlayerModel> playersList = [];
      final teamAsnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('players')
          .where('teamId', isEqualTo: teamA)
          .get();

      final teamBsnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('players')
          .where('teamId', isEqualTo: teamB)
          .get();

      playersList = [
        ...teamAsnap.docs.map(
          (e) => PlayerModel.fromMap(e.data()),
        ),
        ...teamBsnap.docs.map(
          (e) => PlayerModel.fromMap(e.data()),
        ),
      ];
      print("teamPlayersList: $playersList");
      return playersList;
    } catch (e, s) {
      debugPrint(s.toString());
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  Future<void> updatePlayerStat(
      {required String playerId,
      required String type,
      required String matchId,
      required String selectTeam,
      required String seasonId,
      required String assister,
      required String teamA,
      required String teamB,
      required String playerName,
      required bool isPenaltyGoal}) async {
    try {
      final goalRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('matches')
          .doc(matchId)
          .collection(FirebaseConstants.goalCollection)
          .doc();
      final matchRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('matches')
          .doc(matchId);

      if (type == PlayerTypes.goals.name ||
          type == PlayerTypes.assist.name ||
          type == PlayerTypes.penalty.name) {
        if (selectTeam == teamA) {
          matchRef.update({"teamAscore": FieldValue.increment(1)});
        } else if (selectTeam == teamB) {
          matchRef.update({"teamBscore": FieldValue.increment(1)});
        }
      }
      final playerRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('players')
          .doc(playerId);

      final goalModel = GoalModel(
          isPenaltyGoal: isPenaltyGoal,
          id: goalRef.id,
          assister: assister,
          goalTaker: playerId,
          goalTakerName: playerName,
          createdDate: DateTime.now(),
          team: selectTeam);

      goalRef.set(goalModel.toMap());

      DocumentReference<Map<String, dynamic>>? assisterRef;
      if (type == PlayerTypes.goals.name) {
        assisterRef = FirebaseFirestore.instance
            .collection(FirebaseConstants.seasonCollection)
            .doc(seasonId)
            .collection('players')
            .doc(assister);
      }

      switch (type) {
        case 'penalty':
          playerRef.update({"statics.goal": FieldValue.increment(1)});
        case 'goals':
          playerRef.update({"statics.goal": FieldValue.increment(1)});
          assisterRef?.update({"statics.assist": FieldValue.increment(1)});
          break;
        case 'yellow':
          playerRef.update({"statics.yelloCard": FieldValue.increment(1)});

        case 'red':
          playerRef.update({"statics.redCard": FieldValue.increment(1)});
        default:
      }
    } catch (e, s) {
      print(s.toString());
      debugPrint(e.toString());
      // debugPrint(s.toString());
    }
  }

  @override
  void updateMatchStat(
      {required String matchId,
      required String winner,
      required String teamA,
      required String teamB,
      required int teamBscore,
      required int teamAscore,
      required String currentStage,
      required BuildContext context,
      required String seasonId,
      required double w,
      required double h}) async {
    try {
      final matchRef = FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection('matches')
          .doc(matchId);

      matchRef.update({
        "status": MatchStatus.fulltime.name,
        'winner': winner,
        "ispenalty": winner.isNotEmpty ? true : false
      });

      //! player appereance update
      List<String> playersId = [];
      final playerRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('players');
      final teamAplayerssnap =
          await playerRef.where('teamId', isEqualTo: teamA).get();
      final teamBplayerssnap =
          await playerRef.where('teamId', isEqualTo: teamB).get();
      playersId = [
        ...teamAplayerssnap.docs.map((e) => e.id),
        ...teamBplayerssnap.docs.map((e) => e.id)
      ];
      for (var player in playersId) {
        playerRef.doc(player).update({"appearences": FieldValue.increment(1)});
      }

      //! teams apperences

      final teamAref = FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection('teams')
          .doc(teamA);
      final teamBref = FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection('teams')
          .doc(teamB);

      final getTeamAdata = await teamAref.get();
      final getTeamBdata = await teamBref.get();
      final matchdata = await matchRef.get();

      if (getTeamAdata.exists &&
          getTeamBdata.exists &&
          matchdata['stage'] == GroupType.group.name) {
        int teamAwin = getTeamAdata['win'] ?? 0;
        int teamAlose = getTeamAdata['lose'] ?? 0;
        int teamAdraw = getTeamAdata['draw'] ?? 0;

        int teamAPoint = getTeamAdata['point'] ?? 0;

        int teamBwin = getTeamBdata['win'] ?? 0;
        int teamBlose = getTeamBdata['lose'] ?? 0;
        int teamBdraw = getTeamBdata['draw'] ?? 0;

        int teamBPoint = getTeamBdata['point'] ?? 0;

        if (teamAscore > teamBscore) {
          teamAwin++;
          teamAPoint += 3;
          teamBlose++;
        } else if (teamAscore < teamBscore) {
          teamBwin++;
          teamBPoint += 3;
          teamAlose++;
        } else {
          teamAPoint++;
          teamBPoint++;
          teamAdraw++;
          teamBdraw++;
        }
        await teamAref.update({
          'win': teamAwin,
          'lose': teamAlose,
          'point': teamAPoint,
          'draw': teamAdraw,
          'playedMatch': FieldValue.increment(1)
        });
        await teamBref.update({
          'win': teamBwin,
          'lose': teamBlose,
          'point': teamBPoint,
          'draw': teamBdraw,
          'playedMatch': FieldValue.increment(1)
        });
      }
      print("0000000");
      if (context.mounted) {
        await checkAndupdateStage(
            currentStage, context, w, h, seasonId, winner);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> checkAndupdateStage(String currentStage, BuildContext context,
      double w, double h, String seasonId, String winner) async {
    try {
      print(" fun working");
      print("currentStage: $currentStage");
      final matchRef = await FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection('matches')
          .where('stage', isEqualTo: currentStage)
          .get();

      bool allCompleted = matchRef.docs.every(
          (element) => element.data()['status'] == MatchStatus.fulltime.name);

      if (allCompleted) {
        print("all completed");
        if (context.mounted) {
          if (currentStage == "group") {
            final groupAteams = await getTopTeams("A", seasonId);
            final groupBteams = await getTopTeams("B", seasonId);

            if (groupAteams.length < 2 || groupBteams.length < 2) {
              throw Exception('Not enough teams to create semifinals!');
            }
            final semifinal1 = {
              "teamA": groupAteams[0]['team'],
              'teamB': groupBteams[1]['team']
            };
            final semifinal2 = {
              "teamA": groupBteams[0]['team'],
              'teamB': groupAteams[1]['team']
            };
            final confirm = await alert(
                context, "Do you want create semifinal match", w, h);

            if (confirm) {
              final semifinalmatchModel = MatchModel(
                  seasonId: seasonId,
                  winner: "",
                  ispenalty: false,
                  goals: [],
                  delete: false,
                  teamA: semifinal1['teamA'],
                  teamB: semifinal1['teamB'],
                  stage: GroupType.semifinal.name,
                  kickoff: DateTime.now(),
                  status: "ongoing",
                  teamAscore: 0,
                  teamBscore: 0,
                  createdDate: DateTime.now());
              addNewMatch(semifinalmatchModel, seasonId);
              final semifinalmatchModel2 = MatchModel(
                  seasonId: seasonId,
                  winner: "",
                  ispenalty: false,
                  goals: [],
                  delete: false,
                  teamA: semifinal2['teamA'],
                  teamB: semifinal2['teamB'],
                  stage: GroupType.semifinal.name,
                  kickoff: DateTime.now(),
                  status: "ongoing",
                  teamAscore: 0,
                  teamBscore: 0,
                  createdDate: DateTime.now());
              addNewMatch(semifinalmatchModel2, seasonId);
            }
          } else if (currentStage == GroupType.semifinal.name) {
            print("else if working");
            final confirm =
                await alert(context, "Do you want create final match", w, h);
            if (confirm) {
              createFinalMatch(context, seasonId);
            }
          } else if (currentStage == GroupType.finalmatch.name) {
            print('is final');
            final seasonColRef =
                FirebaseFirestore.instance.collection('seasons').doc(seasonId);
            print('seasonRef: $seasonColRef');
            final matchData = matchRef.docs.firstWhere((element) =>
                element.data()['stage'] == GroupType.finalmatch.name &&
                element.data()['status'] == MatchStatus.fulltime.name);
            String runner = winner == matchData['teamA']
                ? matchData['teamB']
                : matchData['teamA'];
            seasonColRef.update({"winner": winner, "runner": runner});
            // if(matchColRef.exists){
            //   matchColRef.reference.update({
            //     ""
            //   })
            // }
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> createFinalMatch(BuildContext context, String seasonId) async {
    final semifinalMatchesRef = FirebaseFirestore.instance
        .collection('seasons')
        .doc(seasonId)
        .collection('matches')
        .where('stage', isEqualTo: GroupType.semifinal.name);

    final snapshot = await semifinalMatchesRef.get();

    if (snapshot.docs.length < 2) {
      throw Exception(
          'Both semifinals must be completed before creating the final.');
    }

    // Determine the winners
    final semifinal1 = snapshot.docs[0];
    final semifinal2 = snapshot.docs[1];

    String teamA = "";
    String teamB = "";

    if (semifinal1.data().containsKey('ispenalty')) {
      teamA = semifinal1['winner'];
    } else {
      teamA = semifinal1['teamAscore'] > semifinal1['teamBscore']
          ? semifinal1['teamA']
          : semifinal1['teamB'];
    }

    if (semifinal2.data().containsKey('ispenalty')) {
      teamB = semifinal2['winner'];
    } else {
      teamB = semifinal2['teamAscore'] > semifinal2['teamBscore']
          ? semifinal2['teamA']
          : semifinal2['teamB'];
    }

    // Create the final match

    final finalmatch = MatchModel(
        seasonId: seasonId,
        ispenalty: false,
        winner: "",
        goals: [],
        delete: false,
        teamA: teamA,
        teamB: teamB,
        stage: GroupType.finalmatch.name,
        kickoff: DateTime.now(),
        status: "ongoing",
        teamAscore: 0,
        teamBscore: 0,
        createdDate: DateTime.now());
    addNewMatch(finalmatch, seasonId);
    if (context.mounted) {
      showSnackBarToast(context, "Final Match created succesfully", "green");
      Navigator.pop(context);
    }
  }

  Future<List<Map<String, dynamic>>> getTopTeams(
      String group, String seasonId) async {
    try {
      final teamRef = FirebaseFirestore.instance
          .collection('seasons')
          .doc(seasonId)
          .collection('teams')
          .where('group', isEqualTo: group);
      final snapshot = await teamRef.orderBy('point', descending: true).get();
      return snapshot.docs
          .take(2)
          .map(
            (doc) => {"team": doc['teamId'], 'point': doc['point']},
          )
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<List<PlayerModel>> getSpecificTeamPlayers(
      {required String teamId, required String seasonId}) async {
    try {
      final playersSnap = await FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('players')
          .where('delete', isEqualTo: false)
          .where('teamId', isEqualTo: teamId)
          .get();
      if (playersSnap.docs.isNotEmpty) {
        return playersSnap.docs
            .map((e) => PlayerModel.fromMap(e.data()))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  @override
  Future<void> addNewManager(ManagerModel managermodel, String season) async {
    try {
      final managerSnap = FirebaseFirestore.instance
          .collection(FirebaseConstants.seasonCollection)
          .doc(season)
          .collection("managers")
          .doc();
      managermodel.id = managerSnap.id;
      managerSnap.set(managermodel.toMap());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<List<GoalModel>> getgoalByteam(
      {required String matchId,
      required String team,
      required String season}) async {
    final doc = await db
        .collection(FirebaseConstants.seasonCollection)
        .doc(season)
        .collection("matches")
        .doc(matchId)
        .collection(FirebaseConstants.goalCollection)
        .where("team", isEqualTo: team)
        .get();

    if (doc.docs.isNotEmpty) {
      return doc.docs.map((e) => GoalModel.fromMap(e.data())).toList();
    }
    return [];
  }

  Future<String?> uploadAwardImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('season_awards')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask;

      if (kIsWeb) {
        // 🌐 Web
        final Uint8List bytes = await image.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // 📱 Mobile
        uploadTask = ref.putFile(
          File(image.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload Award Image Error: $e");
      return null;
    }
  }

  Future<void> addSeasonAward({
    required String seasonId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final awardSnap = db
          .collection(FirebaseConstants.seasonCollection)
          .doc(seasonId)
          .collection('awards')
          .doc();
      data['id'] = awardSnap.id;
      awardSnap.set(data);
    } catch (e) {
      debugPrint("Add Season Award Error: $e");
      rethrow;
    }
  }
}
