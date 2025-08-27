// ignore_for_file: public_member_api_docs, sort_constructors_first
class NotificationModel {
  String? id;
  DateTime? createdDate;
  String? title;
  String? body;
  bool? delete;
  NotificationModel({
    this.createdDate,
    this.title,
    this.body,
    this.delete,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdDate': createdDate,
      'id': id,
      'title': title,
      'body': body,
      'delete': delete ?? false,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
        createdDate: map['createdDate']?.toDate(),
        title: map['title'] ?? "",
        body: map['body'] ?? "",
        delete: map['delete'] ?? false);
  }
}
