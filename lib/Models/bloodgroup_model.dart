// ignore_for_file: public_member_api_docs, sort_constructors_first
class BloodGroup {
  String? name;
  String? phoneNumber;
  String? bloodGroup;
  BloodGroup({
    this.name,
    this.phoneNumber,
    this.bloodGroup,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'bloodGroup': bloodGroup,
    };
  }

  factory BloodGroup.fromMap(Map<String, dynamic> map) {
    return BloodGroup(
        name: map['name'] ?? "",
        phoneNumber: map['phoneNumber'] ?? "",
        bloodGroup: map['bloodGroup'] ?? "");
  }
}
