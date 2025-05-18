// ignore_for_file: public_member_api_docs, sort_constructors_first
class EventExpenseModel {
  String? eventId;
  double? amount;
  String? userId;
  DateTime? createdDate;
  String? id;
  String? expenseName;
  EventExpenseModel({
    this.eventId,
    this.amount,
    this.userId,
    this.createdDate,
    this.id,
    this.expenseName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventId': eventId,
      'expenseAmount': amount,
      'userId': userId,
      'createdDate': createdDate,
      'id': id,
      'expenseName': expenseName
    };
  }

  factory EventExpenseModel.fromMap(Map<String, dynamic> map) {
    return EventExpenseModel(
        eventId: map['eventId'] ?? "",
        expenseName: map['expenseName'] ?? "",
        amount: map['expenseAmount'] == null
            ? null
            : map["expenseAmount"].toDouble(),
        userId: map['userId'] ?? "",
        createdDate:
            map['createdDate'] == null ? null : map['createdDate'].toDate(),
        id: map['id'] ?? "");
  }
}
