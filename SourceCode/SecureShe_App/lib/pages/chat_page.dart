import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Chat/message_chat.dart';
import 'package:my_app/models/Chat/message_service.dart';
import 'package:my_app/pages/my_contacts.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String recipientUserId;

  ChatScreen({required this.userId, required this.recipientUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  late String _chatroomId;

  @override
  void initState() {
    super.initState();
    _chatroomId =
        _messageService.getChatroomId(widget.userId, widget.recipientUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppVars.accent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            _onBackPress();
          },
        ),
        title: FutureBuilder<String>(
          future: _messageService.getUserName(widget.recipientUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading...',
                style: TextStyle(color: Colors.white),
              );
            }
            if (snapshot.hasError) {
              return const Text(
                'Error loading user name',
                style: TextStyle(color: Colors.white),
              );
            }
            return Text(
              'Chat with ${snapshot.data}',
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageChat>>(
              stream: _messageService.getMessages(_chatroomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("  ");
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                return ListView.builder(
                  //reverse: true, // To display the latest messages at the bottom
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(snapshot.data![index]);
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageChat message) {
    return FutureBuilder<Map<String, String>>(
      future:
          _messageService.getUserNames(message.fromUserId, message.toUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("  ");
        }

        if (snapshot.hasError) {
          return const Text('Error loading names');
        }

        final senderName = snapshot.data?[message.fromUserId] ?? 'Unknown User';
        final isCurrentUser = message.fromUserId == widget.userId;

        return Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentUser ? AppVars.accent : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? 'You' : senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message.content,
                  style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Display user-specific preset messages as suggestions
          Container(
            height: 50,
            child: FutureBuilder<List<String>>(
              future: _messageService.getUserPresetMessages(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("  ");
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  // Handle error or empty preset messages
                  return Container();
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Set the tapped preset message in the input field
                        _messageController.text = snapshot.data![index];
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppVars.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            snapshot.data![index],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input field for typing a message
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _sendMessage();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      final newMessage = MessageChat(
        fromUserId: widget.userId,
        toUserId: widget.recipientUserId,
        timestamp: DateTime.now(),
        content: content,
      );

      _messageService.sendMessage(newMessage, _chatroomId);
      _messageController.clear();
    }
  }

  void _onBackPress() async {
    try {
      final messagesCollection = FirebaseFirestore.instance
          .collection('messages')
          .doc(_chatroomId)
          .collection('messages');

      final documents = await messagesCollection.get();
      for (final doc in documents.docs) {
        await messagesCollection.doc(doc.id).update({
          'chattingWith': null,
        });
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyContacts()),
      );
    } catch (e) {
      print('Error during back press: $e');
    }
  }
}
