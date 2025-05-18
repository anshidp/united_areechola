class Usermodel {
  String? name;
  String? email;
  String? phoneNumber;
  bool? delete;
  DateTime? createdDate;
  String? password;
  String? id;
  String? bloodGroup;
  int? age;
  List? search;
  String? token;
  Usermodel({
    this.token,
    this.name,
    this.email,
    this.phoneNumber,
    this.delete,
    this.createdDate,
    this.password,
    this.id,
    this.bloodGroup,
    this.age,
    this.search,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token ?? "",
      'name': name,
      "search": search,
      'email': email,
      'phoneNumber': phoneNumber,
      'delete': delete,
      'createdDate': createdDate,
      'password': password,
      'id': id,
      'bloodgroup': bloodGroup,
      'age': age,
    };
  }

  factory Usermodel.fromMap(Map<String, dynamic> map) {
    return Usermodel(
        token: map['token'] ?? "",
        name: map['name'],
        email: map['email'],
        phoneNumber: map['phoneNumber'],
        delete: map['delete'] != null ? map['delete'] as bool : null,
        createdDate: map['createdDate']?.toDate(),
        password: map['password'],
        id: map['id'],
        bloodGroup: map['bloodgroup'],
        age: map['age'],
        search: map["search"] ?? []);
  }
}
