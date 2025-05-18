import 'dart:convert';

class UserDataModel {
  final String email;
  final String password;
  final String role;
  String? id;
  String? token;

  UserDataModel(
      {required this.email,
      required this.password,
      required this.role,
      this.token,
      this.id});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'role': role,
      'id': id,
      'token':token??"",
    };
  }

  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
        email: map['email'] ?? "",
        password: map['password'] ?? "",
        token: map['token']??"",
        id: map['id'] ?? "",
        role: map['role'] ?? "");
  }
}
