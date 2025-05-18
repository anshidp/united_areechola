// ignore_for_file: public_member_api_docs, sort_constructors_first
class SubcriptionModel {
  String? id;
  String? userId;
  double? amount;
  DateTime? createdDate;
  DateTime? startDate;
  bool? delete;
  int? status;
  DateTime? expireDate;
  int? month;
  SubcriptionModel({
    this.id,
    this.userId,
    this.amount,
    this.createdDate,
    this.delete,
    this.status,
    this.expireDate,
    this.startDate,
    this.month,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'amount': amount,
      'createdDate': createdDate,
      'delete': delete,
      'status': status,
      'expireDate': expireDate,
      'startDate': startDate,
      'month': month
    };
  }

  factory SubcriptionModel.fromMap(Map<String, dynamic> map) {
    return SubcriptionModel(
        month: map['month'] ?? 0,
        id: map['id'] ?? "",
        startDate: map['startDate']?.toDate(),
        userId: map['userId'] ?? "",
        amount: map['amount']?.toDouble(),
        createdDate:
            map['createdDate'] == null ? null : map["createdDate"].toDate(),
        delete: map['delete'] ?? false,
        status: map['status'] ?? 0,
        expireDate:
            map['expireDate'] == null ? null : map["expireDate"].toDate());
  }
}
