// ignore_for_file: public_member_api_docs, sort_constructors_first
class EventTransactionModel {
  String? eventId;
  double? amount;
  String? userId;
  DateTime? createdDate;
  String? id;
  bool? delete;
  List? search;
  String? username;
  EventTransactionModel({
    this.eventId,
    this.amount,
    this.userId,
    this.createdDate,
    this.id,
    this.delete,
    this.search,
    this.username,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'eventId': eventId,
      'amount': amount,
      'userId': userId,
      'createdDate': createdDate,
      'id': id,
      'delete': delete,
      'search': search,
      'username': username
    };
  }

  factory EventTransactionModel.fromMap(Map<String, dynamic> map) {
    return EventTransactionModel(
        eventId: map['eventId'] ?? "",
        search: map['search'] ?? [],
        amount: map['amount']?.toDouble(),
        userId: map['userId'] ?? "",
        delete: map['delete'] ?? false,
        username: map['username'] ?? "",
        createdDate: map['createdDate']?.toDate(),
        id: map['id'] ?? "");
  }
}
