class KuriMember {
  String? id;
  final String name;
  final String phone;
  final DateTime joinedDate;
  final int wonMonth;

  KuriMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinedDate,
    required this.wonMonth,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'joinedDate': joinedDate,
      'wonMonth': wonMonth,
    };
  }

  factory KuriMember.fromJson(Map<String, dynamic> json) {
    return KuriMember(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      joinedDate: json['joinedDate']?.toDate(),
      wonMonth: json['wonMonth'],
    );
  }
}
