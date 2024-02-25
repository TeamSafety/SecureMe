class PersonalContactModel {
  final String contactName;
  final String initialsTemp;

  final String uid;

  PersonalContactModel({
    required this.contactName,
    required this.initialsTemp,
    required this.uid,
  });

  factory PersonalContactModel.fromMap(Map<String, dynamic> map) {
    return PersonalContactModel(
      contactName: map['contactName'] ?? '',
      initialsTemp: map['initialsTemp'] ?? '',
      uid: map['uid'] ?? '',
    );
  }
}
