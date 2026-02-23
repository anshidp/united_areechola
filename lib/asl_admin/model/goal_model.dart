// ignore_for_file: public_member_api_docs, sort_constructors_first
class GoalModel {
  String? id;
  String? goalTaker;
  String? goalTakerName;
  String? assister;
  DateTime? createdDate;
  String? team;
  bool? isPenaltyGoal;
  String? type; // Added type field

  GoalModel({
    this.id,
    this.goalTaker,
    this.assister,
    this.createdDate,
    this.team,
    this.goalTakerName,
    this.isPenaltyGoal,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isPenaltyGoal': isPenaltyGoal,
      'goalTaker': goalTaker,
      'assister': assister,
      'createdDate': createdDate,
      'team': team,
      'goalTakerName': goalTakerName,
      'type': type,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      isPenaltyGoal: map['isPenaltyGoal'] ?? false,
      id: map['id'],
      goalTaker: map['goalTaker'] ?? "",
      assister: map['assister'] ?? "",
      createdDate: map['createdDate']?.toDate(),
      team: map['team'] ?? "",
      goalTakerName: map['goalTakerName'] ?? "",
      type: map['type'],
    );
  }
}
