import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/Chat/message_chat.dart';

class MessageService {
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection('messages');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
      return userDoc.get('username') ?? 'Unknown User';
    } catch (e) {
      print('Error fetching user information: $e');
      return 'Unknown User';
    }
  }
 Future<Map<String, String>> getUserNames(String idFrom, String idTo) async {
    try {
      final Map<String, String> names = {};

      final senderDoc = await _firestore.collection('Users').doc(idFrom).get();
      final receiverDoc = await _firestore.collection('Users').doc(idTo).get();

      names[idFrom] = senderDoc.get('username') ?? 'Unknown User';
      names[idTo] = receiverDoc.get('username') ?? 'Unknown User';

      return names;
    } catch (e) {
      print('Error fetching user information: $e');
      return {};
    }
  }


  Future<void> sendMessage(MessageChat message, String chatroomId) async {
    await _messagesCollection.doc(chatroomId).collection('messages').add(message.toJson());
  }

  Stream<List<MessageChat>> getMessages(String chatroomId) {
    return _messagesCollection.doc(chatroomId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageChat.fromDocument(doc);
      }).toList();
    });
  }

  String getChatroomId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort(); // Ensure consistent order to generate the same chatroom ID for both users
    return userIds.join('_'); // Combine user IDs to create a unique chatroom ID
  }

  Future<List<String>> getUserPresetMessages(String userId) async {
    try {
      var userDoc = await _firestore.collection('Users').doc(userId).get();

      if (userDoc.exists) {
        var messagesCollection = userDoc.reference.collection('messages');
        // Fetch documents from the 'messages' subcollection
        var messagesQuery = await messagesCollection.get();
        // Extract the message field from each document
        List<String> presetMessages = messagesQuery.docs
            .map((messageDoc) => messageDoc['message'] as String)
            .toList();

        return presetMessages;
      } else {
        // User document not found
        return [];
      }
    } catch (e) {
      // Handle errors
      print('Error fetching user preset messages: $e');
      return [];
    }
  }
}

