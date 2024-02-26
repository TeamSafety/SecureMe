import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/message_chat.dart';

class MessageService {
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  Future<void> sendMessage(MessageChat message) async {
    await _messagesCollection.add(message.toJson());
  }

  Stream<List<MessageChat>> getMessages(String userId) {
    return _messagesCollection
        .where('fromUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageChat.fromDocument(doc);
      }).toList();
    });
  }
}
