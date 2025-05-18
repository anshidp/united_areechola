// ignore_for_file: public_member_api_docs, sort_constructors_first
class EventModel {
  String? eventname;
  String? eventId;
  List? users;
  double? income;
  double? expense;
  double? balance;
  DateTime? createdDate;
  String? discription;
  double? targetamount;
  bool? delete;
  EventModel(
      {this.eventname,
      this.eventId,
      this.users,
      this.income,
      this.expense,
      this.targetamount,
      this.balance,
      this.delete,
      this.discription,
      this.createdDate});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventname': eventname,
      'id': eventId,
      'users': users,
      'totalIncome': income,
      'totalexpense': expense,
      'balance': balance,
      "createdDate": createdDate,
      "discription": discription,
      "targetamount": targetamount,
      "delete": delete
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventname: map['eventname'] ?? "",
      delete: map["delete"] ?? false,
      eventId: map['id'] ?? "",
      users: map['users'] ?? [],
      income: map['totalIncome'] == null ? null : map['totalIncome'].toDouble(),
      expense:
          map['totalexpense'] == null ? null : map['totalexpense'].toDouble(),
      discription: map["discription"] ?? '',
      targetamount:
          map["targetamount"] == null ? null : map['targetamount'].toDouble(),
      createdDate:
          map["createdDate"] == null ? null : map["createdDate"].toDate(),
      balance: map['balance'] == null ? null : map['balance'].toDouble(),
    );
  }
}
