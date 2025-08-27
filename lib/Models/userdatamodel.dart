class UserDataModel {
  final String email;
  String? password;
  final String role;
  String? id;
  String? token;
  String? fullName;
  String? phoneNumber;
  String? photoUrl;
  bool? delete;
  DateTime? createdDate;

  UserDataModel({
    required this.email,
    this.password,
    this.fullName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    this.token,
    this.id,
    this.createdDate,
    this.delete,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'photoUrl': photoUrl,
      'fullName': fullName,
      'createdDate': createdDate,
      'delete': delete,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'role': role,
      'id': id,
      'token': token ?? "",
    };
  }

  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
        createdDate: map['createdDate']?.toDate(),
        delete: map['delete'] ?? false,
        fullName: map['fullName'] ?? "",
        phoneNumber: map['phoneNumber'] ?? "",
        photoUrl: map['photoUrl'] ?? "",
        email: map['email'] ?? "",
        password: map['password'] ?? "",
        token: map['token'] ?? "",
        id: map['id'] ?? "",
        role: map['role'] ?? "");
  }
}
