import 'package:flutter/material.dart';
import 'package:my_app/models/message_chat.dart';
import 'package:my_app/models/message_service.dart';

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
    _chatroomId = _messageService.getChatroomId(widget.userId, widget.recipientUserId);
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _messageService.getUserName(widget.recipientUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return const Text('Error loading user name');
            }
            return Text('Chat with ${snapshot.data}');
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
                  return const CircularProgressIndicator();
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
      future: _messageService.getUserNames(message.fromUserId, message.toUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return const Text('Error loading names');
        }

        final senderName = snapshot.data?[message.fromUserId] ?? 'Unknown User';
        final isCurrentUser = message.fromUserId == widget.userId;

        return Align(
          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentUser ? 'You' : senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message.content,
                  style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
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
      child: Row(
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
}
