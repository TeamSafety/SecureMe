class PersonalContactModel {
  final String contactName;
  final String initialsTemp;
  final String imagePath; 
  final String addedContactUid; 
  final String uid;

  PersonalContactModel({
    required this.contactName,
    required this.initialsTemp,
    required this.uid,
    required this.imagePath, 
    required this.addedContactUid, 
  });

  factory PersonalContactModel.fromMap(Map<String, dynamic> map) {
    return PersonalContactModel(
      contactName: map['contactName'] ?? '',
      initialsTemp: map['initialsTemp'] ?? '',
      uid: map['uid'] ?? '',
      imagePath: map['imagePath'] ?? 'avatar_default.jpg',
      addedContactUid: map['contactUid'] ?? '',
    );
  }
}
