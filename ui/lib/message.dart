import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ui/auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class MessagePage extends StatefulWidget {
  final String otherUserName;
  final Uint8List? otherUserProfilePicture;
  final String otherUserId;

  const MessagePage({
    required this.otherUserName,
    required this.otherUserProfilePicture,
    required this.otherUserId,
  });

  @override
  MessagePageState createState() => MessagePageState();
}

class Message {
  String text;
  // True if the message was sent by the current user
  bool isCurrentUser; 
  DateTime timestamp;

  Message({
    required this.text,
    required this.isCurrentUser,
    required this.timestamp,
  });
}

class MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  List<Message> _messages = [];
  List<String> messages = [];
  Uint8List? _currentUserProfilePicture;

  @override
  void initState() {
    super.initState();
    // Initialize with some test messages
    _messages = [
      Message(
        text: 'Hello, how are you?',
        isCurrentUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        text: 'I\'m fine, thanks! And you?',
        isCurrentUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Message(
        text: 'I\'m doing well too.',
        isCurrentUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];

    _initSocket();
    _fetchAndSetProfilePicture();
    _fetchMessages();
  }

  void _fetchAndSetProfilePicture() {
    Authorization().getRequest("/profile/").then((value) {
      final responseBody = json.decode(value.toString()); 
      if (responseBody['profile'] != null && responseBody['profile']['picture1'] != null) {
        final String base64Image = responseBody['profile']['picture1'];
        setState(() {
          _currentUserProfilePicture = base64Decode(base64Image);
        });
      }
    });
  }

  void _fetchMessages() {
    Authorization().getRequest("/message/${widget.otherUserId}/").then((value) {
      final responseBody = json.decode(value.toString());
      if (responseBody['messages'] != null) {
        setState(() {
          messages = List<String>.from(responseBody['messages']);
        });
      }
    });
  }

  void _initSocket() {
    socket = IO.io('http://localhost:3001', <String, dynamic>{
      'transports':['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO');
    });

    socket.on('message', (data) {
      print('Received message: $data');
    });

    socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));
  }

  void _sendMessage() {
    final String text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
        text: text,
        isCurrentUser: true,
        timestamp: DateTime.now(),
      );
      setState(() {
        Authorization().postRequest('/message/${widget.otherUserId}/', {
          'message': message.text
        }).then((value) => {
          _messages.add(message)
        });
        
      });
      _messageController.clear();
      // send message to the server
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                return ListTile(
                  // display profile picture of the other user
                  leading: message.isCurrentUser ? null : CircleAvatar(
                    backgroundImage: widget.otherUserProfilePicture != null ? MemoryImage(widget.otherUserProfilePicture!) : null,
                  ),
                  // display profile picture of the current user
                  trailing: message.isCurrentUser ? CircleAvatar(
                    backgroundImage: _currentUserProfilePicture != null ? MemoryImage(_currentUserProfilePicture!) : null,
                  ) : null,
                  title: Align(
                    alignment: message.isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: message.isCurrentUser ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              message.text,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                               _formatTimestamp(message.timestamp),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          )
                        ],
                      ),
                    )
                  )
                );
              }
            ),
          ),
        // Input area 
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: InputBorder.none,
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
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _messageController.dispose();
    socket.disconnect();
    super.dispose();
  }
}

// to send message: make a post request to the `/message/<other_user_id>/` to send a message.
// For the body of the message send: {'message': 'The text you are trying to send'}.

// to receive all the messages when you open the page:
// Make a get request to `/message/<other_user_id>/`