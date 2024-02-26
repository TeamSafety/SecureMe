import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/firestore_constants.dart';

class MessageChat {
  final String fromUserId;
  final String toUserId;
  final DateTime timestamp; // Correct type
  final String content;

  const MessageChat({
    required this.fromUserId,
    required this.toUserId,
    required this.timestamp,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.idFrom: this.fromUserId,
      FirestoreConstants.idTo: this.toUserId,
      FirestoreConstants.timestamp: Timestamp.fromDate(this.timestamp),
      FirestoreConstants.content: this.content,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    return MessageChat(
      fromUserId: doc.get(FirestoreConstants.idFrom),
      toUserId: doc.get(FirestoreConstants.idTo),
      timestamp: (doc.get(FirestoreConstants.timestamp) as Timestamp).toDate(),
      content: doc.get(FirestoreConstants.content),
    );
  }
}
