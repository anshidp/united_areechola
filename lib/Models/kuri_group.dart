class KuriGroup {
  String? id;
  final String name;
  final int totalMembers;
  final int monthlyContribution;
  final int totalAmount;
  final DateTime startDate;
  final int currentMonth;
  final List<String> memberIds;
  final Map monthlyWinners;
  DateTime? lastSpinDate;
  final bool delete;

  KuriGroup(
      {required this.id,
      required this.name,
      required this.totalMembers,
      required this.monthlyContribution,
      required this.totalAmount,
      required this.startDate,
      required this.currentMonth,
      required this.memberIds,
      required this.monthlyWinners,
      required this.delete,
      this.lastSpinDate});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalMembers': totalMembers,
      'monthlyContribution': monthlyContribution,
      'totalAmount': totalAmount,
      'startDate': startDate,
      'currentMonth': currentMonth,
      'memberIds': memberIds,
      'monthlyWinners': monthlyWinners,
      'lastSpinDate': lastSpinDate,
      'delete':false
    };
  }

  factory KuriGroup.fromJson(Map<String, dynamic> json) {
    return KuriGroup(
      delete: json['delete'],
      id: json['id'],
      name: json['name'],
      totalMembers: json['totalMembers'],
      monthlyContribution: json['monthlyContribution'],
      totalAmount: json['totalAmount'],
      startDate: json['startDate']?.toDate(),
      currentMonth: json['currentMonth'],
      memberIds: List<String>.from(json['memberIds']),
      monthlyWinners: json['monthlyWinners'] ?? {},
      lastSpinDate: json['lastSpinDate']?.toDate(),
    );
  }
}
