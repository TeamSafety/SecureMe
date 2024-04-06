class PersonalContactModel {
  final String contactName;
  final String initialsTemp;
  final String imagePath;
  final String addedContactUid;
  final String uid;
  final double lat;
  final double long;

  PersonalContactModel({
    required this.contactName,
    required this.initialsTemp,
    required this.uid,
    required this.imagePath,
    required this.addedContactUid,
    required this.lat,
    required this.long,
  });

  factory PersonalContactModel.fromMap(Map<String, dynamic> map) {
    return PersonalContactModel(
      contactName: map['contactName'] ?? '',
      initialsTemp: map['initialsTemp'] ?? '',
      uid: map['uid'] ?? '',
      imagePath: map['imagePath'] ?? 'assets/images/avatar_default.jpg',
      addedContactUid: map['contactUid'] ?? '',
      lat: map['lat'] ?? '',
      long: map['long'] ?? '',
    );
  }
}
